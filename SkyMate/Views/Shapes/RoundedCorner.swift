//
//  RoundedCorner.swift
//  SkyMate
//
//  Created by Thomas Heinis on 14/07/2023.
//

import SwiftUI

/// `RoundedCorner` is a `Shape` that can create a rectangle with specific rounded corners.
struct RoundedCorner: Shape {

  // MARK: - Properties

  /// The radius to use when drawing the rounded corners.
  /// If this value is `.infinity`, the resulting shape is a capsule.
  var radius: CGFloat = .infinity

  /// The corners of a rectangle to apply the rounding to.
  var corners: UIRectCorner = .allCorners

  // MARK: - Path Drawing

  /// Creates and returns a new `Path` for the shape inside the specified rectangle.
  ///
  /// - Parameter rect: The rectangle to create the `Path` in.
  /// - Returns: The created `Path`.
  func path(in rect: CGRect) -> Path {
    let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
    return Path(path.cgPath)
  }
}
