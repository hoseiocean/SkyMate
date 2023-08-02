//
//  CommandViewModel.swift
//  SkyMate
//
//  Created by Thomas Heinis on 20/07/2023.
//

import Foundation

final class CommandViewModel {
  
  init() {
    let cardTitle = CommandText.title.localized
    let cardContent = CommandText.content.localized
    let card = Card(title: cardTitle, content: cardContent)
    CarrouselViewModel.shared.addCard(card)
  }
}
