//
//  NetworkManager.swift
//  SkyMate
//
//  Created by Thomas Heinis on 07/07/2023.
//

import Foundation

// MARK: - NetworkManagerError

/// Errors that can occur in NetworkManager.
enum NetworkManagerError: Error {

  /// Custom error from URLSession.
  case custom(error: Error)

  /// Error when decoding fails.
  case failedToDecode(error: Error)

  /// Invalid data returned from URLSession.
  case invalidData

  /// Invalid HTTP status code returned from URLSession.
  case invalidStatusCode(statusCode: Int)

  /// Invalid URL for URLSession.
  case invalidUrl
}

// MARK: - NetworkManager

/// Singleton manager for handling network requests.
final class NetworkManager {

  private var networkingSession = URLSession(configuration: .default)

  /// Shared instance of NetworkManager.
  static let shared = NetworkManager()

  // MARK: - Initialization

  private init() {}

  /// Initializes a new NetworkManager with the provided URLSession.
  ///
  /// - Parameter networkingSession: The URLSession to use for network requests.
  init(networkingSession: URLSession) {
    self.networkingSession = networkingSession
  }

  // MARK: - Network Operations


  /// Loads a resource and calls a completion handler with the result.
  ///
  /// The completion handler is called with a `Result` containing either the requested resource
  /// decoded as type `T` if the request was successful, or an error.
  ///
  /// - Parameters:
  ///   - resource: The resource to load.
  ///   - sessionConfiguration: Configuration for the URLSession.
  ///   - completion: A closure that takes a `Result` and returns `Void`.
  func load<T: Decodable>(
    _ resource: Resource,
    sessionConfiguration: URLSessionConfiguration = .default,
    completion: @escaping (Result<T, Error>) -> Void
  ) {
    guard let resourceUrl = resource.url else {
      completion(.failure(NetworkManagerError.invalidUrl))
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
          completion(.failure(NetworkManagerError.custom(error: error)))
          return
        }

        guard let response = response as? HTTPURLResponse, (200...299) ~= response.statusCode else {
          guard let httpURLresponse = response as? HTTPURLResponse else { return }
          let statusCode = httpURLresponse.statusCode
          completion(.failure(NetworkManagerError.invalidStatusCode(statusCode: statusCode)))
          return
        }

        guard let data = data else {
          completion(.failure(NetworkManagerError.invalidData))
          return
        }

        do {
          let decoder = JSONDecoder()
          decoder.keyDecodingStrategy = .convertFromSnakeCase
          let result = try decoder.decode(T.self, from: data)
          completion(.success(result))
        } catch {
          completion(.failure(NetworkManagerError.failedToDecode(error: error)))
        }
      }
    }
    task.resume()
  }
}
