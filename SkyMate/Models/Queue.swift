//
//  Queue.swift
//  SkyMate
//
//  Created by Thomas Heinis on 14/06/2023.
//

import Foundation

class Queue<T>: CustomStringConvertible {

  // MARK: - Properties

  private let capacity: Int
  
  let queueLock = DispatchQueue(label: String(describing: T.self) + "QueueLock")

  var queue: [T]

  var description: String {
    var result = "["
    for item in queue {
      result += "\(item), "
    }
    return result + "]"
  }

  // MARK: - Initialization

  /// Initializes a new SFTranscriptionSegmentBuffer with the specified capacity.
  /// - Parameter capacity: The maximum number of segments the buffer can hold. Defaults to 3.
  init(capacity: Int = 10) {
    self.queue = [T]()
    self.capacity = max(.zero, capacity)
  }

  // MARK: - Public Methods

  /// Removes all segments from the buffer.
  func clear() {
    queueLock.sync {
      queue.removeAll()
    }
  }

  /// Returns the number of segments currently in the buffer.
  func count() -> Int {
    queueLock.sync {
      queue.count
    }
  }

  /// Removes and returns the first segment from the buffer, or nil if the buffer is empty.
  /// - Returns: The first SFTranscriptionSegment in the buffer, or nil if the buffer is empty.
  @discardableResult func dequeue() -> T? {
    queueLock.sync {
      if !queue.isEmpty {
        return queue.removeFirst()
      }
      return nil
    }
  }

  func displaySegments() {
    print(description)
  }

  /// Adds a segment to the buffer, removing the first segment if the buffer exceeds its capacity.
  /// - Parameter segment: The SFTranscriptionSegment to enqueue.
  func enqueue(_ segment: T) {
    queueLock.sync {
      queue.append(segment)
      if queue.count > capacity {
        queue.removeFirst()
      }
    }
  }

  /// Checks if the buffer is full (i.e., the number of segments equals the capacity).
  /// - Returns: True if the buffer is full, false otherwise.
  func isFull() -> Bool {
    queueLock.sync {
      queue.count == capacity
    }
  }

}
