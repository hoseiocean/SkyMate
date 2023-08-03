//
//  DictionaryManager.swift
//  SkyMate
//
//  Created by Thomas Heinis on 30/05/2023.
//

import Foundation

// A protocol defining methods for managing a dictionary of SM Terms
protocol DictionaryManaging {

  /// Fetches a term from the dictionaries of all term types based on the input key string.
  ///
  /// - Parameters:
  ///   - keyString: The key to search for within the dictionary keys.
  ///
  /// - Returns: A tuple containing the corresponding value and its term type if a matching key is
  ///   found; otherwise, `nil`.
  ///
  /// - Throws: Throws a `DictionaryError.invalidDictionaryContent` error if the dictionary content
  /// is not valid.
  func fetchTerm(forKey keyString: String) throws -> (any SMTerm)?

  /// Attempts to find a term in dictionaries of specified term types based on the input key
  /// string. Unlike a typical dictionary search, this function looks for the presence of the key
  /// string within the dictionary keys, allowing for inexact matching. This is used to facilitate
  /// language handling where the input key might not be an exact match.
  ///
  /// - Parameters:
  ///   - keyString: The key to search for within the dictionary keys.
  ///   - termTypes: The types of terms to be searched. The function will search across all given
  ///   term types to the first occurrence found.
  ///
  /// - Returns: A tuple containing the corresponding value and its term type if a matching key is
  ///   found; otherwise, `nil`.
  ///
  /// - Throws: Throws a `DictionaryError.invalidDictionaryContent` error if the dictionary content
  /// is not valid.
  func fetchTerm(forKey keyString: String, ofExpectedTypes termTypes: [SMTermType]) throws -> (any SMTerm)?

  /// Attempts to find a term in a dictionary based on the input key string.
  /// Unlike a typical dictionary search, this function looks for the presence of the key string
  /// within the dictionary keys, allowing for inexact matching. This is used to facilitate
  /// language handling where the input key might not be an exact match.
  ///
  /// - Parameters:
  ///   - keyString: The key to search for within the dictionary keys.
  ///   - termType: The type of term being searched.
  ///
  /// - Returns: The corresponding value if a matching key is found; otherwise, `nil`.
  ///
  /// - Throws: Throws a `DictionaryError.invalidDictionaryContent` error if the dictionary content
  /// is not valid.
  func fetchTerm(forKey keyString: String, ofType termType: SMTermType) throws -> (any SMTerm)?
}

/// A dictionary that maps homophone strings to SM term strings.
typealias HomophonesDictionary = [String: String]

/// An enumeration of possible errors that can be thrown when dealing with dictionaries.
enum DictionaryManagerError: Error {
  case dictionaryNotFound
  case invalidDictionaryContent
}

/// This class provides methods to manage language dictionaries in the application.
final class DictionaryManager {

  // MARK: - Properties

  private let languageManager = LanguageManager.shared

  private var cachedDictionaries: [SMTermType: (language: SupportedLanguage, content: HomophonesDictionary)] = [:]

  /// The shared singleton instance of the DictionaryManager.
  static let shared = DictionaryManager()

  // MARK: - Initializer

