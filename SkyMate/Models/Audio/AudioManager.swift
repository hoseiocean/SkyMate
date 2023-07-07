//
//  AudioManager.swift
//  SkyMate
//
//  Created by Thomas Heinis on 15/06/2023.
//

import AVFAudio

/// The `AudioManagerDelegate` protocol defines methods that an object may implement to receive audio buffer updates from an `AudioManager`.
protocol AudioManagerDelegate: AnyObject {
  /// This method is called whenever the `AudioManager` receives a new audio buffer.
  ///
  /// - Parameters:
  ///   - audioManager: The `AudioManager` that is sending the buffer.
  ///   - buffer: The new audio buffer.
  func audioManager(_ audioManager: AudioManager, didUpdate buffer: AVAudioPCMBuffer) async
}

final class AudioManager {

  // MARK: - Properties

  private struct Configuration {
    static let audioBus: AVAudioNodeBus = 0
    static let bufferSize: UInt32 = 1024
  }

  private enum Error: Swift.Error {
    case audioEngineStartingFailed(error: Swift.Error)
    case audioSessionFailed(error: Swift.Error)

    var localizedDescription: String {
      switch self {
      case .audioEngineStartingFailed(let error):
        return "Failed to start the audio engine: \(error)"
      case .audioSessionFailed(let error):
        return "Failed to set up the audio session: \(error)"
      }
    }
  }

  private let audioEngine = AVAudioEngine()
  private var isTapping: Bool = false

  /// The delegate object that will receive the audio buffer updates.
  /// It is declared as `weak` to prevent reference cycles.
  weak var delegate: AudioManagerDelegate?

  /// A boolean property indicating whether the audio engine is running.
  var isListening: Bool {
    audioEngine.isRunning
  }

  // MARK: - Public Methods

  /// Starts listening for audio input if it is not already doing so.
  ///
  /// This method is marked as `async` to handle potential blocking operations without blocking the main thread,
  /// and it `throws` to propagate errors that occur during the start-up process.
  ///
  /// - Throws: `Error.audioSessionFailed` if there is an issue with setting up the audio session,
  ///           `Error.audioEngineStartingFailed` if there is an issue starting the audio engine.
  func listen() async throws {
    guard !isListening else { return }

    let audioSession = AVAudioSession.sharedInstance()
    do {
      try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
      try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
    } catch {
      throw Error.audioSessionFailed(error: error)
    }

    let audioFormat = audioEngine.inputNode.outputFormat(forBus: Configuration.audioBus)

    if !isTapping {
      audioEngine.inputNode.installTap(
        onBus: Configuration.audioBus,
        bufferSize: Configuration.bufferSize,
        format: audioFormat
      ) { [weak self] buffer, _ in
        guard let self else { return }
        Task {
          await self.delegate?.audioManager(self, didUpdate: buffer)
        }
      }
      isTapping = true
    }

    audioEngine.prepare()

    do {
      try audioEngine.start()
    } catch {
      throw Error.audioEngineStartingFailed(error: error)
    }
  }

  /// Stops listening for audio input and cleans up the associated resources.
  ///
  /// This method should be called when you no longer need to listen for audio input, to free up system resources.
  func stopAndClean() {
    if isListening {
      audioEngine.inputNode.removeTap(onBus: Configuration.audioBus)
      isTapping = false
      audioEngine.stop()
      audioEngine.reset()
    }
  }

  // MARK: - Deinitializer

  /// Deinitializer for `AudioManager`.
  ///
  /// Ensures that audio listening is stopped and all resources are freed when the `AudioManager` object is deallocated.
  deinit {
    stopAndClean()
  }
}
