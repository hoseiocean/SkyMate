//
//  AirportViewModel.swift
//  SkyMate
//
//  Created by Thomas Heinis on 20/07/2023.
//

final class AirportViewModel {

  // MARK: - Initialization

  /// Creates an `AirportViewModel` instance which initializes a `Card` with the localized title
  /// and content for the airport, and adds it to the `CarrouselViewModel`.
  init() {
    let cardTitle = AirportText.title.localized
    let cardContent = AirportText.content.localized
    let card = Card(title: cardTitle, content: cardContent)
    CarrouselViewModel.shared.addCard(card)
  }
}
