//
//  CommandViewModel.swift
//  SkyMate
//
//  Created by Thomas Heinis on 20/07/2023.
//

/// `CommandViewModel` is a ViewModel class for displaying the list of available commands.
final class CommandViewModel {

  // MARK: - Initialization

  /// Initializer for the `CommandViewModel` class.
  ///
  /// Upon initialization, it sets up a localized card displaying the list of commands and adds it
  /// to the `CarrouselViewModel`.
  init() {
    let cardTitle = CommandText.title.localized
    let cardContent = CommandText.content.localized
    let card = Card(title: cardTitle, content: cardContent)
    CarrouselViewModel.shared.addCard(card)
  }
}
