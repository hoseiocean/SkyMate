//
//  AirportViewModel.swift
//  SkyMate
//
//  Created by Thomas Heinis on 20/07/2023.
//

import Foundation

final class AirportViewModel {
  
  init() {
    let cardTitle = AirportText.title.localized
    let cardContent = AirportText.content.localized
    let card = Card(title: cardTitle, content: cardContent)
    CarrouselViewModel.shared.addCard(card)
  }
}
