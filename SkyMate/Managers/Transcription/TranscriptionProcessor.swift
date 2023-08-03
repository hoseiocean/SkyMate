//
//  TranscriptionProcessor.swift
//  SkyMate
//
//  Created by Thomas Heinis on 15/06/2023.
//

import Speech

// MARK: - SpeechRecognitionResult

/// Structure representing the result of speech recognition. Created to reduce dependency on the
/// framework used.
struct SpeechRecognitionResult {

  private var _speechRecognitionMetadata: Any?

  /// The most accurate transcription determined by the speech recognizer.
  let bestTranscription: String

  /// A boolean value indicating whether the speech recognizer has determined the final results.
  let isFinal: Bool

  /// An array of all transcriptions ordered by decreasing accuracy.
  let transcriptions: [String]

  // Initialization

  /// Initializes a new speech recognition result.
  init(bestTranscription: String, isFinal: Bool, speechRecognitionMetadata: Any?, transcriptions: [String]) {
    self.bestTranscription = bestTranscription
    self.isFinal = isFinal
    self._speechRecognitionMetadata = speechRecognitionMetadata
    self.transcriptions = transcriptions
  }

  // Speech Recognition Metadata

  /// The speech recognition metadata, available from iOS 14.5 and onwards.
  @available(iOS 14.5, *)
  var speechRecognitionMetadata: SFSpeechRecognitionMetadata? {
    get {
      return _speechRecognitionMetadata as? SFSpeechRecognitionMetadata
    }
    set {
      _speechRecognitionMetadata = newValue
    }
  }
}

// MARK: - SFSpeechRecognitionResult Extension

extension SFSpeechRecognitionResult {

  /// Convert an SFSpeechRecognitionResult into a SpeechRecognitionResult.
  func toSpeechRecognitionResult() -> SpeechRecognitionResult {
    if #available(iOS 14.5, *) {
      return SpeechRecognitionResult(
        bestTranscription: self.bestTranscription.formattedString,
        isFinal: self.isFinal,
        speechRecognitionMetadata: self.speechRecognitionMetadata,
        transcriptions: self.transcriptions.map { $0.formattedString }
      )
    } else {
      return SpeechRecognitionResult(
        bestTranscription: self.bestTranscription.formattedString,
        isFinal: self.isFinal,
        speechRecognitionMetadata: nil,
        transcriptions: self.transcriptions.map { $0.formattedString }
      )
    }
  }
}

// MARK: - TranscriptionProcessorError

/// The set of errors that can be thrown when processing transcriptions.
enum TranscriptionProcessorError: Error {
  case lastSegmentFailed
  case transcriptionFailed
}

// MARK: - TranscriptionProcessor

/// Class that handles the processing of speech transcriptions.
final class TranscriptionProcessor {

  // Config

  private struct Config {
    static let singleTranscriptionCount = 1
  }

  // Properties

  private let commandProcessor: CommandProcessing
  private let dictionaryManager: DictionaryManaging
  private let expectedTypes: [SMTermType] = [.command, .letter]

  /// The operating mode of the recognition provider.
  let operatingMode: RecognitionProviderOperatingMode

  /// Queue for holding transcriptions.
  let speechStringsQueue = StringsQueue()

  // Initialization

  /// Initializes a new transcription processor with the given parameters.
  init(
    dictionaryManager: DictionaryManaging = DictionaryManager.shared,
    commandProcessor: CommandProcessing = CommandProcessor.shared,
    operatingMode: RecognitionProviderOperatingMode = .normal
  ) {
    self.dictionaryManager = dictionaryManager
    self.commandProcessor = commandProcessor
    self.operatingMode = operatingMode
  }

  // Private Methods

  private func displayTranscriptions(for speech: SpeechRecognitionResult) {
    print("Transcripts in order of decreasing confidence")
    for transcription in speech.transcriptions {
      print(transcription)
    }
  }
  
  private func getTranscriptionFrom(speech: SpeechRecognitionResult) throws -> String? {
    if #available(iOS 14.5, *) {
      guard speech.speechRecognitionMetadata == nil else { return nil }
    }
    guard
      speech.transcriptions.count == Config.singleTranscriptionCount,
      let transcription = speech.transcriptions.last
    else {
      throw TranscriptionProcessorError.transcriptionFailed
    }
    return transcription
  }
  
  private func handleError(error: Error) {
    speechStringsQueue.clear()
    NotificationCenter.default.post(name: .transcriptionDidEncounterError, object: error)
  }
  
  private func processQueueAndFetchTerm() {
    let joinedQueueString = speechStringsQueue.joined
    if let smTerm = try? dictionaryManager.fetchTerm(forKey: joinedQueueString, ofExpectedTypes: expectedTypes) {
      speechStringsQueue.clear()
      commandProcessor.handle(term: smTerm)
      NotificationCenter.default.post(name: .transcriptionDidFoundTerm, object: nil)
    } else {
      NotificationCenter.default.post(name: .didProcessedTranscription, object: nil)
    }
  }

  // Public Methods

  /// Parses an SFSpeechRecognitionResult and convert it to SpeechRecognitionResult, structure over
  /// which we have control.
  func parse(speechRecognitionResult: SFSpeechRecognitionResult) {
    parse(speechRecognitionResult: speechRecognitionResult.toSpeechRecognitionResult())
  }

  /// Parses a SpeechRecognitionResult.
  func parse(speechRecognitionResult: SpeechRecognitionResult) {
    switch operatingMode {
    case .learning:
      displayTranscriptions(for: speechRecognitionResult)
    case .normal:
      DispatchQueue.main.async { [weak self] in
        guard let self else { return }
        let transcriptionResult: Result<String?, Error> = Result {
          try self.getTranscriptionFrom(speech: speechRecognitionResult)
        }
        switch transcriptionResult {
        case .success(let speechString):
          guard let speechString else { return }
          self.speechStringsQueue.enqueue(speechString)
          self.processQueueAndFetchTerm()
        case .failure(let error):
          self.handleError(error: error)
        }
      }
    }
  }
}
