//
//  MetarViewModel.swift
//  SkyMate
//
//  Created by Thomas Heinis on 20/07/2023.
//

import Foundation

final class MetarViewModel {

  init() {
    let cardTitle = MetarText.title.localized
    var cardContent = String()
    let resource = Resource(
      url: APIList.metarAPI.url!,
      method: .get,
      body: HTTPBody(data: nil, parameters: nil),
      headers: ["X-API-Key": "5d540a86255f4128a040f61648"]
    )

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
