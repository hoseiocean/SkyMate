//
//  Localizer.swift
//  SkyMate
//
//  Created by Thomas Heinis on 28/06/2023.
//

import Foundation

enum AvailableLanguage: String, CaseIterable {
  case english = "en"
  case french = "fr"
  case spanish = "es"

  static func language(forKey key: String) -> AvailableLanguage {
    AvailableLanguage(rawValue: key) ?? .english
  }
}

class Localizer {
  var preferredLanguage: String {
    let languageKey = UserDefaults.standard.string(forKey: Constant.Key.preferredLanguageKey) ?? String()
    return AvailableLanguage.language(forKey: languageKey).rawValue
  }

  func localize(_ key: String) -> String {
    guard
      let path = Bundle.main.path(forResource: preferredLanguage, ofType: Constant.FileType.localizedProject),
      let bundle = Bundle(path: path)
    else {
      return key
    }

    return NSLocalizedString(key, bundle: bundle, comment: Constant.Character.nothing)
  }

  static func switchToLanguage(_ language: AvailableLanguage) {
    UserDefaults.standard.set([language.rawValue], forKey: Constant.Key.preferredLanguageKey)
    UserDefaults.standard.synchronize()
  }
}
