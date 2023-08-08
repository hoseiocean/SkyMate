//
//  RecognitionManagerProvider.swift
//  SkyMate
//
//  Created by Thomas Heinis on 22/06/2023.
//

import Combine
import Speech
import SwiftUI

// MARK: - RecognitionProviderError

/// Enum that defines the possible errors that can be thrown by the `RecognitionProvider`.
enum RecognitionProviderError: String, Localizable, Error {
  case noRecognitonManager
  case notAllPermissionsGranted
  case speechRecognitionFailedToStart
  case speechRecognitionNotAvailable
}

// MARK: - RecognitionProviderOperatingMode

/// Enum that defines the possible operating modes of the `RecognitionProvider`.
enum RecognitionProviderOperatingMode {
  case learning
  case normal
}

// MARK: - RecognitionProvider

/// A class that provides a service for recognizing voice commands.
final class RecognitionProvider: ObservableObject {

  // MARK: - Config

  private struct Config {
    static let nanosecondsToSleep: UInt64 = 2 * 1_000_000_000
    static let operatingMode: RecognitionProviderOperatingMode = .normal
  }

  // MARK: - Private Properties

  private let languageManager = LanguageManager.shared

  private var _recognitionManagerStateSubscription: AnyCancellable?
  private var areDictionariesLoaded = false
  private var hasCardBeenGenerated = false
  private var hasRestartAttempted = false

  // MARK: - Recognition Manager

  /// The manager responsible for the recognition tasks.
  var recognitionManager: RecognitionManager? {
    didSet {
      guard let manager = recognitionManager else { return }
      _recognitionManagerStateSubscription = manager.$state
        .receive(on: DispatchQueue.main)
        .sink { [weak self] newState in
          guard let self else { return }
          self.recognitionManagerState = newState
        }
    }
  }

  // MARK: - Recognition Manager State

  /// The current state of the recognition manager.
  @Published var recognitionManagerState: RecognitionManagerState = .idle

  // MARK: - Shared Instance

  /// Shared instance of `RecognitionProvider` for singleton usage.
  static let shared = RecognitionProvider()

  // MARK: - Initialization

  private init() {
    NotificationCenter.default.addObserver(self, selector: #selector(languageDidChange), name: .languageDidChange, object: nil)
  }

  /// Function called when the language settings did change.
  @objc func languageDidChange() {
    Task {
      await self.start()
    }
  }

  // MARK: - Private Methods

  private func handleError(error: RecognitionProviderError) {
    guard areDictionariesLoaded else { return }
    let cardContent = String(describing: error)
    let cardTitle = "RecognitionProvider"
    let card = Card(title: cardTitle, content: cardContent)
    CarrouselViewModel.shared.addCard(card)
  }
  
  private func getPermissions() async  -> Bool {
    let permissionManager = PermissionManager()
    let allPermissionsGranted = await permissionManager.requestAllPermissions()
    if allPermissionsGranted {
      return true
    } else {
      handleError(error: RecognitionProviderError.notAllPermissionsGranted)
      return false
    }
  }

  // MARK: - Public Methods

  /// Creates a new instance of the `RecognitionManager`.
  func createRecognitionManager() async  {
    areDictionariesLoaded = loadDictionaries()
    guard
      areDictionariesLoaded,
      await getPermissions(),
      let speechRecognizer = SFSpeechRecognizer(locale: languageManager.currentLanguage.value.locale)
    else {
      handleError(error: RecognitionProviderError.speechRecognitionNotAvailable)
      return
    }

    do {
      let audioManager = AudioManager()
      let transcriptionProcessor = TranscriptionProcessor(operatingMode: Config.operatingMode)
      recognitionManager = try RecognitionManager(
        audioManager: audioManager,
        speechRecognizer: speechRecognizer,
        transcriptionProcessor: transcriptionProcessor,
        operatingMode: Config.operatingMode
      )
      recognitionManager?.delegate = self
      try self.startListening()
    } catch {
      handleError(error: RecognitionProviderError.speechRecognitionFailedToStart)
    }
  }

  /// Checks if the recognition manager is currently listening.
  func isListening() -> Bool {
    guard let recognitionManager else { return false }
    if case .listening = recognitionManager.state {
      return true
    }
    return false
  }

  /// Loads dictionaries needed for operation.
  func loadDictionaries() -> Bool {
    for type in SMTermType.allCases {
      do {
        _ = try DictionaryManager.shared.content(forSMTermType: type, inLanguage: LanguageManager.shared.currentLanguage.value)
      } catch {
        DispatchQueue.main.sync {
          self.hasCardBeenGenerated = true
          let language = self.languageManager.currentLanguage.value
          let languageStringKey = "RecognitionProviderText_" + String(describing: language)
          let languageName = self.languageManager.localizedString(forKey: languageStringKey, inLanguage: language)
          let contentString = String(format: RecognitionProviderText.missingDictionariesContent.localized, languageName)
          let card = Card(
            title: RecognitionProviderText.missingDictionariesTitle.localized,
            content: contentString
          )
          CarrouselViewModel.shared.addCard(card)
        }

        // The language stored in UserDefaults has priority over all others, thus if
        // a dictionary for this language is missing, UserDefaults’ must be deleted.
        if let _ = UserDefaults.standard.string(forKey: Const.Key.appLanguage) {
          UserDefaults.standard.removeObject(forKey: Const.Key.appLanguage)
        }

        let previousLanguage = languageManager.previousLanguage ?? .defaultLanguage
        languageManager.setLanguage(previousLanguage)
        return false
      }
    }
    return true
  }

  /// Starts the recognition manager.
  func start() async  {
    recognitionManager?.stopAndClean()
    recognitionManager = nil
    await createRecognitionManager()
  }

  /// Starts the listening process of the recognition manager.
  func startListening() throws {
    guard let recognitionManager else { throw RecognitionProviderError.noRecognitonManager }
    recognitionManager.listen()
  }

  /// Stops the listening process of the recognition manager.
  func stopListening() throws {
    guard let recognitionManager else { throw RecognitionProviderError.noRecognitonManager }
    recognitionManager.stopAndClean()
  }

  // MARK: - Deinitialization

  deinit {
    recognitionManager = nil
    NotificationCenter.default.removeObserver(self, name: .languageDidChange, object: nil)
  }
}

// MARK: - RecognitionManagerDelegate

/// Extension of `RecognitionProvider` to conform to `RecognitionManagerDelegate` protocol.
extension RecognitionProvider: RecognitionManagerDelegate {

  func recognitionManagerDidStartSuccessfully(_ manager: RecognitionManager) {
    guard areDictionariesLoaded && !hasCardBeenGenerated else { hasCardBeenGenerated = false; return }
    hasRestartAttempted = false
    let card = Card(
      title: RecognitionProviderText.instructionManualTitle.localized,
      content: RecognitionProviderText.instructionManualContent.localized
    )
    CarrouselViewModel.shared.addCard(card)
  }
  
  func recognitionManagerFailedToRestart(_ manager: RecognitionManager) {
    guard !hasRestartAttempted else { return }
    hasRestartAttempted = true
    Task {
      do {
        try await Task.sleep(nanoseconds: Config.nanosecondsToSleep)
        await self.createRecognitionManager()
      } catch {
        let card = Card(
          title: RecognitionProviderText.failedTitle.localized,
          content: RecognitionProviderText.failedContent.localized
        )
        CarrouselViewModel.shared.addCard(card)
      }
    }
  }
}
