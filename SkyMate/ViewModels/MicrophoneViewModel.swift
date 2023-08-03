//
//  MicrophoneViewModel.swift
//  SkyMate
//
//  Created by Thomas Heinis on 20/07/2023.
//

/// `MicrophoneViewModel` is a final class responsible for managing the microphone state
/// and the associated card’s content.
final class MicrophoneViewModel {

  // MARK: - Initialization

  /// The initializer tries to stop the microphone listening, updates the card content based on
  /// the operation’s success or failure, creates a new `Card` instance with the generated content,
  /// and adds the card to the `CarrouselViewModel`.
  init() {
    let cardTitle = MicrophoneText.title.localized

    var cardContent = String()

    do {
      try RecognitionProvider.shared.stopListening()
      cardContent = MicrophoneText.content.localized
    } catch {
      cardContent = String(describing: error.localizedDescription)
    }
    let card = Card(title: cardTitle, content: cardContent)
    CarrouselViewModel.shared.addCard(card)
  }
}
