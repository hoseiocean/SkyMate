//
//  RecognitionHandler.swift
//  SkyMate
//
//  Created by Thomas Heinis on 18/06/2023.
//

import Foundation

// MARK: - CommandProcessing Protocol

/// `CommandProcessing` defines a protocol that requires the implementation of a method to handle
/// speech master terms (SMTerms).
protocol CommandProcessing {

  /// Handle a term derived from the `SMTerm` base class.
  /// - Parameter term: The `SMTerm` to handle.
  func handle(term: any SMTerm)
}

// MARK: - CommandProcessor

/// `CommandProcessor` is a class that conforms to `CommandProcessing` protocol.
/// It handles terms by checking if they match the expected type and if they differ from the last command.
/// If they meet both conditions, it executes the term's handler on the main queue.
final class CommandProcessor: CommandProcessing {

  // Private properties

  private var expectedType = SMCommand.self
  private var lastCommand: SMCommand?

  // Shared instance

  /// Shared instance of `CommandProcessor`, used to apply singleton pattern.
  static let shared = CommandProcessor()

  // Initializer

  private init() {}

  // MARK: Public Methods

  /// Handle an `SMTerm`.
  /// If the term is of the expected type and different from the last command, it executes the term's handler.
  /// It also logs information about the expected type, the recognized type, and the term itself.
  /// - Parameter term: The `SMTerm` to handle.
  func handle(term: any SMTerm) {
    print(Self.self, "Expected:", expectedType, "Recognized:", type(of: term), "Term:", term)
    guard type(of: term) == self.expectedType else { return }
    guard let command = term as? SMCommand, command != lastCommand else { return }
    lastCommand = command
    DispatchQueue.main.async {
      term.handleTerm()
    }
  }
}
