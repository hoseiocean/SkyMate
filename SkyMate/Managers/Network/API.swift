//
//  API.swift
//  SkyMate
//
//  Created by Thomas Heinis on 07/07/2023.
//

import Foundation

// MARK: - API Protocol

/// Protocol that defines the URL property that an API must have.
protocol API {
  var url: URL? { get }
}

// MARK: - APIList Enum

/// List of all the APIs used in the application.
enum APIList: API {

  /// The METAR weather observation API.
  case metarAPI

  // MARK: - URL

  /// URL used to make requests to the specific API.
  var url: URL? {
    switch self {
    case .metarAPI:
      return URL(string: "https://api.checkwx.com/metar/DGAA")
    }
  }
}
