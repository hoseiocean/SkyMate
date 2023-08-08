//
//  AudioManager.swift
//  SkyMate
//
//  Created by Thomas Heinis on 15/06/2023.
//

import AVFAudio

/// The `AudioManagerDelegate` protocol defines methods that an object may implement to receive
/// audio buffer updates from an `AudioManager`.
protocol AudioManagerDelegate: AnyObject {

  /// This method is called whenever the `AudioManager` encounters an error.
  ///
  /// - Parameters:
  ///   - audioManager: The `AudioManager` that is sending the buffer.
  ///   - error: The error encountered.
  func audioManager(_ audioManager: AudioManager, didEncounterError error: Swift.Error)

  /// This method is called whenever the `AudioManager` receives a new audio buffer.
  ///
  /// - Parameters:
  ///   - audioManager: The `AudioManager` that is sending the buffer.
  ///   - buffer: The new audio buffer.
  func audioManager(_ audioManager: AudioManager, didUpdate buffer: AVAudioPCMBuffer) async
}

/// `AudioManagerError` is an enumeration of the different errors that can occur during the
/// lifecycle of the `AudioManager`.
///
/// - `audioEngineStartingFailed`: This error occurs when the audio engine fails to start. It
/// provides an underlying `Error` object that can give more information about the problem.
///
/// - `audioSessionFailed`: This error occurs when there is a problem setting up the audio session.
/// It also provides an underlying `Error` object that can give more information about the
/// problem.
enum AudioManagerError: Error {
  case audioEngineStartingFailed(error: Error)
  case audioSessionFailed(error: Error)
}

final class AudioManager {

  // MARK: - Properties

  private struct Configuration {
    static let audioBus: AVAudioNodeBus = 0
    static let bufferSize: UInt32 = 1024
  }

  private var audioEngine: AVAudioEngine? = AVAudioEngine()
  private let bufferProcessingQueue = DispatchQueue(label: Const.Label.bufferProcessingQueue)

  private var isTapping: Bool = false

  /// The delegate object that will receive the audio buffer updates.
  /// It is declared as `weak` to prevent reference cycles.
  weak var delegate: AudioManagerDelegate?

  /// A boolean property indicating whether the audio engine is running.
  var isListening: Bool {
    guard let audioEngine else { return false }
    return audioEngine.isRunning
  }

  // MARK: - Public Methods

  /// Starts listening for audio input if it is not already doing so.
  ///
  /// This method is marked as `async` to handle potential blocking operations without blocking
  /// the main thread, and it `throws` to propagate errors that occur during the start-up process.
  ///
  /// - Throws: `Error.audioSessionFailed` if there is an issue with setting up the audio session,
  ///           `Error.audioEngineStartingFailed` if there is an issue starting the audio engine.
  func listen() async {
    guard !isListening else { return }

    // Before starting to listen, we ensure that any previously running audio engine or active tap
    // is stopped and cleaned. This is necessary to prevent any conflicts or issues with the audio
    // engine when starting a new session. Also, this helps with managing resources as any
    // lingering taps or audio engines from previous sessions are appropriately cleaned up.
    stopAndClean()

    // Here, we initiate the audio session and set its properties. An audio session is a singleton
    // object that is used to set the audio context for the app and to express to the operating
    // system how we intend to use audio session.
    let audioSession = AVAudioSession.sharedInstance()
    do {
      try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
      try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
    } catch {
      delegate?.audioManager(self, didEncounterError: AudioManagerError.audioSessionFailed(error: error))
    }

    // This block of code sets up an audio tap on the input node of the audio engine. A tap allows
    // us to intercept the audio data from the input node and process it before it gets to the
    // output. Here, we’re sending the audio data to our delegate via the
    // `audioManager(_:didUpdate:)` method.
    if !isTapping {
      let audioFormat = audioEngine?.inputNode.outputFormat(forBus: Configuration.audioBus)
      audioEngine?.inputNode.installTap(
        onBus: Configuration.audioBus,
        bufferSize: Configuration.bufferSize,
        format: audioFormat
      ) { [weak self] buffer, _ in
        self?.bufferProcessingQueue.async { [weak self] in
          guard let self else { return }
          Task {
            await self.delegate?.audioManager(self, didUpdate: buffer)
          }
        }
      }
      isTapping = true
    }

    audioEngine?.prepare()
    do {
      try audioEngine?.start()
    } catch {
      delegate?.audioManager(self, didEncounterError: AudioManagerError.audioEngineStartingFailed(error: error))
    }
  }

  /// Stops listening for audio input and cleans up the associated resources.
  ///
  /// This method should be called when you no longer need to listen for audio input, to free up
  /// system resources.
  func stopAndClean() {
    if isListening {
      audioEngine?.inputNode.removeTap(onBus: Configuration.audioBus)
      isTapping = false
      audioEngine?.stop()
      audioEngine?.reset()
    }
  }

  // MARK: - Deinitializer

  /// Deinitializer for `AudioManager`.
  ///
  /// Ensures that audio listening is stopped and all resources are freed when the `AudioManager`
  /// object is deallocated.
  deinit {
    stopAndClean()
  }
}
