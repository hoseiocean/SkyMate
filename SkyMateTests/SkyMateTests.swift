//
//  SkyMateTests.swift
//  SkyMateTests
//
//  Created by Thomas Heinis on 24/07/2023.
//

@testable import SkyMate
import Speech
import XCTest

class SkyMateTests: XCTestCase {
  
  // MARK: - Queue
  
  let aSingleElement = 42
  let defaultCapacity = 10
  let expectedElementsCount = 1
  let queue = Queue<Int>()
  
  var commandProcessor: CommandProcessor!
  var dictionaryManager: DictionaryManager!
  var fullRange: ClosedRange<Int> { 0 ... defaultCapacity - 1 }
  var overloadedRange: Range<Int> { 0 ..< defaultCapacity + 1 }
  var sut: TranscriptionProcessor!
  
  override func setUp() {
    super.setUp()
    dictionaryManager = DictionaryManager.shared
    commandProcessor = CommandProcessor.shared
  }
  
  override func tearDown() {
    sut = nil
    dictionaryManager = nil
    commandProcessor = nil
    super.tearDown()
  }
  
  func test_GivenOverloadedQueue_WhenCheckingIsFull_ThenReturnsTrue() {
    // Given
    for _ in overloadedRange {
      queue.enqueue(aSingleElement)
    }
    
    // When & Then
    XCTAssertTrue(queue.isFull())
  }
  
  func test_GivenEmptyQueue_WhenEnqueuingElement_ThenIsEmptyAndIsFullReturnCorrectValues() {
    // Given & When
    queue.enqueue(aSingleElement)
    
    // Then
    XCTAssertFalse(queue.isEmpty())
    XCTAssertFalse(queue.isFull())
  }
  
  func test_GivenQueueWithOneElement_WhenCheckingCount_ThenReturnsOne() {
    // Given
    queue.enqueue(aSingleElement)
    
    // When & Then
    XCTAssertEqual(queue.count(), expectedElementsCount)
  }
  
  func test_GivenOverloadedQueue_WhenGetElements_ThenReturnsCorrectElements() {
    // Given
    for i in overloadedRange {
      queue.enqueue(i)
    }
    
    // When
    let elements = queue.getElements()
    
    // Then
    XCTAssertEqual(elements, Array(overloadedRange.dropFirst()), "getElements() should return all elements in the queue.")
  }
  
  
  func test_GivenOverloadedQueue_WhenCheckingCount_ThenReturnsCapacity() {
    // Given
    for i in overloadedRange {
      queue.enqueue(i)
    }
    
    // When & Then
    XCTAssertEqual(queue.count(), defaultCapacity)
  }
  
  func test_GivenFullQueue_WhenDequeueingElements_ThenReturnsElementsInCorrectOrder() {
    // Given
    for i in fullRange {
      queue.enqueue(i)
    }
    
    // When & Then
    for i in fullRange {
      XCTAssertEqual(queue.dequeue(), i)
    }
  }
  
  func test_GivenEmptyQueue_WhenEnqueuingAndDequeueingElement_ThenIsEmptyReturnsTrue() {
    // Given
    queue.enqueue(aSingleElement)
    
    // When
    queue.dequeue()
    
    // Then
    XCTAssertTrue(queue.isEmpty())
    XCTAssertFalse(queue.isFull())
  }
  
  func test_GivenQueueWithElements_WhenClearing_ThenIsEmptyReturnsTrue() {
    // Given
    for _ in fullRange {
      queue.enqueue(aSingleElement)
    }
    
    // When
    queue.clear()
    
    // Then
    XCTAssertTrue(queue.isEmpty(), "Queue should be empty after calling clear().")
  }
  
  func test_GivenClearedQueue_WhenDequeueing_ThenReturnsNil() {
    // Given
    queue.clear()
    
    // When & Then
    XCTAssertNil(queue.dequeue(), "dequeue() should return nil after calling clear().")
  }
  
  // MARK: - Transcription Processor
  
  func testParse_SpeechRecognitionResult_ShouldReturnCommand() {
    sut = TranscriptionProcessor(dictionaryManager: dictionaryManager, commandProcessor: commandProcessor)

//    DispatchQueue.main.async {
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
      self.sut.parse(speechRecognitionResult: speechRecognitionResult)
      
      // Then
      // Use an expectation for a notification to be posted
      let expect = self.expectation(forNotification: .transcriptionDidFoundTerm, object: nil, handler: nil)
      // Wait for the expectation to be fulfilled
      self.wait(for: [expect], timeout: 1.0)
//    }
  }
  
  func testParse_SpeechRecognitionResult_ShouldNotReturnCommand() {
    sut = TranscriptionProcessor(dictionaryManager: dictionaryManager, commandProcessor: commandProcessor)

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
  
  // MARK: - Network Status Monitor
  
  func test_Deinit_ShouldStopsMonitoring() {
    let expectation = self.expectation(description: "stopMonitoring was called")
    
    // Subclassing NetworkStatusMonitor to test stopMonitoring
    class TestableNetworkStatusMonitor: NetworkStatusMonitor {
      var onStopped: (() -> Void)?
      
      override func stopMonitoring() {
        super.stopMonitoring()
        onStopped?()
      }
    }
    
    var monitor: TestableNetworkStatusMonitor? = TestableNetworkStatusMonitor()
    monitor?.onStopped = {
      expectation.fulfill()
    }
    monitor = nil
    
    waitForExpectations(timeout: 1.0) { (error) in
      if let error {
        XCTFail("waitForExpectations error: \(error)")
      }
    }
  }
  
  // MARK: - Audio Manager
  
  func testAudioManagerDeinit() async throws {
    var audioManager: AudioManager? = AudioManager()
    weak var weakReference = audioManager
    
    await audioManager?.listen()
    XCTAssertTrue(audioManager?.isListening == true)
    
    audioManager?.stopAndClean()
    XCTAssertFalse(audioManager?.isListening == true)
    
    audioManager = nil
    try await Task.sleep(nanoseconds: UInt64(0.1 * 1_000_000_000))
    XCTAssertNil(weakReference, "Expected AudioManager to be deallocated but it was not!")
  }
}
