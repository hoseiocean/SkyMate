//
//  RecognitionManager.swift
//  SkyMate
//
//  Created by Thomas Heinis on 15/06/2023.
//

import Speech

// MARK: - RecognitionManagerDelegate

/// A protocol that defines the delegate methods for the RecognitionManager.
protocol RecognitionManagerDelegate: AnyObject {

  /// Called when the RecognitionManager successfully starts.
  func recognitionManagerDidStartSuccessfully(_ manager: RecognitionManager)

  /// Called when the RecognitionManager fails to restart.
  func recognitionManagerFailedToRestart(_ manager: RecognitionManager)
}

// MARK: - RecognitionManagerError

/// Enumerates the errors that the RecognitionManager can throw.
enum RecognitionManagerError: Error {
  case recognitionRequestCreationFailed
  case recognitionRequestNotSet
  case recognitionTaskFailure(error: Error)
  case recognitionTaskNotSet
  case speechRecognizerNotAvailable
  case unexpectedRecognitionResult
}

// MARK: - RecognitionManagerState

/// Enumerates the states that the RecognitionManager can be in.
enum RecognitionManagerState {
  case error(Error)
  case idle
  case initializing
  case listening
  case stopping
}

// MARK: - RecognitionManager

/// The main class for managing the speech recognition process.
final class RecognitionManager: ObservableObject {

  // MARK: - Config

  private struct Config {
    static let maxRetryCount = 3
  }

  // MARK: - Private Properties

  private let audioManager: AudioManager
  private let dispatchQueue: DispatchQueue
  private let operatingMode: RecognitionProviderOperatingMode
  private let speechRecognizer: SFSpeechRecognizer
  private let transcriptionProcessor: TranscriptionProcessor

  private var lastSpeechRecognitionResult: SFSpeechRecognitionResult?
  private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
  private var recognitionTask: SFSpeechRecognitionTask?
  private var retryCount: Int = 0
  private var lastTranscription: SFTranscription?

  // MARK: - State Property

  /// The current state of the RecognitionManager.
  @Published private(set) var state: RecognitionManagerState = .idle

  /// The delegate for the RecognitionManager.
  weak var delegate: RecognitionManagerDelegate?

  // MARK: - Initialization

  /// Initializes a new instance of RecognitionManager.
  init(
    audioManager: AudioManager,
    speechRecognizer: SFSpeechRecognizer,
    transcriptionProcessor: TranscriptionProcessor,
    dispatchQueue: DispatchQueue = .main,
    operatingMode: RecognitionProviderOperatingMode = .normal
  ) throws {
    guard speechRecognizer.isAvailable else { throw RecognitionManagerError.speechRecognizerNotAvailable }
    self.audioManager = audioManager
    self.speechRecognizer = speechRecognizer
    self.transcriptionProcessor = transcriptionProcessor
    self.dispatchQueue = dispatchQueue
    self.operatingMode = operatingMode
    audioManager.delegate = self
  }

  // MARK: - Private Methods

  private func createRecognitionRequest() throws {
    recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
    guard let recognitionRequest else {
      throw RecognitionManagerError.recognitionRequestCreationFailed
    }
    recognitionRequest.requiresOnDeviceRecognition = (operatingMode != .normal)
    recognitionRequest.shouldReportPartialResults = (operatingMode == .normal)
  }

  private func handleError(_ error: Error) {
    if case .stopping = state {
      return
    }

    if retryCount < Config.maxRetryCount {
      retryRecognition()
    } else {
      delegate?.recognitionManagerFailedToRestart(self)
      stopAndClean()
    }
  }

  private func isFunctionning() -> Bool {
    switch state {
    case .idle, .stopping:
      return false
    default:
      return true
    }
  }

  private func retryRecognition() {
    retryCount += 1
    let retryDelay = DispatchTimeInterval.seconds(Int(pow(2.0, Double(retryCount))))
    dispatchQueue.asyncAfter(deadline: .now() + retryDelay) { [weak self] in
      self?.listen()
    }
  }

  private func setState(_ newState: RecognitionManagerState) {
    dispatchQueue.async {
      self.state = newState
      print(Self.self, self.state)
      if case .error(let error) = newState {
        self.handleError(error)
      }
    }
  }

  private func startListening() async throws {
    guard recognitionRequest != nil else { throw RecognitionManagerError.recognitionRequestNotSet }
    guard recognitionTask != nil else { throw RecognitionManagerError.recognitionTaskNotSet }
    await audioManager.listen()
    setState(.listening)
    delegate?.recognitionManagerDidStartSuccessfully(self)
  }

  private func startRecognitionTask() throws {
    guard let recognitionRequest else {
      throw RecognitionManagerError.recognitionRequestNotSet
    }

    recognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest) { [weak self] result, error in
      guard let self, self.isFunctionning() else { return }

      if let error {
        self.setState(.error(RecognitionManagerError.recognitionTaskFailure(error: error)))
        return
      }

      guard let result else { self.setState(.error(RecognitionManagerError.unexpectedRecognitionResult)); return }
      self.transcriptionProcessor.parse(speechRecognitionResult: result)
    }

    // Establishing KVO mechanism for the `recognitionTask` object’s `isFinishing` property. The
    // purpose is to observe and respond to changes in the recognition task’s state (whether it’s
    // finishing or not). When the recognition task is observed to be finishing, the method
    // `stopAndClean()` is called to stop and reset all components related to the task, ensuring
    // a clean state for the next recognition task. Immediately after that, the `listen()` method
    // is invoked to start a new recognition task. Using the `.new` option means that the observer
    // wants to know the new value of `isFinishing`.
    _ = recognitionTask?.observe(\.isFinishing, options: .new) { [weak self] task, _ in
      guard let self else { return }
      if task.isFinishing {
        self.stopAndClean()
        self.listen()
      }
    }
  }

  // MARK: - Public Methods

  /// Starts the speech recognition process.
  func listen() {
    if case .listening = state {
      stopAndClean()
    }

    do {
      setState(.initializing)
      try createRecognitionRequest()
      try startRecognitionTask()
      Task {
        do {
          try await startListening()
        } catch {
          setState(.error(error))
        }
      }
    } catch {
      setState(.error(error))
    }
  }

  /// Stops and cleans up the recognition process.
  func stopAndClean() {
    setState(.stopping)
    audioManager.stopAndClean()
    recognitionTask?.cancel()
    recognitionTask = nil
    recognitionRequest = nil
    retryCount = .zero
    setState(.idle)
  }

  // MARK: - Deinitialization

  deinit {
    guard case .idle = state else {
      stopAndClean()
      return
    }
  }
}

// MARK: - AudioManagerDelegate

/// Extension to handle AudioManagerDelegate methods.
extension RecognitionManager: AudioManagerDelegate {

  /// Handles errors encountered by the AudioManager.
  func audioManager(_ audioManager: AudioManager, didEncounterError error: Swift.Error) {
    self.setState(.error(error))
  }

  /// Handles audio buffer updates from the AudioManager.
  func audioManager(_ audioManager: AudioManager, didUpdate buffer: AVAudioPCMBuffer) async {
    dispatchQueue.async {
      self.recognitionRequest?.append(buffer)
    }
  }
}
