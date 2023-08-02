//
//  CarrouselViewModel.swift
//  SkyMate
//
//  Created by Thomas Heinis on 10/07/2023.
//

import Combine
import Foundation

final class CarrouselViewModel: ObservableObject {

  private let languageManager = LanguageManager.shared

  private var cancellables = Set<AnyCancellable>()

  static let shared = CarrouselViewModel()

  @Published var cards: [Card] = []
  @Published var currentCard: Card?

  private init() { }

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

  func updateCard(_ card: Card, with newContent: String) {
    if let index = cards.firstIndex(where: { $0.id == card.id }) {
      DispatchQueue.main.async {
        self.objectWillChange.send()
        self.cards[index].content = newContent
      }
    }
  }
}
