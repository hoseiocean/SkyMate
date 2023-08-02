//
//  Card.swift
//  SkyMate
//
//  Created by Thomas Heinis on 10/07/2023.
//

import Combine
import SwiftUI

class Card: ObservableObject, Identifiable {

  let id: UUID

  @Published var content: String
  @Published private(set) var title: String

  init(title: String, content: String) {
    self.id = UUID()
    self.title = title
    self.content = content
  }

  func updateContent(_ newContent: String) {
    self.content = newContent
  }

  func updateTitle(_ newTitle: String) {
    self.title = newTitle
  }
}
