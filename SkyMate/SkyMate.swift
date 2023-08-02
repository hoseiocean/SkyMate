//
//  SkyMate.swift
//  SkyMate
//
//  Created by Thomas Heinis on 11/06/2023.
//

import SwiftUI

@main final class SkyMate: App {

  @ObservedObject private var recognitionProvider: RecognitionProvider

  var body: some Scene {
    WindowGroup {
      let contentView = ContentView()
        .environmentObject(RecognitionProvider.shared)
      contentView
    }
  }

  init() {
    self.recognitionProvider = RecognitionProvider.shared
    Task {
      await self.recognitionProvider.start()
    }
  }
}
