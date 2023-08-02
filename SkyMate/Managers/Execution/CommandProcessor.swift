//
//  RecognitionHandler.swift
//  SkyMate
//
//  Created by Thomas Heinis on 18/06/2023.
//

import Foundation

protocol CommandProcessing {
  func process(term: any SMTerm)
}

final class CommandProcessor: CommandProcessing {

  private var expectedType = SMCommand.self

  static let shared = CommandProcessor()

  private init() {}

  func process(term: any SMTerm) {
    print(Self.self, "Expected:", expectedType, "Recognized:", type(of: term), term)
    guard type(of: term) == self.expectedType else { return }
    DispatchQueue.main.async {
      term.handleTerm()
    }
  }
}
