//
//  SkyMateTests.swift
//  SkyMateTests
//
//  Created by Thomas Heinis on 24/07/2023.
//

@testable import SkyMate
import Speech
import XCTest

class TranscriptionProcessorTests: XCTestCase {
  var sut: TranscriptionProcessor!
  var dictionaryManager: DictionaryManager!
  var commandProcessor: CommandProcessor!

  override func setUp() {
    super.setUp()
    dictionaryManager = DictionaryManager.shared
    commandProcessor = CommandProcessor.shared
    sut = TranscriptionProcessor(dictionaryManager: dictionaryManager, commandProcessor: commandProcessor)
  }

  override func tearDown() {
    sut = nil
    dictionaryManager = nil
    commandProcessor = nil
    super.tearDown()
  }

  func testParse_SpeechRecognitionResult_ShouldReturnCommand() {
    // Given
    let bestTranscription = "mais tard"
    let isFinal = true
    let transcriptions = ["mais tard"]
    let speechRecognitionResult = SpeechRecognitionResult(
      bestTranscription: bestTranscription,
      isFinal: isFinal,
      speechRecognitionMetadata: nil,
      transcriptions: transcriptions
    )

    // When
    sut.parse(speechRecognitionResult: speechRecognitionResult)

    // Then
    // Use an expectation for a notification to be posted
    let expect = expectation(forNotification: .transcriptionDidFoundTerm, object: nil, handler: nil)
    // Wait for the expectation to be fulfilled
    wait(for: [expect], timeout: 1.0)
  }

  func testParse_SpeechRecognitionResult_ShouldNotReturnCommand() {
    // Given
    let bestTranscription = "not a command"
    let isFinal = true
    let transcriptions = ["not a command"]
    let speechRecognitionResult = SpeechRecognitionResult(
      bestTranscription: bestTranscription,
      isFinal: isFinal,
      speechRecognitionMetadata: nil,
      transcriptions: transcriptions
    )

    // When
    sut.parse(speechRecognitionResult: speechRecognitionResult)

    // Then
    // Use an expectation for a notification to be posted
    let expect = expectation(forNotification: .didProcessedTranscription, object: nil, handler: nil)
    // Wait for the expectation to be fulfilled
    wait(for: [expect], timeout: 1.0)
  }
}
