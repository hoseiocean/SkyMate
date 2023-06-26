//
//  DictionaryManager.swift
//  SkyMate
//
//  Created by Thomas Heinis on 30/05/2023.
//

import Foundation

typealias HomophoneToSMTermDictionary = [String: String]

// MARK: - SMTerms’ Types

/// SMTermProtocol defines an interface that all terms
/// in this application should conform to.
protocol SMTermProtocol: RawRepresentable where RawValue == String {

  // All possible cases of the terms.
  static var allCases: [Self] { get }

  // Localized representation of the term.
  var localized: String { get }

  // The name of the resource file that contains the terms.
  static var resourceName: String { get }
}

enum SMAnswer: String, Localizable, CaseIterable {
  case cancel
  case ok
}

/// SMLetter and SMCommand are specific types of terms. They conform to Localizable for localization,
/// CaseIterable for being able to list all possible terms, and SMTermProtocol for getting the terms
/// from a resource file.
enum SMLetter: String, Localizable, CaseIterable {
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
}

enum SMCommand: String, Localizable, CaseIterable {
  case destination
  case night
  case metar
  case microphone
  case notam
}

// Each term type implements resourceName to specify
// the file that contains their terms.
extension SMAnswer: SMTermProtocol {
  static var resourceName: String {
    return Constant.File.answers
  }
}
extension SMLetter: SMTermProtocol {
  static var resourceName: String {
    return Constant.File.letters
  }
}

extension SMCommand: SMTermProtocol {
  static var resourceName: String {
    return Constant.File.commands
  }
}

final class DictionaryManager {

  // MARK: - Private Properties

  private enum Error: Swift.Error {
    case fileNotFound(file: String)
    case fileReadError(file: String)
  }

  // Mapping of homophones to terms. This is used to interpret transcriptions.
  let homophoneToSMTermDictionary: HomophoneToSMTermDictionary

  // MARK: - Public Properties

  var normalizedKeys: [String] {
    Array(homophoneToSMTermDictionary.keys).map { $0.normalized }
  }

  // The term type for this handler. It’s used for finding the appropriate terms in the transcriptions.
  var termType: any SMTermProtocol.Type

  // MARK: - Initialization

  /// Initialization of TermsHandler. A dictionary file for the given term type is loaded and an error
  /// is thrown if it can’t be loaded.
  init<T: SMTermProtocol>(for termType: T.Type = SMCommand.self) throws {
    self.termType = termType
    homophoneToSMTermDictionary = try DictionaryManager.loadDictionaryFile(for: termType)
  }

  // MARK: - Public Methods

  /// This method loads the dictionary from the resource file for a given term type. If the file can’t
  /// be found or loaded, it throws an error.
  static func loadDictionaryFile<T: SMTermProtocol>(for termType: T.Type) throws -> HomophoneToSMTermDictionary {
    let resource = termType.resourceName

    guard let path = Bundle.main.path(forResource: resource, ofType: Constant.File.Extension.strings) else {
      throw Error.fileNotFound(file: resource + Constant.Character.point + Constant.File.Extension.strings)
    }

    guard let dictionary = NSDictionary(contentsOfFile: path) as? HomophoneToSMTermDictionary else {
      throw Error.fileReadError(file: path)
    }

    return dictionary
  }

}
