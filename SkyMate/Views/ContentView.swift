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
  //  @State private var isListening: Bool = false
  @EnvironmentObject var recognitionObserver: RecognitionObserver
  //  @State var selectedTab: Int = 0

  var body: some View {
    NavigationView {
      Group {
        if sizeClass == .compact {
          // Paysage
          HStack {
            DisplayView()
            ButtonView()
          }
        } else {
          // Portrait
          VStack {
            DisplayView()
            ButtonView()
          }
        }
      }
      .background(Color(red: 20/255, green: 40/255, blue: 80/255))
      .navigationBarTitle("Titre", displayMode: .large)
      .foregroundColor(.white)
    }
    .navigationViewStyle(StackNavigationViewStyle())
    .accentColor(.white)
//    .statusBarStyle(.lightContent)
  }

  init() {
      let appearance = UINavigationBarAppearance()
      appearance.configureWithOpaqueBackground()
      appearance.backgroundColor = UIColor(red: 20/255, green: 40/255, blue: 80/255, alpha: 1)
      appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
      appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]

      UINavigationBar.appearance().standardAppearance = appearance
      UINavigationBar.appearance().scrollEdgeAppearance = appearance
  }
}

//var body: some View {
//  .padding()
//  NavigationView {
//    TabView(selection: Binding(
//      get: { selectedTab },
//      set: {
//        selectedTab = $0
//        if selectedTab == 1 {
//          toggleListening()
//        }
//      }
//    )) {
//      Text(recognitionObserver.isRecognizing ? "Recognizing" : "Manual")
//        .tabItem {
//          Label(recognitionObserver.isRecognizing ? "Recognizing" : "Manual", systemImage: recognitionObserver.isRecognizing ? Constant.Symbol.microphone : Constant.Symbol.keyboard)
//            .tint(recognitionObserver.isRecognizing ? .green : .red)
//        }
//        .tag(1)
//      Text("View Two")
//        .tabItem {
//          Label(Locale.preferredLanguages[0], systemImage: "flag")
//        }
//        .tag(2)
//      Text("View Three")
//        .tabItem { Text("3") }
//        .tag(3)
//    }
//  }
//}
//
//private func toggleListening() {
//  if recognitionManagerProvider.recognitionObserver.isRecognizing {
//    recognitionManagerProvider.recognitionManager?.stop()
//  } else {
//    recognitionManagerProvider.recognitionManager?.start()
//  }
//}
//}

struct DisplayView: View {
  @EnvironmentObject var recognitionObserver: RecognitionObserver

  var body: some View {
    VStack {
      Image(systemName: Constant.Symbol.globe)
        .imageScale(.large)
        .foregroundColor(.accentColor)
      Text(recognitionObserver.term)
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
  }
}

struct ButtonView: View {

  let gradient = LinearGradient(
    gradient: Gradient(
      colors: [
        Color(red: 20/255, green: 50/255, blue: 100/255),
        Color(red: 60/255, green: 120/255, blue: 180/255)
      ]),
    startPoint: .bottomLeading,
    endPoint: .topTrailing)

  @State var bigCorner: CGFloat = 48
  @State var littleCorner: CGFloat = 16

  var body: some View {
    VStack(spacing: 16) {
      HStack(spacing: 16) {
        ForEach(1...2, id: \.self) { index in
          Button(action: {}) {
            Text("Bouton \(index)")
          }
          .frame(maxWidth: .infinity, maxHeight: .infinity)
          .background(gradient)
          .cornerRadius(index % 2 == 1 ? bigCorner : littleCorner, corners: [.bottomLeft, .topRight])
          .cornerRadius(index % 2 == 0 ? bigCorner : littleCorner, corners: [.bottomRight, .topLeft])
        }
      }
      HStack(spacing: 16) {
        ForEach(3...4, id: \.self) { index in
          Button(action: {}) {
            Text("Bouton \(index)")
          }
          .frame(maxWidth: .infinity, maxHeight: .infinity)
          .background(gradient)
          .cornerRadius(index % 2 == 0 ? bigCorner : littleCorner, corners: [.bottomLeft, .topRight])
          .cornerRadius(index % 2 == 1 ? bigCorner : littleCorner, corners: [.bottomRight, .topLeft])
        }
      }
    }
    .padding(.horizontal, 24)
    .padding(.top, 24)
    .padding(.bottom, 8)
    .frame(maxWidth: .infinity, maxHeight: .infinity)
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
