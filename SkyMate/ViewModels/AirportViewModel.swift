//
//  DestinationViewModel.swift
//  SkyMate
//
//  Created by Thomas Heinis on 20/07/2023.
//

import Foundation

final class AirportViewModel {
  init() {
    let cardTitle = DestinationText.title.localized
    let cardContent = DestinationText.content.localized
    let card = Card(title: cardTitle, content: cardContent)
    CarrouselViewModel.shared.addCard(card)
  }
}
