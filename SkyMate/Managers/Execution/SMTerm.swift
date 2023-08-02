//
//  SMTerm.swift
//  SkyMate
//
//  Created by Thomas Heinis on 10/07/2023.
//

/// `SMTerm` is a protocol that requires conformance to `CaseIterable` and defines
/// a resource name for each type of term.
protocol SMTerm: CaseIterable {
  
  /// The name of the resource file that contains the term strings.
  static var resourceName: String { get }

  ///
  func handleTerm()
}

/// `SMAnswer` is an enumeration of possible answer terms in SkyMate. It conforms to the `SMTerm`
/// protocol.
enum SMAnswer: String, SMTerm {
  case cancel
  case ok

  static var resourceName: String {
    return Const.File.Name.answers
  }

  func handleTerm() {
    return
  }
}

/// `SMCommand` is an enumeration of possible command terms in SkyMate. It conforms to the `SMTerm`
/// protocol.
enum SMCommand: String, SMTerm {
  case airport
  case command
  case english
  case french
  case metar
  case microphone
  case night
  case notam
  case spanish

  static var resourceName: String {
    return Const.File.Name.command
  }

  func handleTerm() {
    switch self {
    case .airport:
      _ = AirportViewModel()
    case .command:
      _ = CommandViewModel()
    case .english:
      LanguageManager.shared.setLanguage(.english)
    case .french:
      LanguageManager.shared.setLanguage(.french)
    case .metar:
      _ = MetarViewModel()
    case .microphone:
      _ = MicrophoneViewModel()
    case .night:
      _ = NightViewModel()
    case .notam:
      _ = NotamViewModel()
    case .spanish:
      LanguageManager.shared.setLanguage(.spanish)
    }
  }
}

/// `SMLetter` is an enumeration of possible letter terms in SkyMate. It conforms to the `SMTerm`
/// protocol.
enum SMLetter: String, SMTerm {
  case alfa
  case bravo
  case charlie
  case delta
  case echo
  case foxtrot
  case golf
  case hotel
  case india
  case juliett
  case kilo
  case lima
  case mike
  case november
  case oscar
  case papa
  case quebec
  case romeo
  case sierra
  case tango
  case uniform
  case victor
  case whiskey
  case xray
  case yankee
  case zulu

  static var resourceName: String {
    return Const.File.Name.letters
  }

  func handleTerm() {
    return
  }
}
