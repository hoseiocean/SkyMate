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
    return Constant.FileName.answers
  }
}
extension SMLetter: SMTermProtocol {
  static var resourceName: String {
    return Constant.FileName.letters
  }
}

extension SMCommand: SMTermProtocol {
  static var resourceName: String {
    return Constant.FileName.commands
  }
}

/// A manager class that handles the loading and management of the dictionary of terms.
final class DictionaryManager {
  
  // MARK: - Private Properties
  
  private enum Error: Swift.Error {
    case fileNotFound(file: String)
    case fileReadError(file: String)
  }
  
  // MARK: - Public Properties
  
  /// Mapping of homophones to terms. This is used to interpret transcriptions.
  let homophoneToSMTermDictionary: HomophoneToSMTermDictionary
  
  /// An array of normalized keys from the homophone to term dictionary.
  var normalizedKeys: [String] {
    Array(homophoneToSMTermDictionary.keys).map { $0.normalized }
  }
  
  /// The type of term for this dictionary manager. Used for finding the appropriate terms in transcriptions.
  var termType: any SMTermProtocol.Type
  
  // MARK: - Initialization
  
  /// Initializes a new instance of the `DictionaryManager` class with the specified term type.
  /// - Parameter termType: The type of term for this dictionary manager. Defaults to `SMCommand.self`.
  /// - Throws: An error of type `Error` if the dictionary loading fails.
  init<T: SMTermProtocol>(for termType: T.Type = SMCommand.self) throws {
    self.termType = termType
    homophoneToSMTermDictionary = try DictionaryManager.loadDictionaryFile(for: termType)
  }
  
  // MARK: - Public Methods
  
  /// Loads the dictionary from the resource file for the specified term type.
  /// - Parameter termType: The type of term for which to load the dictionary.
  /// - Returns: The loaded dictionary as a `HomophoneToSMTermDictionary`.
  /// - Throws: An error of type `Error` if the dictionary file cannot be found or read.
  static func loadDictionaryFile<T: SMTermProtocol>(for termType: T.Type) throws -> HomophoneToSMTermDictionary {
    let resource = termType.resourceName
    
    guard let path = Bundle.main.path(forResource: resource, ofType: Constant.FileType.strings) else {
      throw Error.fileNotFound(file: resource + Constant.Character.point + Constant.FileType.strings)
    }
    
    guard let dictionary = NSDictionary(contentsOfFile: path) as? HomophoneToSMTermDictionary else {
      throw Error.fileReadError(file: path)
    }
    
    return dictionary
  }
  
}
