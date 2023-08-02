//
//  MicrophoneViewModel.swift
//  SkyMate
//
//  Created by Thomas Heinis on 20/07/2023.
//

import Foundation

final class MicrophoneViewModel {

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
