//
//  LanguageManager.swift
//  SkyMate
//
//  Created by Thomas Heinis on 12/07/2023.
//

import Combine
import Foundation

/// This class provides an interface to manage supported languages in the app.
final class LanguageManager {
  
  // MARK: - Properties
  
  private let userSettings = UserDefaults.standard
  
  private var cachedStrings: [String: String] = [:]
  private var cachedStringsBundle: Bundle?
  
  /// Current language of the app. It publishes changes to the language setting.
  let currentLanguage = CurrentValueSubject<SupportedLanguage, Never>(.defaultLanguage)
  
  /// Singleton instance of LanguageManager.
  static let shared = LanguageManager()
  
  // MARK: - Initializer
  
  private init() {
    let languageCode = userSettings.string(forKey: Const.Key.appLanguage) ?? SupportedLanguage.defaultLanguage.rawValue
    currentLanguage.value = SupportedLanguage(rawValue: languageCode) ?? SupportedLanguage.defaultLanguage
  }
  
  // MARK: - Cache Management
  
  private func clearCache() {
    cachedStrings.removeAll()
    cachedStringsBundle = nil
  }
  
  private func languageBundle(for language: SupportedLanguage) -> Bundle? {
    // Don’t waste time
    if let cachedStringsBundle {
      return cachedStringsBundle
    }

    // Let’s lose some only if necessary
    let languageFile = language.rawValue
    let localizedProjectFile = Const.File.Extension.localizedProject
    
    guard
      let bundlePath = Bundle.main.path(forResource: languageFile, ofType: localizedProjectFile),
      let stringsBundle = Bundle(path: bundlePath)
    else {
      return nil
    }
    
    cachedStringsBundle = stringsBundle
    return stringsBundle
  }
  
  // MARK: - Language Management
  
  /// Returns the localized string for the given key in the specified language.
  /// The result is cached for faster access next time.
  ///
  /// - Parameters:
  ///   - stringKey: The key to find in the strings file.
  ///   - language: The language in which the string should be localized.
  /// - Returns: The localized string for the key, or `nil` if the key cannot be
  /// found.
  func localizedString(forKey stringKey: String, in language: SupportedLanguage) -> String? {
    // Don’t waste time
    if let cachedString = cachedStrings[stringKey] {
      return cachedString
    }
    
    // Let’s lose some only if necessary
    let languageBundle = languageBundle(for: language) ?? Bundle.main
    let noComments = Const.Char.none
    let localizedString = NSLocalizedString(stringKey, bundle: languageBundle, comment: noComments)

    cachedStrings[stringKey] = localizedString
    
    return localizedString
  }
  
  /// Sets the language of the app to the given language and saves it
  /// in the user settings. This also clears the cache to ensure that
  /// the new language is used for future localization.
  ///
  /// - Parameter newLanguage: The new language to set for the app.
  func setLanguage(_ newLanguage: SupportedLanguage) {
    clearCache()
    currentLanguage.value = newLanguage
    userSettings.set(newLanguage.rawValue, forKey: Const.Key.appLanguage)
  }
  
  // MARK: - Deinit
  
  deinit {
    clearCache()
  }
}
