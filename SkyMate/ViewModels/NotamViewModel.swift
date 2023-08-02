//
//  NotamViewModel.swift
//  SkyMate
//
//  Created by Thomas Heinis on 20/07/2023.
//

import Foundation

final class NotamViewModel {
  
  init() {
    let cardTitle = NotamText.title.localized
    let cardContent = NotamText.content.localized
    let card = Card(title: cardTitle, content: cardContent)
    CarrouselViewModel.shared.addCard(card)
  }
}
