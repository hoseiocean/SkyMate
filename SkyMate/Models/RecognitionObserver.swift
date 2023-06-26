//
//  RecognitionHandler.swift
//  SkyMate
//
//  Created by Thomas Heinis on 18/06/2023.
//

import Foundation

final class RecognitionObserver: ObservableObject {

  // MARK: - Properties

  @Published var isRecognizing: Bool = false
  @Published var term: String = ScreenText.defaultMessage.localized

}
