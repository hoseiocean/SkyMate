//
//  RecognitionManager.swift
//  SkyMate
//
//  Created by Thomas Heinis on 15/06/2023.
//

import Speech

protocol RecognitionManagerDelegate: AnyObject {
  func recognitionManagerFailedToRestart(_ recognitionManager: RecognitionManager)
}

/// The `RecognitionManager` class is responsible for managing the speech recognition process.
/// It utilizes an `AudioManager` to capture audio input, an `SFSpeechRecognizer` to perform speech recognition,
/// and a `Queue<SMTranscriptionSegment>` to hold the recognized speech segments.
/// If the recognition task fails, the manager will attempt to restart the task once.
/// If the restart also fails, it informs the delegate via the `recognitionManagerFailedToRestart(_:)` method.
final class RecognitionManager {

  // MARK: - Properties

  /// Defines custom error types thrown by RecognitionManager.
  private enum Error: Swift.Error {
    /// Thrown when there is no last segment in the current transcription.
    case lastSegmentFailed
    /// Thrown when the recognition request does not support reporting partial results.
    /// By default, an `SFSpeechAudioBufferRecognitionRequest` does report partial results.
    /// If this error is thrown, ensure `recognitionRequest.shouldReportPartialResults` is set to `true`.
    case partialRecognitionNotReported
    /// Thrown when there was a problem starting the recognition task.
    case recognitionTaskFailure(error: Swift.Error)
    /// Thrown when transcription of speech fails.
    case transcriptionFailed
    /// Thrown when an unexpected or invalid recognition result is received.
    case unexpectedRecognitionResult
  }

  private let audioManager: AudioManager
  private let recognitionObserver: RecognitionObserver
  private let segmentsQueue: TranscriptionSegmentQueue
  private let speechRecognizer: SFSpeechRecognizer

  weak var delegate: RecognitionManagerDelegate?

  private var isStopping: Bool = false
  private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest
  private var recognitionTask: SFSpeechRecognitionTask?
  private var shouldRetry = true

  // MARK: - Initialization

  /// Creates an instance of `RecognitionManager`.
  ///
  /// The `RecognitionManager` handles the whole process of speech recognition, using the provided audio manager to capture audio input, a speech recognizer for converting spoken words into text, and a queue for holding transcriptions.
  ///
  /// - Parameters:
  ///   - audioManager: An instance of `AudioManager` for capturing audio input.
  ///   - speechRecognizer: An instance of `SFSpeechRecognizer` for performing speech recognition.
  ///   - segmentsQueue: A queue for holding recognized speech segments in form of `SMTranscriptionSegment`.
  ///
  /// - Throws: An error of type `AudioManager.AudioSessionSetupError` in case audio session setup failed.
  init(
    audioManager: AudioManager,
    speechRecognizer: SFSpeechRecognizer,
    segmentsQueue: TranscriptionSegmentQueue,
    recognitionObserver: RecognitionObserver
  ) throws {
    self.audioManager = audioManager
    self.speechRecognizer = speechRecognizer
    self.segmentsQueue = segmentsQueue
    self.recognitionObserver = recognitionObserver

    recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
    recognitionRequest.requiresOnDeviceRecognition = true

    audioManager.delegate = self
  }

  // MARK: - Private Methods

  /// Handles an error that occurred during the recognition process.
  /// If `shouldRetry` is `true`, it attempts to restart the recognition task.
  /// If the restart also fails, it informs the delegate via the `recognitionManagerFailedToRestart(_:)` method.
  private func handleRecognitionError(_ error: Swift.Error, delay: DispatchTimeInterval = DispatchTimeInterval.seconds(1)) {
    guard !isStopping else { return }

    print("An error occurred during recognition:", error)
    if self.shouldRetry {
      shouldRetry = false
      DispatchQueue.main.asyncAfter(deadline: .now() + delay) { [weak self] in
        print("Restarting the recognition")
        self?.start()
      }
    } else {
      print("Failed restarting the recognition")
      delegate?.recognitionManagerFailedToRestart(self)
    }
  }

  /// Starts a new recognition task.
  /// - Throws: `Error.recognitionTaskFailure(error:)` if there was a problem starting the recognition task.
  ///           `Error.unexpectedRecognitionResult` if an unexpected or invalid recognition result is received.
  ///           `Error.transcriptionFailed` if the transcription of the speech fails.
  ///           `Error.lastSegmentFailed` if there is no last segment in the current transcription.
  /// The method also handles any errors that occur during recognition by calling `handleRecognitionError(_:)`.
  private func startRecognitionTask() throws -> SFSpeechRecognitionTask {
    return speechRecognizer.recognitionTask(with: recognitionRequest) { [weak self] result, error in
      guard let self else {
        return
      }
      do {
        if let error {
          throw Error.recognitionTaskFailure(error: error)
        }

        guard let result else {
          throw Error.unexpectedRecognitionResult
        }

        guard result.speechRecognitionMetadata == nil else {
          return
        }

        guard result.transcriptions.count == 1, let transcription = result.transcriptions.first else {
          throw Error.transcriptionFailed
        }

        guard let segment = transcription.segments.last else {
          throw Error.lastSegmentFailed
        }

        self.segmentsQueue.enqueue(segment)
      } catch {
        self.handleRecognitionError(error)
      }
    }
  }

  // MARK: - Public Methods

  /// Starts the speech recognition process.
  /// - Throws: `Error.partialRecognitionNotReported` if the recognition request does not support reporting partial results.
  /// The method also handles any errors that occur during recognition by calling `handleRecognitionError(_:)`.
  func start() {
    stop()
    do {
      guard recognitionRequest.shouldReportPartialResults else { throw Error.partialRecognitionNotReported }
      try audioManager.startListening()
      recognitionTask = try startRecognitionTask()
      recognitionObserver.isRecognizing = true
    } catch {
      self.handleRecognitionError(error)
    }
  }

  /// Stops the speech recognition process.
  func stop() {
    isStopping = true
    recognitionTask?.cancel()
    recognitionTask = nil
    try? audioManager.stopListening()
    recognitionObserver.isRecognizing = false
  }
}

extension RecognitionManager: AudioManagerDelegate {

  /// Handles the receipt of an audio buffer from the audio manager.
  ///
  /// This method is called by the `AudioManager` when it has new audio buffer data. The audio data is appended to the current `SFSpeechAudioBufferRecognitionRequest` to continue the speech recognition process.
  ///
  /// - Parameter buffer: The `AVAudioPCMBuffer` object containing the new audio data.
  func didReceiveAudioBuffer(_ buffer: AVAudioPCMBuffer) {
    recognitionRequest.append(buffer)
  }

}