  private init() {
    NotificationCenter.default.addObserver(self, selector: #selector(languageDidChange), name: .languageDidChange, object: nil)
  }

  // MARK: - Cache Management

  private func clearCache(includingCurrentLanguage: Bool = true) {
    if includingCurrentLanguage {
      cachedDictionaries.removeAll()
    } else {
      let currentLanguage = LanguageManager.shared.currentLanguage.value
      cachedDictionaries = cachedDictionaries.filter { $0.value.language == currentLanguage }
    }
  }

  @objc func languageDidChange() {
    clearCache()
  }

  // MARK: - Dictionary Management

  /// Returns the dictionary content for the given term type in the specified language.
  ///
  /// - Parameters:
  ///   - termType: The type of terms to return the dictionary for.
  ///   - language: The language of the dictionary. The default value is the current language
  ///   of the app.
  /// - Returns: The dictionary of homophones to SM terms.
  /// - Throws: Throws `DictionaryManagerError.dictionaryNotFound` or `DictionaryManagerError.invalidDictionaryContent`
  ///   if the dictionary could not be found or if its content is invalid.
  func content(forSMTermType termType: SMTermType, inLanguage language: SupportedLanguage = LanguageManager.shared.currentLanguage.value) throws -> HomophonesDictionary? {

    // Don’t waste time if we already have the requested dictionary!
    if let cachedDictionary = cachedDictionaries[termType], cachedDictionary.language == language {
      return cachedDictionary.content
    }

    // Let’s lose some only if we need to load this dictionary…
    let languageBundle = languageManager.languageBundle(for: language) ?? Bundle.main
    let fileName = termType.type.resourceName
    let stringsFile = Const.File.Extension.strings
    let bundlePath = languageBundle.path(forResource: fileName, ofType: stringsFile)

    guard let bundlePath else { throw DictionaryManagerError.dictionaryNotFound }

    guard
      let dictionaryContent = NSDictionary(contentsOfFile: bundlePath) as? HomophonesDictionary,
      !dictionaryContent.isEmpty
    else {
      throw DictionaryManagerError.invalidDictionaryContent
    }

    // Next time, the dictionary will already be loaded for this language.
    clearCache(includingCurrentLanguage: false)
    cachedDictionaries[termType] = (language, dictionaryContent)
    return dictionaryContent
  }

  /// Searches for a term in dictionaries of specified term types based on the input key string.
  ///
  /// - Parameters:
  ///   - keyString: The key to search for within the dictionary keys.
  ///   - termTypes: The types of terms to be searched.
  ///   - language: The language in which to perform the search. Defaults to the current language
  ///   used by the `LanguageManager`.
  ///
  /// - Returns: An `SMTerm` instance if a matching key is found; otherwise, `nil`.
  ///
  /// - Throws: Throws `DictionaryManagerError.invalidDictionaryContent` error if the dictionary
  /// content is not valid.
  func term(forKey keyString: String, ofExpectedTypes termTypes: [SMTermType], inLanguage language: SupportedLanguage = LanguageManager.shared.currentLanguage.value) throws -> (any SMTerm)? {
    for type in termTypes {
      if let term = try term(forKey: keyString, ofType: type) {
        return term
      }
    }
    return nil
  }

  /// Searches for a term in a dictionary of a specified term type based on the input key string.
  ///
  /// - Parameters:
  ///   - keyString: The key to search for within the dictionary keys.
  ///   - termType: The type of term being searched.
  ///   - language: The language in which to perform the search. Defaults to the current language
  ///   used by the `LanguageManager`.
  ///
  /// - Returns: An `SMTerm` instance if a matching key is found; otherwise, `nil`.
  ///
  /// - Throws: Throws `DictionaryManagerError.invalidDictionaryContent` error if the dictionary
  /// content is not valid.
  func term(forKey keyString: String, ofType termType: SMTermType, inLanguage language: SupportedLanguage = LanguageManager.shared.currentLanguage.value) throws -> (any SMTerm)? {

    // Normalize the key string to ensure consistent matching
    let searchedKey = keyString.normalized

    if let dictionary = try content(forSMTermType: termType, inLanguage: language),
       let match = dictionary.first(where: { searchedKey.hasSuffix($0.key.normalized) }) {

      switch termType {
      case .answer:
        if let answer = SMAnswer(rawValue: match.value) {
          return answer
        }
      case .command:
        if let command = SMCommand(rawValue: match.value) {
          return command
        }
      case .letter:
        if let letter = SMLetter(rawValue: match.value) {
          return letter
        }
      }
    }

    return nil
  }

  /// Searches for a term in the dictionaries of all term types based on the input key string.
  ///
  /// - Parameters:
  ///   - keyString: The key to search for within the dictionary keys.
  ///   - language: The language in which to perform the search. Defaults to the current language
  ///   used by the `LanguageManager`.
  ///
  /// - Returns: An `SMTerm` instance if a matching key is found; otherwise, `nil`.
  ///
  /// - Throws: Throws `DictionaryManagerError.invalidDictionaryContent` error if the dictionary
  /// content is not valid.
  func term(forKey keyString: String, inLanguage language: SupportedLanguage = LanguageManager.shared.currentLanguage.value) throws -> (any SMTerm)? {
    for type in SMTermType.allCases {
      if let term = try term(forKey: keyString, ofType: type) {
        return term
      }
    }
    return nil
  }

  // MARK: - Deinit

  /// This method is called when the instance is deallocated.
  /// It is responsible for cleaning up and clearing any cached data.
  deinit {
    clearCache()
  }
}

extension DictionaryManager: DictionaryManaging {
  func fetchTerm(forKey keyString: String) throws -> (any SMTerm)? {
    return try term(forKey: keyString)
  }

  func fetchTerm(forKey keyString: String, ofExpectedTypes termTypes: [SMTermType]) throws -> (any SMTerm)? {
    return try term(forKey: keyString, ofExpectedTypes: termTypes)
  }

  func fetchTerm(forKey keyString: String, ofType termType: SMTermType) throws -> (any SMTerm)? {
    return try term(forKey: keyString, ofType: termType)
  }
}
