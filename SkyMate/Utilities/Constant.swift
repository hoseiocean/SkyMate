//
//  Constant.swift
//  SkyMate
//
//  Created by Thomas Heinis on 11/06/2023.
//

import Foundation

struct Constant {

  enum Character {
    static let nothing = ""
    static let point = "."
    static let space = " "
    static let underscore = "_"
  }

  enum FileName {
    static let answers = "Answers"
    static let commands = "Commands"
    static let letters = "Letters"
  }

  enum FileType {
    static let localizedProject = "lproj"
    static let strings = "strings"
  }

  enum Identifier {
//    static let locale = Locale(identifier: languageId)

    static let locale = Locale(identifier: "fr-FR")

    static var languageCode: String {
//      if #available(iOS 16, *) {
//        guard let languageCode = Locale.current.language.languageCode else { return "en" }
//        return languageCode.identifier
//      } else {
//        guard let languageCode = Locale.current.languageCode else { return "en" }
//        return languageCode
//      }

//      let languageKey = UserDefaults.standard.string(forKey: Constant.Key.preferredLanguageKey) ?? String()
//      return AvailableLanguage.language(forKey: languageKey).rawValue

      return "en"
    }

    static var languageId: String {
      switch languageCode {
      case "es":
        return "es-ES"
      case "fr":
        return "fr-FR"
      default:
        return "en-US"
      }
    }
  }

  enum Key {
    static let preferredLanguageKey = "preferredLanguage"
  }

  enum Label {
    static let networkStatusQueue = "NetworkStatusMonitor"
    static let queueLock = "QueueLock"
  }

  enum Symbol {
    static let globe = "globe"
    static let language = "message"
    static let microphone = "mic"
    static let mute = "mic.slash"
    static let plane = "airplane.arrival"

    static var languageFlag: String {
      switch Identifier.languageCode {
      case "es":
        return "🇪🇸"
      case "fr":
        return "🇫🇷"
      default:
        return "🇺🇸"
      }
    }
  }

}
