//
//  SkyMateQueueTests.swift
//  SkyMateTests
//
//  Created by Thomas Heinis on 04/08/2023.
//

@testable import SkyMate
import Speech
import XCTest

class QueueTests: XCTestCase {

  let aSingleElement = 42
  let capacity = 10
  let expectedElementsCount = 1
  let queue = Queue<Int>()

  var fullRange: ClosedRange<Int> { 0 ... capacity - 1 }
  var overloadedRange: Range<Int> { 0 ..< capacity + 1 }

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
    XCTAssertEqual(queue.count(), capacity)
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
}
