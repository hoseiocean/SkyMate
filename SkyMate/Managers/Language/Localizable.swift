//
//  Localizable.swift
//  SkyMate
//
//  Created by Thomas Heinis on 13/07/2023.
//

/// A protocol that describes an entity that can be localized.
protocol Localizable {

  /// The current language of the localizable entity.
  var currentLanguage: SupportedLanguage { get }

  /// The localized version of the entity.
  var localized: String { get }
}

/// Default implementation of `Localizable` protocol for entities that conform
/// to `RawRepresentable` with `RawValue` being `String`.
extension Localizable where Self: RawRepresentable, Self.RawValue == String {

  /// By default, the `currentLanguage` property is derived from
  /// the `LanguageManager`’s `currentLanguage`.
  var currentLanguage: SupportedLanguage {
    LanguageManager.shared.currentLanguage.value
  }

  /// The `localized` property constructs a string key based on the raw value of the entity
  /// and retrieves the localized version of that string from the `LanguageManager`. If no
  /// localized version is found, the raw value is returned.
  var localized: String {
    let stringEnum = String(describing: Self.self)
    let underscore = Const.Char.underscore
    let stringCase = self.rawValue
    
    // Strings are given specific keys to make them easier to store and find.
    let stringKey = stringEnum + underscore + stringCase
    let localizedString = LanguageManager.shared.localizedString(forKey: stringKey, inLanguage: currentLanguage)
    return localizedString ?? self.rawValue
  }
}
