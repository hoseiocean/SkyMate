//
//  StringsQueue.swift
//  SkyMate
//
//  Created by Thomas Heinis on 26/06/2023.
//

final class StringsQueue: Queue<String> {

  /// The combined substrings of all segments in the buffer.
  var joined: String {
    getElements().joined()
  }

  override func enqueue(_ element: String) {
    super.enqueue(element)
  }
}
