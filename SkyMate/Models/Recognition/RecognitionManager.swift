//
//  RecognitionManager.swift
//  SkyMate
//
//  Created by Thomas Heinis on 15/06/2023.
//

import Speech

// MARK: - RecognitionManagerDelegate

/// Delegates recognition manager failures, specifically restart failures.
protocol RecognitionManagerDelegate: AnyObject {
  func recognitionManagerFailedToRestart(_ recognitionManager: RecognitionManager)
}

// MARK: - RecognitionManagerState

/// Enum representing different states of the recognition process.
enum RecognitionManagerState {
  case error(Swift.Error)
  case idle
  case initializing
  case listening
  case stopping
}

// MARK: - RecognitionManager

/// `RecognitionManager` handles the speech recognition process using audio input from `AudioManager`,
/// `SFSpeechRecognizer` for speech recognition, and a queue for holding recognized speech segments.
/// If the recognition task fails, it attempts to restart once. If the restart also fails, it informs
/// the delegate.
final class RecognitionManager: ObservableObject {

  // MARK: - Properties

  /// Custom error types thrown by RecognitionManager.
  private enum Error: Swift.Error {
    case audioBufferFailed
    case lastSegmentFailed
    case partialRecognitionNotReported
    case recognitionRequestCreationFailed
    case recognitionTaskFailure(error: Swift.Error)
    case speechRecognizerNotAvailable
    case transcriptionFailed
    case unexpectedRecognitionResult
  }

  private let audioManager: AudioManager
  private let dispatchQueue: DispatchQueue
  private let segmentsQueue: TranscriptionSegmentQueue
  private let speechRecognizer: SFSpeechRecognizer

  private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
  private var recognitionTask: SFSpeechRecognitionTask?
  private var shouldRetry = true

  /// The state of recognition process.
  @Published private(set) var state: RecognitionManagerState = .idle

  ///
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
    dispatchQueue: DispatchQueue = .main
  ) throws {
    guard speechRecognizer.isAvailable else { throw Error.speechRecognizerNotAvailable }
    self.audioManager = audioManager
    self.speechRecognizer = speechRecognizer
    self.segmentsQueue = segmentsQueue
    self.dispatchQueue = dispatchQueue
    audioManager.delegate = self
  }

  // MARK: - Private Methods

  /// Handles an error that occurred during the recognition process.
  /// If `shouldRetry` is `true`, it attempts to restart the recognition task.
  /// If the restart also fails, it informs the delegate via the `recognitionManagerFailedToRestart(_:)` method.
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

  /// Starts a new recognition task.
  /// - Throws: `Error.recognitionTaskFailure(error:)` if there was a problem starting the recognition task.
  ///           `Error.unexpectedRecognitionResult` if an unexpected or invalid recognition result is received.
  ///           `Error.transcriptionFailed` if the transcription of the speech fails.
  ///           `Error.lastSegmentFailed` if there is no last segment in the current transcription.
  /// The method also handles any errors that occur during recognition by calling `handleRecognitionError(_:)`.
  private func startRecognitionTask() {
    guard let recognitionRequest = recognitionRequest else {
      setState(.error(Error.audioBufferFailed))
      return
    }
    speechRecognizer.recognitionTask(with: recognitionRequest) { [weak self] result, error in
      guard let self = self else { return }
      if let error = error {
        self.setState(.error(Error.recognitionTaskFailure(error: error)))
        return
      }

      guard let result = result else {
        self.setState(.error(Error.unexpectedRecognitionResult))
        return
      }

      guard result.speechRecognitionMetadata == nil else {
        return
      }

      guard result.transcriptions.count == 1, let transcription = result.transcriptions.first else {
        self.setState(.error(Error.transcriptionFailed))
        return
      }

      guard let segment = transcription.segments.last else {
        self.setState(.error(Error.lastSegmentFailed))
        return
      }

      segmentsQueue.enqueue(segment)
    }
  }

  // MARK: - Public Methods

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
      recognitionRequest.requiresOnDeviceRecognition = true
      guard recognitionRequest.shouldReportPartialResults else {
        setState(.error(Error.partialRecognitionNotReported))
        return
      }
      guard speechRecognizer.isAvailable else {
        setState(.error(Error.speechRecognizerNotAvailable))
        return
      }
      startRecognitionTask()
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

extension RecognitionManager: AudioManagerDelegate {

  /// Handles the receipt of an audio buffer from the audio manager.
  ///
  /// This method is called by the `AudioManager` when it has new audio buffer data. The audio data is appended to the current `SFSpeechAudioBufferRecognitionRequest` to continue the speech recognition process.
  ///
  /// - Parameter buffer: The `AVAudioPCMBuffer` object containing the new audio data.
  func audioManager(_ audioManager: AudioManager, didUpdate buffer: AVAudioPCMBuffer) {
    recognitionRequest?.append(buffer)
  }
}
