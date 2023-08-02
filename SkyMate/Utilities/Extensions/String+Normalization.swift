//
//  String+Normalization.swift
//  SkyMate
//
//  Created by Thomas Heinis on 11/06/2023.
//

extension String {

  /// A normalized version of the string.
  ///
  /// The normalized version of the string is computed by:
  ///   - Replacing any diacritic marks with their non-diacritic equivalents.
  ///   - Lowercasing the string.
  ///   - Replacing all spaces with nothing.
  ///   - Trimming white spaces and new lines at the start and end of the string.
  var normalized: String {
    self
      .folding(options: .diacriticInsensitive, locale: .current)
      .lowercased()
      .replacingOccurrences(of: Const.Char.space, with: Const.Char.none)
      .trimmingCharacters(in: .whitespacesAndNewlines)
  }
}
