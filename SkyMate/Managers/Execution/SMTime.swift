//
//  SMTime.swift
//  SkyMate
//
//  Created by Thomas Heinis on 08/07/2023.
//

import CoreLocation
import Foundation
import Solar

enum SMTimeError: Error {
  case failedToCalculateNauticalTwilightStart
  case failedToCalculateNauticalTwilightEnd
}

/// A structure representing nautical night information.
struct SMTime {

  private static let defaultLatitude: Double = 5.603849
  private static let defaultLongitude: Double = -0.168263

  /// Date formatter for converting dates to UTC time.
  private static let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.timeStyle = .short
    formatter.timeZone = TimeZone(identifier: "UTC")
    return formatter
  }()

  let latitude: Double
  let longitude: Double
  let nauticalSunriseUTC: Date?
  let nauticalSunsetUTC: Date?

  // MARK: - Initialization

  /// Initializes the AeronauticalNight structure with the provided latitude and longitude.
  ///
  /// - Parameters:
  ///   - latitude: The latitude of the location.
  ///   - longitude: The longitude of the location.
  init(latitude: Double, longitude: Double) throws {
    self.latitude = latitude
    self.longitude = longitude

    let location = CLLocation(latitude: latitude, longitude: longitude)

    guard let solar = Solar(for: Date(), coordinate: location.coordinate) else {
        throw SMTimeError.failedToCalculateNauticalTwilightStart
    }

    self.nauticalSunriseUTC = solar.nauticalSunrise
    self.nauticalSunsetUTC = solar.nauticalSunset
  }

  /// Initializes the AeronauticalNight structure with default latitude and longitude values.
  init() throws {
    try self.init(latitude: SMTime.defaultLatitude, longitude: SMTime.defaultLongitude)
  }

  // MARK: - Utility Methods

  /// The current time in UTC.
  static var currentUTCTime: Date {
    let now = Date()
    let nowComponents = Calendar.current.dateComponents(in: TimeZone(identifier: Const.Id.utc)!, from: now)
    return Calendar.current.date(from: nowComponents)!
  }

  /// Converts a date to UTC time.
  ///
  /// - Parameter date: The date to convert.
  /// - Returns: The UTC time representation of the date.
  func UTCTime(from date: Date) -> String {
    SMTime.dateFormatter.string(from: date)
  }

  /// Returns the time interval between the current time and the sunrise time.
  ///
  /// - Returns: The time interval in seconds.
  func timeIntervalToNauticalSunrise() -> TimeInterval? {
    guard let nauticalSunriseUTC else {
      return nil
    }
    let currentTime = SMTime.currentUTCTime
    return nauticalSunriseUTC.timeIntervalSince(currentTime)
  }

  /// Returns the time interval between the current time and the sunset time.
  ///
  /// - Returns: The time interval in seconds.
  func timeIntervalToNauticalSunset() -> TimeInterval? {
    guard let nauticalSunsetUTC else {
      return nil
    }
    let currentTime = SMTime.currentUTCTime
    return nauticalSunsetUTC.timeIntervalSince(currentTime)
  }
}
