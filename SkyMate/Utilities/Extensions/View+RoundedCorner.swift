//
//  View+RoundedCorner.swift
//  SkyMate
//
//  Created by Thomas Heinis on 14/07/2023.
//

import SwiftUI

extension View {

  func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
    clipShape(RoundedCorner(radius: radius, corners: corners))
  }
}
