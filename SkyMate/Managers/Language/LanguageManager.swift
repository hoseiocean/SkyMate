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

  /// Save the previous language. By default, it is nil.
  var previousLanguage: SupportedLanguage?

  // MARK: - Initializer
  
  private init() {
    let languageCode = SupportedLanguage.defaultLanguage.rawValue
    currentLanguage.value = SupportedLanguage(rawValue: languageCode) ?? SupportedLanguage.defaultLanguage
  }
  
  // MARK: - Cache Management
  
  private func clearCache() {
    cachedStrings.removeAll()
    cachedStringsBundle = nil
  }
  
  // MARK: - Language Management

  /// This function returns the language bundle associated with the specified language.
  ///
  /// - Parameter language: The language for which to return the bundle.
  /// - Returns: The Bundle object for the specified language. This function first checks the cache
  ///   to see if the bundle for this language has already been loaded, to avoid unnecessary disk
  ///   reads. If the bundle has not yet been loaded, this function loads it from disk and stores
  ///   it in the cache for next time. If the bundle cannot be found on disk, this function returns `nil`.
  ///
  ///   Note that the returned Bundle object only contains the localized strings for the specified
  ///   language. It does not contain any classes, protocols, or other runtime information.
  func languageBundle(for language: SupportedLanguage) -> Bundle? {
    // Don’t waste time if we already have the requested bundle of Strings!
    if let cachedStringsBundle {
      return cachedStringsBundle
    }

    // Let’s lose some only if we need to load this bundle…
    let languageFile = language.rawValue
    let localizedProjectFile = Const.File.Extension.localizedProject

    guard
      let bundlePath = Bundle.main.path(forResource: languageFile, ofType: localizedProjectFile),
      let stringsBundle = Bundle(path: bundlePath)
    else {
      return nil
    }

    // Next time, the bundle of Strings will already be loaded for this language.
    cachedStringsBundle = stringsBundle
    return stringsBundle
  }

  /// Returns the localized string for the given key in the specified language.
  /// The result is cached for faster access next time.
  ///
  /// - Parameters:
  ///   - stringKey: The key to find in the strings file.
  ///   - language: The language in which the string should be localized.
  /// - Returns: The localized string for the key, or `nil` if the key cannot be
  /// found.
  func localizedString(forKey stringKey: String, in language: SupportedLanguage) -> String? {
    // Don’t waste time if we already have the requested Strings!
    if let cachedString = cachedStrings[stringKey] {
      return cachedString
    }
    
    // Let’s lose some only if we need to load these Strings…
    let languageBundle = languageBundle(for: language) ?? Bundle.main
    let noComments = Const.Char.none
    let localizedString = NSLocalizedString(stringKey, bundle: languageBundle, comment: noComments)

    // Next time, the Strings will already be loaded for this language.
    cachedStrings[stringKey] = localizedString

    return localizedString
  }
  
  /// This function changes the language used in the app.
  ///
  /// - Parameter newLanguage: The language to use in the app. This function updates the `currentLanguage`
  ///   property and saves the new language to the UserDefaults so it persists across app launches.
  ///   It then posts a `languageDidChange` notification, which other parts of the app can listen to
  ///   in order to update their UI when the language changes.
  ///
  ///   Before changing the language, this function clears the cache of loaded strings. This is because
  ///   the strings are loaded from the bundle for the current language, so when the language changes,
  ///   the cached strings are no longer valid.
  func setLanguage(_ newLanguage: SupportedLanguage) {
    clearCache()
    previousLanguage = currentLanguage.value
    currentLanguage.value = newLanguage
    userSettings.set(newLanguage.rawValue, forKey: Const.Key.appLanguage)
    NotificationCenter.default.post(name: .languageDidChange, object: nil)
  }
  
  // MARK: - Deinit
  
  deinit {
    clearCache()
  }
}
