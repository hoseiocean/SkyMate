//
//  PermissionManager.swift
//  SkyMate
//
//  Created by Thomas Heinis on 15/06/2023.
//

import Speech

final class PermissionManager {

  // MARK: - Properties

  private var hasAudioSource: Bool {
    AVAudioSession.sharedInstance().recordPermission == .granted
  }

  private var hasSpeechRecognitionPermission: Bool {
    SFSpeechRecognizer.authorizationStatus() == .authorized
  }

  // MARK: - Private Methods

  private func requestSpeechRecognitionPermission() async -> Bool {
    await withCheckedContinuation { continuation in
      SFSpeechRecognizer.requestAuthorization { status in
        continuation.resume(returning: status == .authorized)
      }
    }
  }

  private func requestAudioPermission() async -> Bool {
    return await withCheckedContinuation { continuation in
      AVAudioSession.sharedInstance().requestRecordPermission { granted in
        continuation.resume(returning: granted)
      }
    }
  }

  // MARK: - Public Methods

  /// Requests all necessary permissions (audio and speech recognition).
  ///
  /// This function is used to request all necessary permissions for audio recording and speech recognition.
  ///
  /// - Parameter completion: A closure to be called with a boolean parameter indicating whether all permissions were granted.
  func requestAllPermissions() async -> Bool {
    var hasAudioPermission = hasAudioSource
    var hasSpeechPermission = hasSpeechRecognitionPermission

    if !hasAudioPermission {
      hasAudioPermission = await requestAudioPermission()
    }

    if !hasSpeechPermission {
      hasSpeechPermission = await requestSpeechRecognitionPermission()
    }

    return hasAudioPermission && hasSpeechPermission
  }
}
