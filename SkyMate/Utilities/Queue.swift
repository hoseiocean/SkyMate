//
//  Queue.swift
//  SkyMate
//
//  Created by Thomas Heinis on 14/06/2023.
//

import Foundation

/// A thread-safe, fixed-capacity queue for storing items of any type.
class Queue<T> {

  // MARK: - Properties

  private let capacity: Int
  private let queueLock = DispatchQueue(label: String(describing: T.self) + Const.Label.queueLock)

  private var queue: [T]

  // MARK: - Initialization

  /// Initializes a new queue with the specified capacity.
  /// - Parameter capacity: The maximum number of items the queue can hold. Defaults to 10.
  ///   Must be greater than 0.
  init(capacity: Int = 10) {
    self.queue = [T]()
    self.capacity = max(1, capacity)
  }

  // MARK: - Public Methods

  /// Removes all items from the queue.
  func clear() {
    executeUnderLock {
      queue.removeAll()
    }
  }

  /// Returns the number of items currently in the queue.
  func count() -> Int {
    executeUnderLock {
      queue.count
    }
  }

  /// Removes and returns the first item from the queue, or nil if the queue is empty.
  /// - Returns: The first item in the queue, or nil if the queue is empty.
  @discardableResult func dequeue() -> T? {
    executeUnderLock {
      if !queue.isEmpty {
        return queue.removeFirst()
      }
      return nil
    }
  }

  /// Adds an item to the queue. If this causes the queue to exceed its capacity,
  /// the first item in the queue is removed.
  /// - Parameter item: The item to enqueue.
  func enqueue(_ item: T) {
    executeUnderLock {
      if isFull() {
        queue.removeFirst()
      }
      queue.append(item)
    }
  }

  /// Executes a closure in a thread-safe manner, using the queue's lock.
  /// - Parameter operation: The closure to execute. The closure's return value is returned by this method.
  /// - Returns: The result of the `operation`.
  func executeUnderLock<R>(_ operation: () -> R) -> R {
    queueLock.sync {
      operation()
    }
  }

  /// Retrieves all elements currently in the queue in a thread-safe manner.
  ///
  /// - Returns: An array containing all elements currently in the queue.
  /// The returned array is a snapshot of the queue's state at the moment this method was called, and further modifications to the queue will not be reflected in this array.
  func getElements() -> [T] {
    executeUnderLock {
      queue
    }
  }

  /// Checks if the queue is empty.
  /// - Returns: True if the queue is empty, false otherwise.
  func isEmpty() -> Bool {
    queue.isEmpty
  }
  
  /// Checks if the queue is full (i.e., the number of items equals the capacity).
  /// - Returns: True if the queue is full, false otherwise.
  func isFull() -> Bool {
    queue.count == capacity
  }
}
