//
//  CarrouselViewModel.swift
//  SkyMate
//
//  Created by Thomas Heinis on 10/07/2023.
//

import Combine
import Foundation

/// Represents a model for managing a collection of `Card` objects for a carousel view.
final class CarrouselViewModel: ObservableObject {

  // MARK: - Properties

  /// Published collection of `Card` objects.
  @Published var cards: [Card] = []

  /// Represents the current card in focus.
  @Published var currentCard: Card?

  // MARK: - Singleton

  /// Shared singleton instance of `CarrouselViewModel`.
  static let shared = CarrouselViewModel()

  // MARK: - Initialization

  private init() { }

  // MARK: - Methods

  /// Adds a `Card` to the cards collection. If the card already exists, it is updated.
  /// The newly added or updated card is set as the current card.
  /// - Parameter card: The `Card` object to add or update in the cards collection.
  func addCard(_ card: Card) {
    DispatchQueue.main.async {
      if let index = self.cards.firstIndex(where: { $0.id == card.id }) {
        self.cards[index] = card
      } else {
        self.cards.append(card)
      }
      self.currentCard = card
    }
  }

  /// Updates the content of a specified card within the cards collection.
  /// - Parameters:
  ///   - card: The `Card` object to update.
  ///   - newContent: The new content for the specified `Card`.
  func updateCard(_ card: Card, with newContent: String) {
    if let index = cards.firstIndex(where: { $0.id == card.id }) {
      DispatchQueue.main.async {
        self.objectWillChange.send()
        self.cards[index].content = newContent
      }
    }
  }
}
