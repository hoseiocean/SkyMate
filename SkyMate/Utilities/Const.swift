//
//  Const.swift
//  SkyMate
//
//  Created by Thomas Heinis on 11/06/2023.
//

struct Const {

  enum Char {
    static let check = space + "✔️"
    static let none = ""
    static let point = "."
    static let space = " "
    static let underscore = "_"
  }

  enum Color {
    static let background = "Background"
    static let buttonIcon = "Button Icon"
    static let buttonBackGround = "Button Background"
    static let shadow = "Shadow"
  }

  enum File {
    enum Extension {
      static let localizedProject = "lproj"
      static let strings = "strings"
    }

    enum Name {
      static let answers = "Answers"
      static let command = "Commands"
      static let letters = "Letters"
    }
  }

  enum Key {
    static let appLanguage = "appLanguage"
  }

  enum Label {
    static let networkStatusQueue = "NetworkStatusMonitor"
    static let queueLock = "QueueLock"
  }

  enum Name {
    static let languageDidChange = "LanguageDidChange"
  }

  enum Symbol {
    static let language = "message"
    static let microphone = "mic"
    static let mute = "mic.slash"
    static let offline = "xmark.icloud.fill"
    static let online = "checkmark.icloud.fill"
    static let plane = "airplane.arrival"
  }
}
