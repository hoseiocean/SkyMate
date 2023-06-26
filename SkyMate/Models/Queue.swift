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
  private let queueLock = DispatchQueue(label: String(describing: T.self) + Constant.Name.queueLock)

  /// The array storing the items of the queue.
  var queue: [T]

  // MARK: - Initialization

  /// Initializes a new queue with the specified capacity.
  /// - Parameter capacity: The maximum number of items the queue can hold. Defaults to 10.
  ///   Must be greater than 0.
  init(capacity: Int = 10) {
    assert(capacity > 0, "Capacity must be greater than 0")
    self.queue = [T]()
    self.capacity = max(.zero, capacity)
  }

  // MARK: - Public Methods

  /// Removes all items from the queue.
  func clear() {
    queueLock.sync {
      queue.removeAll()
    }
  }

  /// Returns the number of items currently in the queue.
  func count() -> Int {
    queueLock.sync {
      queue.count
    }
  }

  /// Removes and returns the first item from the queue, or nil if the queue is empty.
  /// - Returns: The first item in the queue, or nil if the queue is empty.
  @discardableResult func dequeue() -> T? {
    queueLock.sync {
      if !queue.isEmpty {
        return queue.removeFirst()
      }
      return nil
    }
  }

  /// Adds an item to the queue. If this causes the queue to exceed its capacity,
  /// the first item in the queue is removed.
  /// - Parameter item: The item to enqueue.
  func enqueue(_ segment: T) {
    queueLock.sync {
      queue.append(segment)
      if queue.count > capacity {
        queue.removeFirst()
      }
    }
  }

  /// Executes a closure in a thread-safe manner, using the queue's lock.
  /// - Parameter operation: The closure to execute. The closure's return value is returned by this method.
  /// - Returns: The result of the `operation`.
  func executeUnderLock<R>(_ operation: () -> R) -> R {
    return queueLock.sync {
      operation()
    }
  }

  /// Checks if the queue is full (i.e., the number of items equals the capacity).
  /// - Returns: True if the queue is full, false otherwise.
  func isFull() -> Bool {
    queueLock.sync {
      queue.count == capacity
    }
  }
}
