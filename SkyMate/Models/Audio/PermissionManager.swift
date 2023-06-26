//
//  PermissionManager.swift
//  SkyMate
//
//  Created by Thomas Heinis on 15/06/2023.
//

import Speech

final class PermissionManager {

  // MARK: - Properties

  /// Indicates whether audio source permission is granted.
  var hasAudioSource: Bool {
    AVAudioSession.sharedInstance().recordPermission == .granted
  }

  /// Indicates whether speech recognition permission is granted.
  var hasSpeechRecognitionPermission: Bool {
    SFSpeechRecognizer.authorizationStatus() == .authorized
  }

  // MARK: - Public Methods

  ///
  ///
  func requestAllPermissions(completion: @escaping (Bool) -> Void) {
    let group = DispatchGroup()

    var hasAudioPermission = hasAudioSource
    var hasSpeechPermission = hasSpeechRecognitionPermission

    if !hasAudioPermission {
      group.enter()
      requestAudioPermission { granted in
        hasAudioPermission = granted
        group.leave()
      }
    }

    if !hasSpeechPermission {
      group.enter()
      requestSpeechRecognitionPermission { granted in
        hasSpeechPermission = granted
        group.leave()
      }
    }

    group.notify(queue: .main) {
      completion(hasAudioPermission && hasSpeechPermission)
    }
  }

  /// Requests speech recognition permission.
  /// - Parameter completion: A closure to be called with the authorization status as a parameter.
  func requestSpeechRecognitionPermission(completion: @escaping (Bool) -> Void) {
    SFSpeechRecognizer.requestAuthorization { status in
      DispatchQueue.main.async {
        completion(status == .authorized)
      }
    }
  }

  /// Requests audio permission.
  /// - Parameter completion: A closure to be called with the permission status as a parameter.
  func requestAudioPermission(completion: @escaping (Bool) -> Void) {
    AVAudioSession.sharedInstance().requestRecordPermission { granted in
      DispatchQueue.main.async {
        completion(granted)
      }
    }
  }

}
