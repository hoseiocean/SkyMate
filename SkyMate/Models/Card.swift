//
//  Card.swift
//  SkyMate
//
//  Created by Thomas Heinis on 10/07/2023.
//

import Combine
import SwiftUI

/// `Card` is a class that models a card with an `id`, a `title`, and a `content`.
class Card: ObservableObject, Identifiable {

  // MARK: - Properties

  /// Unique identifier for `Card` instance.
  let id: UUID

  /// The content of the `Card`.
  @Published var content: String

  /// The title of the `Card`.
  @Published private(set) var title: String

  // MARK: - Initialization

  /// Initializes a new `Card` with the given `title` and `content`.
  /// - Parameters:
  ///   - title: The title of the `Card`.
  ///   - content: The content of the `Card`.
  init(title: String, content: String) {
    self.id = UUID()
    self.title = title
    self.content = content
  }

  // MARK: - Methods

  /// Updates the `content` of the `Card`.
  /// - Parameter newContent: The new content to update to.
  func updateContent(_ newContent: String) {
    self.content = newContent
  }

  /// Updates the `title` of the `Card`.
  /// - Parameter newTitle: The new title to update to.
  func updateTitle(_ newTitle: String) {
    self.title = newTitle
  }
}
