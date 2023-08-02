//
//  API.swift
//  SkyMate
//
//  Created by Thomas Heinis on 07/07/2023.
//

import Foundation

protocol API {
  var url: URL? { get }
}

enum APIList: API {
  case metarAPI

  var url: URL? {
    switch self {
    case .metarAPI:
      return URL(string: "https://api.checkwx.com/metar/DGAA")
    }
  }
}
