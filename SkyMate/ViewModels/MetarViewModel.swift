//
//  MetarViewModel.swift
//  SkyMate
//
//  Created by Thomas Heinis on 20/07/2023.
//

import Foundation

/// Errors specific to `MetarViewModel`.
enum MetarViewModelError: Error {

  /// Error thrown when a required key is not found in the app’s configuration.
  case keyNotFound(key: String)
}

// MARK: - MetarViewModel

/// `MetarViewModel` is responsible for creating and managing `Card` instances that represent METAR
/// data.
final class MetarViewModel {

  // MARK: - Config

  private enum Config {
    static let appKeyKeyString = "APP_KEY_KEY"
    static let appKeyValueString = "APP_KEY_VALUE"

    static var appKeyKey: String? {
      try? value(for: appKeyKeyString).get()
    }
    static var appKeyValue: String? {
      try? value(for: appKeyValueString).get()
    }

    static func value(for key: String) -> Result<String, Error> {
      guard let value = Bundle.main.infoDictionary?[key] as? String else {
        return .failure(MetarViewModelError.keyNotFound(key: key))
      }
      return .success(value)
    }
  }

  // MARK: - Initialization

  /// Creates a new `MetarViewModel` and initiates the loading of METAR data.
  init() {
    var cardContent = String()

    guard
      let appKeyKey = Config.appKeyKey,
      let appKeyValue = Config.appKeyValue
    else {
      cardContent = MetarText.missingURL.localized
      return
    }

    let resource = Resource(
      url: APIList.metarAPI.url!,
      method: .get,
      body: HTTPBody(data: nil, parameters: nil),
      headers: [appKeyKey: appKeyValue]
    )

    let cardTitle = MetarText.title.localized

    NetworkManager.shared.load(resource) { (result: Result<Metar, Error>) in
      switch result {
      case .success(let data):
        cardContent = String(describing: data.data.description)
      case .failure(let error):
        cardContent = String(describing: error.localizedDescription)
      }
      DispatchQueue.main.async {
        let card = Card(title: cardTitle, content: cardContent)
        CarrouselViewModel.shared.addCard(card)
      }
    }
  }
}
