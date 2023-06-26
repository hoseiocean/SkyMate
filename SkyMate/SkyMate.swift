//
//  SkyMate.swift
//  SkyMate
//
//  Created by Thomas Heinis on 11/06/2023.
//

import SwiftUI

@main final class SkyMate: App {
  @ObservedObject private var recognitionProvider = RecognitionProvider()

  var body: some Scene {
    WindowGroup {
      ContentView()
        .environmentObject(recognitionProvider)
        .environmentObject(recognitionProvider.recognitionObserver)
    }
  }
}
