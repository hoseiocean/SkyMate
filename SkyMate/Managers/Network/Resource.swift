//
//  Resource.swift
//  SkyMate
//
//  Created by Thomas Heinis on 07/07/2023.
//

import Foundation

// MARK: - HTTPBody

/// The HTTPBody struct represents the data and parameters for an HTTP request.
struct HTTPBody {
  
  /// The body data to be included with the HTTP request.
  let data: Data?
  
  /// The parameters to be included in the query string for the HTTP request.
  let parameters: [URLQueryItem]?
}

// MARK: - HTTPMethod

/// The HTTPMethod enum represents the HTTP methods used in requests.
enum HTTPMethod: String {
  
  /// Represents an HTTP GET request.
  case get = "GET"
  
  /// Represents an HTTP POST request.
  case post = "POST"
}

// MARK: - Resource

/// The Resource struct represents an HTTP resource, which includes the URL, HTTP method, body
/// data, and headers for a request.
struct Resource {
  
  /// The URL of the resource.
  let url: URL!
  
  /// The HTTP method used for the request.
  let method: HTTPMethod
  
  /// The body of the request.
  let body: HTTPBody
  
  /// The HTTP headers to be included with the request.
  var headers: [String: String] = [:]
}
