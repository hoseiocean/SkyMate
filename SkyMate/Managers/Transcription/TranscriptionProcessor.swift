//
//  TranscriptionProcessor.swift
//  SkyMate
//
//  Created by Thomas Heinis on 15/06/2023.
//

import Speech

struct SpeechRecognitionResult {
  let bestTranscription: String
  let isFinal: Bool
  private var _speechRecognitionMetadata: Any?
  let transcriptions: [String]
  
  init(bestTranscription: String, isFinal: Bool, speechRecognitionMetadata: Any?, transcriptions: [String]) {
    self.bestTranscription = bestTranscription
    self.isFinal = isFinal
    self._speechRecognitionMetadata = speechRecognitionMetadata
    self.transcriptions = transcriptions
  }
  
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

extension SFSpeechRecognitionResult {
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

enum TranscriptionProcessorError: Error {
  case lastSegmentFailed
  case transcriptionFailed
}

final class TranscriptionProcessor {
  
  private struct Config {
    static let singleTranscriptionCount = 1
  }
  
  private let commandProcessor: CommandProcessing
  private let dictionaryManager: DictionaryManaging
  private let expectedTypes: [SMTermType] = [.command, .letter]
  
  let operatingMode: RecognitionProviderOperatingMode
  let speechStringsQueue = StringsQueue()
  
  init(
    dictionaryManager: DictionaryManaging = DictionaryManager.shared,
    commandProcessor: CommandProcessing = CommandProcessor.shared,
    operatingMode: RecognitionProviderOperatingMode = .normal
  ) {
    self.dictionaryManager = dictionaryManager
    self.commandProcessor = commandProcessor
    self.operatingMode = operatingMode
  }
  
  private func displayTranscriptions(for speech: SpeechRecognitionResult) {
    print("Transcripts in order of decreasing confidence")
    for transcription in speech.transcriptions {
      print(transcription)
    }
  }
  
  private func extractAndSearchSmTerm(in stringsQueue: StringsQueue) -> (any SMTerm)? {
    let joinedQueueString = stringsQueue.joined
    guard
      let smTerm = try? dictionaryManager.fetchTerm(forKey: joinedQueueString, ofExpectedTypes: expectedTypes)
    else {
      return nil
    }
    return smTerm
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
  
  func parse(speechRecognitionResult: SFSpeechRecognitionResult) {
    parse(speechRecognitionResult: speechRecognitionResult.toSpeechRecognitionResult())
  }
  
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
