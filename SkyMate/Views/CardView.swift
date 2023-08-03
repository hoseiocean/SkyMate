//
//  CardView.swift
//  SkyMate
//
//  Created by Thomas Heinis on 10/07/2023.
//

import Combine
import SwiftUI

/// `CardView` is a view that presents a card with its contents and title.
struct CardView: View {

  // MARK: - Configuration Struct

  private struct Config {
    static let cardViewPadding: CGFloat = 16.0
    static let cardViewCornerRadius: CGFloat = 16.0
  }

  // MARK: - Properties

  /// The card object to be displayed by the CardView.
  @ObservedObject var card: Card

  // MARK: - Body

  var body: some View {
    RoundedRectangle(cornerRadius: Config.cardViewCornerRadius)
      .fill(Color.gray)
      .frame(maxWidth: .infinity, maxHeight: .infinity)
      .padding(Config.cardViewPadding)
      .shadow(color: Color(Const.Color.shadow).opacity(1), radius: 6, x: 0, y: 6)
      .overlay(
        GeometryReader { geometry in
          VStack(spacing: 0) {

            // MARK: - Card Content

            VStack {
              Text(card.content)
                .font(.title2.monospacedDigit())
                .fontWeight(.regular)
                .foregroundColor(Color(Const.Color.cardText))
            }
            .frame(maxWidth: geometry.size.width, maxHeight: geometry.size.height * 0.85)
            .background(Color(Const.Color.cardBackground))
            .clipShape(RoundedCorner(radius: Config.cardViewCornerRadius, corners: [.topLeft, .topRight]))
            .padding([.leading, .top, .trailing], Config.cardViewPadding)

            // MARK: - Card Title

            VStack {
              Text(card.title)
                .font(.system(size: 18.0, weight: .semibold))
                .foregroundColor(Color(Const.Color.titleText))
            }
            .frame(maxWidth: .infinity, maxHeight: geometry.size.height * 0.2)
            .background(Color(Const.Color.titleBackground))
            .clipShape(RoundedCorner(radius: Config.cardViewCornerRadius, corners: [.bottomLeft, .bottomRight]))
            .padding([.bottom, .leading, .trailing], Config.cardViewPadding)
          }
        }
      )
  }
}
