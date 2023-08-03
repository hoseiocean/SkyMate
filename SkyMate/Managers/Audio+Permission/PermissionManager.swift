//
//  PermissionManager.swift
//  SkyMate
//
//  Created by Thomas Heinis on 15/06/2023.
//

import Speech

/// `PermissionManager` is a final class that is used for handling audio and speech recognition
/// permissions in the application.
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

  /// Asynchronously requests all necessary permissions for audio and speech recognition
  /// functionality. If permissions have already been granted, it doesn’t request them again.
  ///
  /// - Returns: `true` if all permissions have been granted, `false` otherwise.
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
