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

  enum File {
    enum Extension {
      static let strings = "strings"
    }
    static let answers = "Answers"
    static let commands = "Commands"
    static let letters = "Letters"
  }

  enum Identifier {
    static let locale = Locale(identifier: languageId)

    static var languageCode: String {
      if #available(iOS 16, *) {
        guard let languageCode = Locale.current.language.languageCode else { return "en" }
        return languageCode.identifier
      } else {
        guard let languageCode = Locale.current.languageCode else { return "en" }
        return languageCode
      }
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

  enum Name {
    static let queueLock = "QueueLock"
  }

  enum Symbol {
    static let globe = "globe"
    static let keyboard = "keyboard"
    static let microphone = "mic"
  }

}
