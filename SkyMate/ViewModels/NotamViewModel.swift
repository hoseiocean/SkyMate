//
//  NotamViewModel.swift
//  SkyMate
//
//  Created by Thomas Heinis on 20/07/2023.
//

/// `NotamViewModel` is a ViewModel class for managing NOTAM (Notice to Airmen) information.
final class NotamViewModel {

  // MARK: - Initialization

  /// Initializer for the `NotamViewModel` class.
  ///
  /// Upon initialization, it sets up a localized NOTAM card and adds it to the
  /// `CarrouselViewModel`.
  init() {
    let cardTitle = NotamText.title.localized
    let cardContent = NotamText.content.localized
    let card = Card(title: cardTitle, content: cardContent)
    CarrouselViewModel.shared.addCard(card)
  }
}
