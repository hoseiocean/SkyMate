//
//  Localizable.swift
//  SkyMate
//
//  Created by Thomas Heinis on 11/06/2023.
//

import Foundation

protocol Localizable {
  var localized: String { get }
}

extension Localizable where Self: RawRepresentable, Self.RawValue == String {
  var localized: String {
    NSLocalizedString(
      String(describing: Self.self) + Constant.Character.underscore + rawValue,
      tableName: nil,
      bundle: Bundle.main,
      value: Constant.Character.nothing,
      comment: Constant.Character.nothing
    )
  }
}

enum ScreenText: String, Localizable {
  case command
  case defaultMessage
}
