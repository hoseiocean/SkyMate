//
//  StringDictionary+KeyMatching.swift
//  SkyMate
//
//  Created by Thomas Heinis on 15/06/2023.
//

import Foundation

extension Dictionary<String, String> {

  /// This method is used to find a key or its prefix in the dictionary.
  /// - Parameters:
  ///   - searchString: The string to be searched in the keys.
  ///   - normalize: A boolean to determine if the search is case sensitive. Default is true.
  /// - Returns: A tuple with the found string and a boolean indicating if the match is a prefix.
  func searchForKeyOrPrefix(like searchString: String, normalize: Bool = true) -> (value: String?, foundPrefix: Bool) {
    let normalizedSearchString = normalize ? searchString.normalized : searchString

    var foundPrefix = false

    let matchingKey = keys.first(where: { key in
      let normalizedKey = normalize ? key.normalized : key

      if normalizedKey.hasPrefix(normalizedSearchString) {
        foundPrefix = true
        return normalizedKey == normalizedSearchString
      }

      return false
    })

    if let matchingKey {
      return (self[matchingKey], foundPrefix)
    }

    return (nil, foundPrefix)
  }

}
