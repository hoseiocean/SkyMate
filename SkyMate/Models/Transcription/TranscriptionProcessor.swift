//
//  TranscriptionProcessor.swift
//  SkyMate
//
//  Created by Thomas Heinis on 15/06/2023.
//

import Speech

/// A class that processes transcriptions and matches them with terms from a dictionary.
class TranscriptionProcessor {

  // MARK: - Properties

  private enum Error: Swift.Error {
    case dictionaryLoadingFailed(name: String, error: Swift.Error)
  }

  private let dictionaryManager: DictionaryManager

  private var dictionary: HomophoneToSMTermDictionary

  var sendRecognizedTerm: (String) -> Void

  // MARK: - Initialization

  /// Initializes a new instance of the `TranscriptionProcessor` class.
  /// - Parameters:
  /// - recognitionObserver: The recognition observer to which recognized terms will be sent.
  /// - Throws: An error of type `Error` if the dictionary loading fails.
  init(recognitionObserver: RecognitionObserver) throws {
    do {
      dictionaryManager = try DictionaryManager(for: SMCommand.self)
      dictionary = dictionaryManager.homophoneToSMTermDictionary
      sendRecognizedTerm = { term in
        recognitionObserver.term = term
      }
    } catch {
      let dictionaryName = String(describing: SMCommand.self)
      throw Error.dictionaryLoadingFailed(name: dictionaryName, error: error)
    }
  }

  // MARK: - Public Methods

  /// Processes the transcription segments and matches them with terms from the dictionary.
  /// - Parameter segmentsQueue: The queue of transcription segments to process.
  func process(_ segmentsQueue: Queue<SFTranscriptionSegment>) {
    let recognizedString = segmentsQueue.joined
    let (smTerm, isPrefixMatch) = dictionary.searchForKeyOrPrefix(like: recognizedString)

    var shouldClearQueue = false

    if let smTerm {
      sendRecognizedTerm(smTerm)
      shouldClearQueue = true

    } else if !isPrefixMatch {
      shouldClearQueue = true
    }

    if shouldClearQueue {
      segmentsQueue.clear()
    }
  }
}
