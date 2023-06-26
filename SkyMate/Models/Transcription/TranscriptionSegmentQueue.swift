//
//  TranscriptionSegmentQueue.swift
//  SkyMate
//
//  Created by Thomas Heinis on 26/06/2023.
//

import Speech

/// A specialized queue for storing and processing transcription segments.
final class TranscriptionSegmentQueue: Queue<SFTranscriptionSegment> {
  
  // MARK: - Properties
  
  private enum Error: Swift.Error {
    case transcriptionProcessorCreationFailed(error: Swift.Error)
  }
  
  private var transcriptionProcessor: TranscriptionProcessor?
  
  // MARK: - Initializer
  
  /// Initializes a new instance of the `TranscriptionSegmentQueue` class with a recognition observer.
  /// - Parameter recognitionObserver: The recognition observer to be used for processing transcriptions.
  /// - Throws: An error of type `Error.transcriptionProcessorCreationFailed` if the transcription processor creation fails.
  init(recognitionObserver: RecognitionObserver) throws {
    do {
      transcriptionProcessor = try TranscriptionProcessor(recognitionObserver: recognitionObserver)
    } catch {
      throw Error.transcriptionProcessorCreationFailed(error: error)
    }
  }
  
  // MARK: - Public Methods
  
  /// Adds a transcription segment to the queue and processes the queue using the associated transcription processor.
  /// - Parameter segment: The transcription segment to enqueue.
  override func enqueue(_ segment: SFTranscriptionSegment) {
    super.enqueue(segment)
    transcriptionProcessor?.process(self)
  }
}
