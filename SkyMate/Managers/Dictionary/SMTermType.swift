//
//  SMTermType.swift
//  SkyMate
//
//  Created by Thomas Heinis on 15/07/2023.
//

/// `SMTermType` is an enumeration of possible term types in SkyMate.
/// It provides a property to map each type to its associated `SMTerm` type.
enum SMTermType: CaseIterable {
  case answer
  case command
  case letter

  /// Provides the associated `SMTerm` type for the current `SMTermType`.
  /// It allows for dynamic access to `SMTerm` conforming types.
  var type: any SMTerm.Type {
    switch self {
    case .answer:
      return SMAnswer.self
    case .command:
      return SMCommand.self
    case .letter:
      return SMLetter.self
    }
  }
}
