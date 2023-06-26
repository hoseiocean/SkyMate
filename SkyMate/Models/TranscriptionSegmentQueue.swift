//
//  TranscriptionSegmentQueue.swift
//  SkyMate
//
//  Created by Thomas Heinis on 26/06/2023.
//

final class TranscriptionSegmentQueue: Queue<SMTranscriptionSegment> {

  // MARK: - Properties

  private enum Error: Swift.Error {
    case transcriptionProcessorCreationFailed(error: Swift.Error)
  }

  private var transcriptionProcessor: TranscriptionProcessor?

  init(recognitionObserver: RecognitionObserver) {
    do {
      transcriptionProcessor = try TranscriptionProcessor(recognitionObserver: recognitionObserver)
    } catch {
      print("TranscriptionProcessor creation failed:", error)
    }
  }

  // MARK: - Public Methods

  override func enqueue(_ segment: SMTranscriptionSegment) {
    super.enqueue(segment)
    transcriptionProcessor?.process(self)
  }
}
