//
//  Resource.swift
//  SkyMate
//
//  Created by Thomas Heinis on 07/07/2023.
//

import Foundation

struct HTTPBody {
  let data: Data?
  let parameters: [URLQueryItem]?
}

enum HTTPMethod: String {
  case get = "GET"
  case post = "POST"
}

struct Resource {
    let url: URL!
    let method: HTTPMethod
    let body: HTTPBody
    var headers: [String: String] = [:]
}
