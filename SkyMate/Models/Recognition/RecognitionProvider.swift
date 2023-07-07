//
//  RecognitionManagerProvider.swift
//  SkyMate
//
//  Created by Thomas Heinis on 22/06/2023.
//

import Speech

/// `RecognitionProvider` is a provider class that manages the speech recognition process using a `RecognitionManager`.
/// This class will initialize and maintain an instance of `RecognitionManager`, restart it if necessary, and handle
/// any errors encountered during these operations.
final class RecognitionProvider: ObservableObject {

  // MARK: - Enumerations

  private enum Error: String, Localizable {
    case speechRecognitionFailedToStart
    case speechRecognitionNotAvailable
  }

  // MARK: - Properties

  // A flag to check if a restart attempt has already been made.
  // This is to prevent repeated attempts to restart the recognition manager.
  private var hasRestartAttempted = false

  /// The `RecognitionManager` instance responsible for managing the speech recognition process.
  @Published var recognitionManager: RecognitionManager?

  // MARK: - Initialization

  /// Initializes the recognition provider by creating a `RecognitionManager`.
  init() {
    createRecognitionManager()
  }

  // MARK: - Private Methods

  private func createRecognitionManager() {
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
        handleError(error: Error.speechRecognitionNotAvailable)
      }
    } catch {
      handleError(error: Error.speechRecognitionFailedToStart)
    }
  }

  private func handleError(error: Error) {
    CommandProcessor.shared.addTerm(error.localized)
    print(error.rawValue, Constant.Identifier.locale)
  }
}

// MARK: - RecognitionManagerDelegate Conformance

extension RecognitionProvider: RecognitionManagerDelegate {

  /// Handles the scenario when the recognition manager restarts successfully.
  ///
  /// - Parameter manager: The recognition manager instance.
  func recognitionManagerDidRestartSuccessfully(_ manager: RecognitionManager) {
    hasRestartAttempted = false
  }

  /// Handles the scenario when the recognition manager fails to restart the recognition task.
  ///
  /// - Parameter manager: The recognition manager instance.
  func recognitionManagerFailedToRestart(_ manager: RecognitionManager) {
    guard !hasRestartAttempted else { return }
    hasRestartAttempted = true
    DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
      self?.createRecognitionManager()
    }
  }
}
