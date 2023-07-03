//
//  ButtonView.swift
//  SkyMate
//
//  Created by Thomas Heinis on 27/06/2023.
//

import SwiftUI

struct ButtonView: View {

  private let iconFrameHeight: CGFloat = 30.0
  private let flagFontSize: CGFloat = 56.0
  private let networkFontSize: CGFloat = 14.0

  @EnvironmentObject var recognitionProvider: RecognitionProvider
  @EnvironmentObject var recognitionObserver: RecognitionObserver

  @StateObject private var networkStatusMonitor = NetworkStatusMonitor()

  let gradient = LinearGradient(
    gradient: Gradient(
      colors: [
        Color(red: 20/255, green: 50/255, blue: 100/255),
        Color(red: 60/255, green: 120/255, blue: 180/255)
      ]),
    startPoint: .bottomLeading,
    endPoint: .topTrailing)

  @State private var bigCorner: CGFloat = 48
  @State private var littleCorner: CGFloat = 16
  @State private var showingLanguageActionSheet = false

  var body: some View {
    VStack(spacing: 16) {
      HStack(spacing: 16) {
        Button(action: {
          handleButton1()
        }) {
          VStack(alignment: .leading) {
            HStack {
              Image(systemName: recognitionObserver.isRecognizing ? Constant.Symbol.microphone : Constant.Symbol.mute)
                .resizable()
                .scaledToFit()
                .shadow(color: Color(red: 20/255, green: 40/255, blue: 80/255), radius: 1, x: 3, y: 3)
                .frame(height: iconFrameHeight)
              Spacer()
            }
            Spacer()
            Toggle(isOn: Binding(
              get: { self.recognitionObserver.isRecognizing },
              set: { _ in
                handleButton1()
              }
            )) {
              Text(recognitionObserver.isRecognizing ? ButtonText.listening.localized : "Off")
            }
          }
          .frame(maxWidth: .infinity, maxHeight: .infinity)
          .padding()
          .background(gradient)
          .cornerRadius(bigCorner, corners: [.bottomLeft, .topRight])
          .cornerRadius(littleCorner, corners: [.bottomRight, .topLeft])
        }

        Button(action: {
          handleButton2()
        }) {
          VStack {
            HStack {
              Image(systemName: Constant.Symbol.language)
                .resizable()
                .scaledToFit()
                .shadow(color: Color(red: 20/255, green: 40/255, blue: 80/255), radius: 1, x: 3, y: 3)
                .frame(height: iconFrameHeight)
              Spacer()
            }
            Spacer()
            Text(Constant.Symbol.languageFlag)
              .font(.system(size: flagFontSize))
              .frame(maxWidth: .infinity, maxHeight: .infinity) // Cela centre le Text dans la VStack
              .padding(.bottom, 8)
          }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
        .background(gradient)
        .cornerRadius(littleCorner, corners: [.bottomLeft, .topRight])
        .cornerRadius(bigCorner, corners: [.bottomRight, .topLeft])
      }
      HStack(spacing: 16) {
        Button(action: { }) {
          VStack {
            HStack {
              Image(systemName: networkStatusMonitor.isConnected ? "checkmark.icloud.fill" : "xmark.icloud.fill")
                .resizable()
                .scaledToFit()
                .shadow(color: Color(red: 20/255, green: 40/255, blue: 80/255), radius: 1, x: 3, y: 3)
                .frame(height: iconFrameHeight)
              Spacer()
            }
            Spacer()
            Text(networkStatusMonitor.isConnected ? "Online" : "Offline")
              .font(.system(size: networkFontSize))
              .frame(maxWidth: .infinity, maxHeight: .infinity)
          }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
        .background(gradient)
        .cornerRadius(bigCorner, corners: [.bottomRight, .topLeft])
        .cornerRadius(littleCorner, corners: [.bottomLeft, .topRight])

        Button(action: { }) {
          VStack {
            HStack {
              Image(systemName: Constant.Symbol.plane)
                .resizable()
                .scaledToFit()
                .shadow(color: Color(red: 20/255, green: 40/255, blue: 80/255), radius: 1, x: 3, y: 3)
                .frame(height: iconFrameHeight)
              Spacer()
            }
            Spacer()
            Text("DGAA")
          }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
        .background(gradient)
        .cornerRadius(littleCorner, corners: [.bottomRight, .topLeft])
        .cornerRadius(bigCorner, corners: [.bottomLeft, .topRight])
      }
    }
    .padding(.horizontal, 24)
    .padding(.top, 24)
    .padding(.bottom, 8)
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .onAppear {
      self.networkStatusMonitor.startMonitoring()
    }
    .actionSheet(isPresented: $showingLanguageActionSheet) {
      ActionSheet(title: Text(ButtonText.selectLanguage.localized), buttons: [
        .default(Text("English" + ((UserDefaults.standard.array(forKey: Constant.Key.preferredLanguageKey) as? [String])?.first == "en" ? " ✔️" : ""))) {
//                Localizer.switchToLanguage(.english)
            },
            .default(Text("French" + ((UserDefaults.standard.array(forKey: Constant.Key.preferredLanguageKey) as? [String])?.first == "fr" ? " ✔️" : ""))) {
//                Localizer.switchToLanguage(.french)
            },
            .default(Text("Spanish" + ((UserDefaults.standard.array(forKey: Constant.Key.preferredLanguageKey) as? [String])?.first == "es" ? " ✔️" : ""))) {
//                Localizer.switchToLanguage(.spanish)
            },
            .cancel()
        ])
    }
  }

  private func handleButton1() {
    if recognitionObserver.isRecognizing {
      recognitionProvider.recognitionManager?.stop()
    } else {
      recognitionProvider.recognitionManager?.start()
    }
  }

  private func handleButton2() {
    self.showingLanguageActionSheet = true
  }

  private func handleButton3() {
    // Code pour le bouton 3
  }

  private func handleButton4() {
    // Code pour le bouton 4
  }

  init() {
    _networkStatusMonitor = StateObject(wrappedValue: NetworkStatusMonitor())
  }

}

struct ButtonView_Previews: PreviewProvider {
  static var previews: some View {
    ButtonView()
  }
}
