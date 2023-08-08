//
//  SupportedLanguage.swift
//  SkyMate
//
//  Created by Thomas Heinis on 13/07/2023.
//

import Foundation

/// SupportedLanguage is an enumeration of supported languages. Conforms to the `RawRepresentable`
/// protocol and provides raw string values that match the ISO 639-1 language codes.
enum SupportedLanguage: String, CaseIterable {
  case dummish = "zh"
  case english = "en"
  case french = "fr"
  case spanish = "es"

  /// Provides the default language.
  ///
  /// - Returns: The current language of the device if it is supported. Otherwise, it returns
  /// English as a default language.
  static var defaultLanguage: SupportedLanguage {
    if let appLanguage = UserDefaults.standard.string(forKey: Const.Key.appLanguage),
       let defaultLanguage = SupportedLanguage(rawValue: appLanguage) {
      return defaultLanguage
    }

    if let languageCode = Locale.current.languageCode,
       let defaultLanguage = SupportedLanguage(rawValue: languageCode) {
      return defaultLanguage
    }

    return .english
  }

  /// Provides a `Locale` instance corresponding to the supported language.
  ///
  /// This computed property creates a new `Locale` instance using the raw value of the
  /// `SupportedLanguage` as the locale identifier. `Locale` instances represent cultural
  /// preferences that might require specific handling for your app’s content.
  ///
  /// For example, use this property to format a date string or a number in a way that
  /// conforms to the user’s language and region.
  ///
  /// - Returns: A `Locale` instance that matches the supported language.
  var locale: Locale {
    Locale(identifier: self.rawValue)
  }
}
