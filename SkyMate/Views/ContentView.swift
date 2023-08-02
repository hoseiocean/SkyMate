//
//  ContentView.swift
//  SkyMate
//
//  Created by Thomas Heinis on 11/06/2023.
//

import SwiftUI

struct ContentView: View {

  @StateObject private var viewModel = CarrouselViewModel.shared

  @Environment(\.colorScheme) var colorScheme
  @Environment(\.verticalSizeClass) var verticalSizeClass

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

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    Group {
      ContentView()
//        .environmentObject(CommandProcessor.shared)
      ContentView()
//        .environmentObject(CommandProcessor.shared)
        .environment(\.colorScheme, .dark)
    }
  }
}
