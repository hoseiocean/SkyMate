//
//  RecognitionManager.swift
//  SkyMate
//
//  Created by Thomas Heinis on 15/06/2023.
//

import Speech

// MARK: - RecognitionManagerDelegate

/// Protocol defining delegate methods to handle recognition manager's events.
/// This allows observing the lifecycle of the recognition process from outside of `RecognitionManager`.
protocol RecognitionManagerDelegate: AnyObject {
  /// Triggered when the recognition manager has successfully restarted.
  func recognitionManagerDidRestartSuccessfully(_ manager: RecognitionManager)
  /// Triggered when the recognition manager fails to restart.
  func recognitionManagerFailedToRestart(_ manager: RecognitionManager)
}

// MARK: - RecognitionManagerState and Operating Mode

/// Enum representing the different operating modes of the recognition manager.
/// `learning` mode is for training the recognizer and `normal` mode is for production use.
enum RecognitionManagerOperatingMode {
  case learning
  case normal
}

/// Enum representing the different states of the recognition process.
/// This is used to track and manage the lifecycle of the recognition process within `RecognitionManager`.
enum RecognitionManagerState {
  case error(Swift.Error)
  case idle
  case initializing
  case listening
  case stopping
}

// MARK: - RecognitionManager

/// The `RecognitionManager` class is responsible for handling the speech recognition process.
/// It combines the audio input, speech recognition, and the handling of recognized segments into one coherent process.
final class RecognitionManager: ObservableObject {

  // MARK: - Properties

  private enum Error: Swift.Error {
    case audioBufferFailed
    case lastSegmentFailed
    case recognitionRequestCreationFailed
    case recognitionTaskFailure(error: Swift.Error)
    case speechRecognizerNotAvailable
    case transcriptionFailed
    case unexpectedRecognitionResult
  }

  // MARK: - Instance Variables

  private let audioManager: AudioManager
  private let dispatchQueue: DispatchQueue
  private let operatingMode: RecognitionManagerOperatingMode
  private let segmentsQueue: TranscriptionSegmentQueue
  private let speechRecognizer: SFSpeechRecognizer

  private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
  private var recognitionTask: SFSpeechRecognitionTask?
  private var shouldRetry = true

  /// The state of recognition process.
  /// This is used to communicate the current state of the recognition process to external observers.
  @Published private(set) var state: RecognitionManagerState = .idle

  /// The RecognitionManager delegate.
  /// This is used to communicate major recognition events to the outside world.
  weak var delegate: RecognitionManagerDelegate?

  // MARK: - Initialization

  /// Creates an instance of `RecognitionManager`.
  ///
  /// The `RecognitionManager` handles the entire speech recognition process. It uses an audio manager to capture
  /// audio input, a speech recognizer for converting spoken words into text, and a queue for holding recognized
  /// speech segments.
  ///
  /// - Parameters:
  ///   - audioManager: An instance of `AudioManager` for capturing audio input.
  ///   - speechRecognizer: An instance of `SFSpeechRecognizer` for performing speech recognition.
  ///   - segmentsQueue: A queue for holding recognized speech segments.
  ///   - dispatchQueue: The dispatch queue to use for handling recognition tasks. Defaults to the main queue.
  /// - Throws: An error of type `AudioManager.AudioSessionSetupError` if audio session setup fails.
  init(
    audioManager: AudioManager,
    speechRecognizer: SFSpeechRecognizer,
    segmentsQueue: TranscriptionSegmentQueue,
    dispatchQueue: DispatchQueue = .main,
    operatingMode: RecognitionManagerOperatingMode = .normal
  ) throws {
    guard speechRecognizer.isAvailable else { throw Error.speechRecognizerNotAvailable }
    self.audioManager = audioManager
    self.speechRecognizer = speechRecognizer
    self.segmentsQueue = segmentsQueue
    self.dispatchQueue = dispatchQueue
    self.operatingMode = operatingMode
    audioManager.delegate = self
  }

  // MARK: - Private Methods

