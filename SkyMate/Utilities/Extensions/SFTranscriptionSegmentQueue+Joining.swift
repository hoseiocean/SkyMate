//
//  SFTranscriptionSegmentQueue+Joining.swift
//  SkyMate
//
//  Created by Thomas Heinis on 26/06/2023.
//

import Speech

extension Queue<SFTranscriptionSegment> {

  /// The combined substrings of all segments in the buffer.
  var joined: String {
    executeUnderLock {
      queue.map { $0.substring }.joined()
    }
  }
}
