//
//  SMTranscriptionSegment.swift
//  SkyMate
//
//  Created by Thomas Heinis on 20/06/2023.
//

import Speech

protocol SMTranscriptionSegment {
  var substring: String { get }
  var startTime: TimeInterval { get }
  var duration: TimeInterval { get }
}

extension SFTranscriptionSegment: SMTranscriptionSegment {
  var startTime: TimeInterval {
    0
  }
}

extension Queue<SMTranscriptionSegment> {

  /// The combined substrings of all segments in the buffer.
  var joined: String {
    queueLock.sync {
      queue.map { $0.substring }.joined()
    }
  }

}
