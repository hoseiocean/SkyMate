//
//  RecognitionManagerProvider.swift
//  SkyMate
//
//  Created by Thomas Heinis on 22/06/2023.
//

import Speech

class RecognitionProvider: ObservableObject {

  @Published var recognitionObserver = RecognitionObserver()
  var recognitionManager: RecognitionManager?

  init() {
    do {
      if let speechRecognizer = SFSpeechRecognizer(locale: Constant.Identifier.locale) {
        let permissionManager = PermissionManager()
        let audioManager = AudioManager()
        let segmentsQueue = try TranscriptionSegmentQueue(recognitionObserver: recognitionObserver)

        recognitionManager = try RecognitionManager(
          audioManager: audioManager,
          speechRecognizer: speechRecognizer,
          segmentsQueue: segmentsQueue,
          recognitionObserver: recognitionObserver)
        recognitionManager?.delegate = self

        permissionManager.requestAllPermissions { [weak self] allPermissionsGranted in
          guard allPermissionsGranted else {
            // TODO: Handle the case where not all permissions are granted.
            return
          }

          self?.recognitionManager?.start()
        }
      } else {
        // TODO: Add user-viewable error handling
        print("Speech recognition is not available for current locale:", Constant.Identifier.locale)
      }
    } catch {
      // TODO: Add user-viewable error handling
      print("RecognitionManager is not available:", error)
    }
  }
}

// MARK: - RecognitionManagerDelegate

extension RecognitionProvider: RecognitionManagerDelegate {
  func recognitionManagerFailedToRestart(_ manager: RecognitionManager) {
    // TODO: Handle the case where recognition failed to restart.
    // This could involve creating a new RecognitionManager instance or handling the situation in another way.
    print("RecognitionManager failed to restart")
  }
}
