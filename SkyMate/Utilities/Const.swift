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
    static let buttonIcon = "Button’s icon"
    static let buttonBackGround = "Button’s background"
    static let cardBackground = "Card’s background"
    static let cardText = "Card’s text"
    static let backgroundWhenRequestSuccessfullyExecuted = "Found term’s background"
    static let foregroundWhenRequestSuccesfullyExecuted = "Found term’s text"
    static let shadow = "Shadow"
    static let titleBackground = "Title’s background"
    static let titleText = "Title’s text"
    static let toggleButton = "Toggle’s button"
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

  enum Id {
    static let defaut = "default"
    static let domain = "dev.happios.SkyMate"
    static let utc = "UTC"
  }

  enum Key {
    static let appLanguage = "appLanguage"
  }

  enum Label {
    static let bufferProcessingQueue = "BufferProcessingQueue"
    static let cacheQueue = "CacheQueue"
    static let changingLanguageQueue = "ChangingLanguageQueue"
    static let localizedStringQueue = "LocalizedStringQueue"
    static let networkStatusQueue = "NetworkStatusMonitor"
    static let queueLock = "QueueLock"
  }

  enum Name {
    static let didFoundTerm = "termFounded"
    static let didProcessedTranscription = "newTranscriptionProcessed"
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
