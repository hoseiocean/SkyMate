//
//  TranscriptionProcessor.swift
//  SkyMate
//
//  Created by Thomas Heinis on 15/06/2023.
//

class TranscriptionProcessor {

  // MARK: - Properties

  private enum Error: Swift.Error {
    case dictionaryLoadingFailed(error: Swift.Error)
  }

  private let dictionaryManager: DictionaryManager

  private var dictionary: HomophoneToSMTermDictionary

  var sendRecognizedTerm: ((String) -> Void)?

  // MARK: - Initialization

  init(recognitionObserver: RecognitionObserver) throws {
    do {
      dictionaryManager = try DictionaryManager(for: SMCommand.self)
      dictionary = dictionaryManager.homophoneToSMTermDictionary
      sendRecognizedTerm = { term in
        recognitionObserver.term = term
      }
    } catch {
      throw Error.dictionaryLoadingFailed(error: error)
    }
  }

  // MARK: - Public Methods

  func process(_ segmentsQueue: Queue<SMTranscriptionSegment>) {
    guard sendRecognizedTerm != nil else {
      print("Warning: sendRecognizedTerm is nil. Will not process.")
      return
    }
    
    let recognizedString = segmentsQueue.joined
    let (smTerm, isPrefixMatch) = dictionary.searchForKeyOrPrefix(like: recognizedString)

    if let smTerm {
      sendRecognizedTerm?(smTerm)
      segmentsQueue.clear()
    } else if !isPrefixMatch {
      segmentsQueue.clear()
    }
  }
}
