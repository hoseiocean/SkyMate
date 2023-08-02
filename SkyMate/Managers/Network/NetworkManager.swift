//
//  NetworkManager.swift
//  SkyMate
//
//  Created by Thomas Heinis on 07/07/2023.
//

import Foundation

final class NetworkManager {

  enum NetworkError: Error {
    case custom(error: Error)
    case failedToDecode(error: Error)
    case invalidData
    case invalidStatusCode(statusCode: Int)
    case invalidUrl
  }

  private var networkingSession = URLSession(configuration: .default)

  static let shared = NetworkManager()

  private init() {}

  init(networkingSession: URLSession) {
    self.networkingSession = networkingSession
  }

  func load<T: Decodable>(
    _ resource: Resource,
    sessionConfiguration: URLSessionConfiguration = .default,
    completion: @escaping (Result<T, Error>) -> Void
  ) {
    guard let resourceUrl = resource.url else {
      completion(.failure(NetworkError.invalidUrl))
      return
    }

    var request = URLRequest(url: resourceUrl)
    switch resource.method {
    case .get:
      var components = URLComponents(url: resourceUrl, resolvingAgainstBaseURL: true)
      components?.queryItems = resource.body.parameters
      request = URLRequest(url: components!.url!)

    case .post:
      request.httpBody = resource.body.data
    }

    request.allHTTPHeaderFields = resource.headers
    request.httpMethod = resource.method.rawValue

    let task = networkingSession.dataTask(with: request) { data, response, error in
      DispatchQueue.main.async {
        if let error {
          completion(.failure(NetworkError.custom(error: error)))
          return
        }

        guard let response = response as? HTTPURLResponse, (200...299) ~= response.statusCode else {
          guard let httpURLresponse = response as? HTTPURLResponse else { return }
          let statusCode = httpURLresponse.statusCode
          completion(.failure(NetworkError.invalidStatusCode(statusCode: statusCode)))
          return
        }

        guard let data = data else {
          completion(.failure(NetworkError.invalidData))
          return
        }

        do {
          let decoder = JSONDecoder()
          decoder.keyDecodingStrategy = .convertFromSnakeCase
          let result = try decoder.decode(T.self, from: data)
          completion(.success(result))
        } catch {
          completion(.failure(NetworkError.failedToDecode(error: error)))
        }
      }
    }
    task.resume()
  }
}
