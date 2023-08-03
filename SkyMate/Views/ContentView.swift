//
//  ContentView.swift
//  SkyMate
//
//  Created by Thomas Heinis on 11/06/2023.
//

import SwiftUI

struct ContentView: View {

  // MARK: - Properties

  @StateObject private var viewModel = CarrouselViewModel.shared

  /// The current color scheme of the device
  @Environment(\.colorScheme) var colorScheme

  /// The current vertical size class of the device
  @Environment(\.verticalSizeClass) var verticalSizeClass

  // MARK: - Body

  /// The main body of the ContentView
  var body: some View {
    ZStack {
      if colorScheme == .light {
        LinearGradient(
          gradient: Gradient(
            stops: [
              .init(color: .lightSMBlue, location: 0),
              .init(color: .darkSMBlue, location: 0.3)
            ]
          ),
          startPoint: .top, endPoint: .bottom
        )
        .edgesIgnoringSafeArea(.all)
      } else {
        LinearGradient(
          gradient: Gradient(
            stops: [
              .init(color: .darkSMBlue, location: 0),
              .init(color: .black, location: 0.3)
            ]
          ),
          startPoint: .top, endPoint: .bottom
        )
        .edgesIgnoringSafeArea(.all)
      }

      // MARK: - Main Content

      Group {
        if verticalSizeClass == .compact {
          // Portrait orientation
          HStack {
            carrouselView
            ButtonView()
          }
        } else {
          // Landscape orientation
          VStack {
            carrouselView
            ButtonView()
          }
        }
      }
      .environmentObject(viewModel)
    }
  }

  // MARK: - Carrousel View

  private var carrouselView: some View {
    GeometryReader { geometry in
      ScrollViewReader { reader in
        ScrollView(.horizontal, showsIndicators: false) {
          LazyHStack(spacing: 20) {
            ForEach(viewModel.cards.indices, id: \.self) { index in
              CardView(card: viewModel.cards[index])
                .id(index)
                .frame(width: geometry.size.width)
                .tag(index)
            }
          }
          .onChange(of: viewModel.cards.count) { value in
            withAnimation {
              reader.scrollTo(viewModel.cards.count - 1, anchor: .trailing)
            }
          }
        }
      }
    }
  }
}

// MARK: - Preview

/// Provides a preview of the ContentView in light and dark modes.
struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    Group {
      ContentView()
      ContentView()
        .environment(\.colorScheme, .dark)
    }
  }
}
