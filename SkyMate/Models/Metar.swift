//
//  Metar.swift
//  SkyMate
//
//  Created by Thomas Heinis on 12/07/2023.
//

/// `Metar` is a structure that represents a METAR weather report.
struct Metar: Codable {

  // MARK: - Properties

  /// An array of data strings, each representing a unique piece of METAR information.
  let data: [String]

  /// The total number of METAR data results.
  let results: Int
}
