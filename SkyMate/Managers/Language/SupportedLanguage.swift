//
//  SupportedLanguage.swift
//  SkyMate
//
//  Created by Thomas Heinis on 13/07/2023.
//

import Foundation

/// SupportedLanguage is an enumeration of supported languages. Conforms to
/// the `RawRepresentable` protocol and provides raw string values that match
/// the ISO 639-1 language codes.
enum SupportedLanguage: String, CaseIterable {
  case english = "en"
  case french = "fr"
  case spanish = "es"

  /// Provides the default language.
  ///
  /// - Returns: The current language of the device if it is supported.
  /// Otherwise, it returns English as a default language.
  static var defaultLanguage: SupportedLanguage {
    guard let languageCode = Locale.current.languageCode else {
      return .english
    }
    return SupportedLanguage(rawValue: languageCode) ?? .english
  }
}
