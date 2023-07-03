//
//  ContentView.swift
//  SkyMate
//
//  Created by Thomas Heinis on 11/06/2023.
//

import SwiftUI

struct ContentView: View {
  @Environment(\.verticalSizeClass) var sizeClass
  @EnvironmentObject var recognitionProvider: RecognitionProvider
  @EnvironmentObject var recognitionObserver: RecognitionObserver
  @State private var termHistory: [String] = []
  @State private var selectedTab = 0

  var body: some View {
    NavigationView {
      VStack {
        carrouselView
        ButtonView()
      }
      .withCommonStyling()
      .onReceive(recognitionObserver.$term) { term in
        termHistory.append(term)
        withAnimation {
          selectedTab = termHistory.count - 1
        }
      }
    }
  }

  @ViewBuilder
  private var carrouselView: some View {
    let screenWidth = UIScreen.main.bounds.width
    TabView(selection: $selectedTab) {
      ForEach(termHistory.indices, id: \.self) { index in
        CardView(term: termHistory[index])
          .frame(width: screenWidth)
          .tag(index)
      }
    }
    .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
  }
}

private extension View {
  func withCommonStyling() -> some View {
    self
      .background(Color(red: 20/255, green: 40/255, blue: 80/255))
      .navigationBarTitle("Titre", displayMode: .large)
      .foregroundColor(.white)
      .navigationViewStyle(StackNavigationViewStyle())
      .accentColor(.white)
  }
}

struct CardView: View {
  let term: String

  var body: some View {
    VStack {
      Image(systemName: Constant.Symbol.globe)
        .imageScale(.large)
        .foregroundColor(.accentColor)
      Text(term)
    }
    .padding()
    .frame(maxWidth: .infinity)
    .background(
      RoundedRectangle(cornerRadius: 16)
        .fill(
          LinearGradient(
            gradient: Gradient(
              colors: [
                Color(red: 20/255, green: 50/255, blue: 100/255),
                Color(red: 60/255, green: 120/255, blue: 180/255)
              ]
            ),
            startPoint: .bottomLeading,
            endPoint: .topTrailing
          )
        )
    )
    .padding(24)
  }
}



struct DisplayView: View {
  @EnvironmentObject var recognitionObserver: RecognitionObserver

  var body: some View {
    GeometryReader { geometry in
      VStack {
        Image(systemName: Constant.Symbol.globe)
          .imageScale(.large)
          .foregroundColor(.accentColor)
        Text(recognitionObserver.term)
      }
      .frame(maxWidth: .infinity, maxHeight: .infinity)
      .background(
        RoundedRectangle(cornerRadius: 16)
          .fill(LinearGradient(
            gradient: Gradient(
              colors: [
                Color(red: 20/255, green: 50/255, blue: 100/255),
                Color(red: 60/255, green: 120/255, blue: 180/255)
              ]
            ),
            startPoint: .bottomLeading,
            endPoint: .topTrailing
          ))
      )
      .padding(24)
      .frame(width: geometry.size.width, height: geometry.size.height)
    }
  }
}

extension View {
  func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
    clipShape(RoundedCorner(radius: radius, corners: corners))
  }
}

struct RoundedCorner: Shape {
  var radius: CGFloat = .infinity
  var corners: UIRectCorner = .allCorners

  func path(in rect: CGRect) -> Path {
    let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
    return Path(path.cgPath)
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    return ContentView().environmentObject(RecognitionObserver())
  }
}
