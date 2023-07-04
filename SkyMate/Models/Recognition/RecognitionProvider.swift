//
//  RecognitionManagerProvider.swift
//  SkyMate
//
//  Created by Thomas Heinis on 22/06/2023.
//

import Speech

/// A provider class that manages the speech recognition process using a `RecognitionManager`.
final class RecognitionProvider: ObservableObject {

  // MARK: - Properties

  /// The recognition manager responsible for managing the speech recognition process.
  @Published var recognitionManager: RecognitionManager?

  // MARK: - Initializer

  /// Initializes the recognition provider.
  init() {
    do {
      if let speechRecognizer = SFSpeechRecognizer(locale: Constant.Identifier.locale) {
        let permissionManager = PermissionManager()
        let audioManager = AudioManager()
        let segmentsQueue = try TranscriptionSegmentQueue()

        // Initialize the recognition manager with the necessary dependencies
        recognitionManager = try RecognitionManager(
          audioManager: audioManager,
          speechRecognizer: speechRecognizer,
          segmentsQueue: segmentsQueue)
        recognitionManager?.delegate = self

        // Request permissions from the user
        permissionManager.requestAllPermissions { [weak self] allPermissionsGranted in
          guard allPermissionsGranted else {
            // TODO: Handle the case where not all permissions are granted.
            return
          }

          // Start listening for speech recognition
          self?.recognitionManager?.listen()
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
  /// Called when the recognition manager fails to restart the recognition task.
  ///
  /// - Parameter manager: The recognition manager instance.
  func recognitionManagerFailedToRestart(_ manager: RecognitionManager) {
    // TODO: Handle the case where recognition failed to restart.
    // This could involve creating a new RecognitionManager instance or handling the situation in another way.
    print("RecognitionManager failed to restart")
  }
}