  private func displayTranscriptions(from result: SFSpeechRecognitionResult) {
    print("Transcripts in order of decreasing confidence for language", Constant.Identifier.locale)
    for transcription in result.transcriptions {
      print(transcription.formattedString)
    }
  }

  private func enqueueSegments(from result: SFSpeechRecognitionResult) {
    guard result.speechRecognitionMetadata == nil else {
      return
    }
    guard result.transcriptions.count == 1, let transcription = result.transcriptions.first else {
      setState(.error(Error.transcriptionFailed))
      return
    }
    guard let segment = transcription.segments.last else {
      setState(.error(Error.lastSegmentFailed))
      return
    }
    segmentsQueue.enqueue(segment)
  }

  private func handleError(_ error: Swift.Error, delay: DispatchTimeInterval = DispatchTimeInterval.seconds(2)) {
    if case .stopping = state {
      return
    }

    print("An error occurred during recognition:", error)

    if shouldRetry {
      shouldRetry = false
      dispatchQueue.asyncAfter(deadline: .now() + delay) { [weak self] in
        self?.listen()
      }
    } else {
      stopAndClean()
      delegate?.recognitionManagerFailedToRestart(self)
    }
  }

  private func setState(_ newState: RecognitionManagerState) {
    state = newState
    if case .error(let error) = newState {
      handleError(error)
    }
  }

  private func recognize() {
    guard let recognitionRequest else {
      setState(.error(Error.audioBufferFailed))
      return
    }
    speechRecognizer.recognitionTask(with: recognitionRequest) { [weak self] result, error in
      guard let self else { return }

      if let error {
        self.setState(.error(Error.recognitionTaskFailure(error: error)))
        return
      }

      guard let result else {
        self.setState(.error(Error.unexpectedRecognitionResult))
        return
      }

      delegate?.recognitionManagerDidRestartSuccessfully(self)

      switch operatingMode {
      case .learning:
        displayTranscriptions(from: result)
      case .normal:
        enqueueSegments(from: result)
      }
    }
  }

  // MARK: - Core Functions

  /// Starts and process the speech recognition process.
  /// - Throws: `Error.partialRecognitionNotReported` if the recognition request does not support reporting partial results.
  /// The method also handles any errors that occur during recognition by calling `handleRecognitionError(_:)`.
  func listen() {
    if case .listening = state {
      stopAndClean()
    }
    do {
      setState(.initializing)
      recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
      guard let recognitionRequest else {
        setState(.error(Error.recognitionRequestCreationFailed))
        return
      }
      recognitionRequest.requiresOnDeviceRecognition = (operatingMode != .normal)
      recognitionRequest.shouldReportPartialResults = (operatingMode == .normal)
      guard speechRecognizer.isAvailable else {
        setState(.error(Error.speechRecognizerNotAvailable))
        return
      }
      recognize()
      try audioManager.listen()
      setState(.listening)
    } catch {
      setState(.error(error))
    }
  }

  /// Stops the speech recognition process and cleans up resources.
  func stopAndClean() {
    setState(.stopping)
    audioManager.stopAndClean()
    recognitionTask?.cancel()
    recognitionTask = nil
    recognitionRequest = nil
    setState(.idle)
  }

  deinit {
    stopAndClean()
  }
}

// MARK: - AudioManagerDelegate

/// Extension of RecognitionManager to comply with AudioManagerDelegate protocol.
/// This extension allows RecognitionManager to handle audio buffer updates.
extension RecognitionManager: AudioManagerDelegate {

  /// Handles the receipt of an audio buffer from the audio manager.
  ///
  /// This method is called by the `AudioManager` when it has new audio buffer data. The audio data is appended
  /// to the current `SFSpeechAudioBufferRecognitionRequest` to continue the speech recognition process.
  ///
  /// - Parameter buffer: The `AVAudioPCMBuffer` object containing the new audio data.
  func audioManager(_ audioManager: AudioManager, didUpdate buffer: AVAudioPCMBuffer) {
    recognitionRequest?.append(buffer)
  }
}
