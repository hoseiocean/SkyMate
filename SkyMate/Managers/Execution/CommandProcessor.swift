//
//  RecognitionHandler.swift
//  SkyMate
//
//  Created by Thomas Heinis on 18/06/2023.
//

import Foundation

protocol CommandProcessing {
  func handle(term: any SMTerm)
}

final class CommandProcessor: CommandProcessing {

  private var expectedType = SMCommand.self
  private var lastCommand: SMCommand?

  static let shared = CommandProcessor()

  private init() {}

  func handle(term: any SMTerm) {
    print(Self.self, "Expected:", expectedType, "Recognized:", type(of: term), term)
    guard type(of: term) == self.expectedType else { return }
    guard let command = term as? SMCommand, command != lastCommand else { return }
    lastCommand = command
    DispatchQueue.main.async {
      term.handleTerm()
    }
  }
}
