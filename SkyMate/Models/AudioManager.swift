//
//  AudioManager.swift
//  SkyMate
//
//  Created by Thomas Heinis on 15/06/2023.
//

import AVFAudio

protocol AudioManagerDelegate: AnyObject {
  func didReceiveAudioBuffer(_ buffer: AVAudioPCMBuffer)
}

final class AudioManager {

  // MARK: - Properties

  private struct Configuration {
    static let audioBus: AVAudioNodeBus = 0
    static let bufferSize: UInt32 = 1024
  }

  private let audioEngine = AVAudioEngine()

  weak var delegate: AudioManagerDelegate?

  var isListening: Bool {
    audioEngine.isRunning
  }

  // MARK: - Public Methods

  /// Starts listening for audio input.
  /// Throws an error if there is an issue starting the audio engine or setting up the audio session.
  func startListening() throws {
    let audioSession = AVAudioSession.sharedInstance()
    try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
    try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)

    let recordingFormat = audioEngine.inputNode.outputFormat(forBus: Configuration.audioBus)
    audioEngine.inputNode.installTap(
      onBus: Configuration.audioBus,
      bufferSize: Configuration.bufferSize,
      format: recordingFormat
    ) { [weak self] buffer, _ in
      self?.delegate?.didReceiveAudioBuffer(buffer)
    }

    audioEngine.prepare()

    do {
      try audioEngine.start()
    } catch let error {
      fatalError("Error starting AVAudioEngine: \(error)")
    }
  }

  /// Stops listening for audio input.
  func stopListening() throws {
    if isListening {
      audioEngine.inputNode.removeTap(onBus: Configuration.audioBus)
      audioEngine.stop()
      audioEngine.reset()
    }
  }

}
