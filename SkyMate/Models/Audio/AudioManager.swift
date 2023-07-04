//
//  AudioManager.swift
//  SkyMate
//
//  Created by Thomas Heinis on 15/06/2023.
//

import AVFAudio

protocol AudioManagerDelegate: AnyObject {
  func audioManager(_ audioManager: AudioManager, didUpdate buffer: AVAudioPCMBuffer)
}

final class AudioManager {

  // MARK: - Properties

  private struct Configuration {
    // The audio bus number used for the audio input.
    static let audioBus: AVAudioNodeBus = 0
    // The size of the audio buffer. 1024 is a common choice for audio processing applications.
    static let bufferSize: UInt32 = 1024
  }

  private enum Error: Swift.Error {
    // Error thrown when starting the audio engine fails.
    case audioEngineStartingFailed(error: Swift.Error)
    // Error thrown when setting up the audio session fails.
    case audioSessionFailed(error: Swift.Error)
  }

  private let audioEngine = AVAudioEngine()

  private var isTapping: Bool = false

  /// The delegate object will receive audio buffer data.
  /// It is declared as weak to prevent reference cycles.
  weak var delegate: AudioManagerDelegate?

  /// A boolean variable to know whether the engine is running or not.
  var isListening: Bool {
    audioEngine.isRunning
  }

  // MARK: - Public Methods

  /// Starts if is not listening yet then listen for audio input.
  /// - Throws: `Error.audioSessionFailed` if there is an issue with setting up the audio session,
  ///           `Error.audioEngineStartingFailed` if there is an issue starting the audio engine.
  func listen() throws {
    guard !isListening else { return }

    let audioSession = AVAudioSession.sharedInstance()
    do {
      try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
      try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
    } catch {
      throw Error.audioSessionFailed(error: error)
    }

    // Set the audio format to the output format of the input node.
    // This ensures that the audio format is compatible with the input node.
    let audioFormat = audioEngine.inputNode.outputFormat(forBus: Configuration.audioBus)

    // Install an audio tap on the input node. The tap will call the delegate with the audio buffer data
    // each time the specified buffer size of data is available. The delegate method is called on the main
    // queue to ensure that UI updates based on the audio data are performed on the main thread.
    if !isTapping {
      audioEngine.inputNode.installTap(
        onBus: Configuration.audioBus,
        bufferSize: Configuration.bufferSize,
        format: audioFormat
      ) { [weak self] buffer, _ in
        guard let self else { return }
        DispatchQueue.main.async {
          self.delegate?.audioManager(self, didUpdate: buffer)
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

  /// Stops listening and cleans resources for audio input.
  func stopAndClean() {
    if isListening {
      audioEngine.inputNode.removeTap(onBus: Configuration.audioBus)
      isTapping = false
      audioEngine.stop()
      audioEngine.reset()
    }
  }

  // Deinitializer for AudioManager. Ensures that audio listening is stopped
  // and all resources are freed when the AudioManager object is deallocated.
  deinit {
    stopAndClean()
  }
}
