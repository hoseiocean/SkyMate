//
//  ButtonView.swift
//  SkyMate
//
//  Created by Thomas Heinis on 27/06/2023.
//

import SwiftUI

/// Represents the state of a speech recognition button.
enum SpeechRecognitionButtonState {
  case normal, processed, found, fail
}

// MARK: - Button View

/// A SwiftUI View representing a collection of control buttons with various functionalities.
struct ButtonView: View {

  // MARK: - Properties

  private let buttonsPadding: CGFloat = 16.0
  private let buttonsSpacing: CGFloat = 12.0
  private let iconFrameHeight: CGFloat = 36.0
  private let flagFontSize: CGFloat = 36.0
  private let networkFontSize: CGFloat = 14.0

  @State private var bigCorner: CGFloat = 36.0
  @State private var buttonState: SpeechRecognitionButtonState = .normal
  @ObservedObject private var languageViewModel = LanguageViewModel()
  @State private var littleCorner: CGFloat = 12.0
  @State private var lockState: Bool = false
  @StateObject private var networkStatusMonitor = NetworkStatusMonitor()
  @State private var showingLanguageActionSheet = false

  /// The recognition provider for the speech functionality.
  @EnvironmentObject var recognitionProvider: RecognitionProvider

  /// The current vertical size class of the device.
  @Environment(\.verticalSizeClass) var verticalSizeClass

  // MARK: - Body

  /// Defines the content and behavior of the view.
  var body: some View {
    VStack(spacing: buttonsSpacing) {
      HStack(spacing: buttonsSpacing) {

        // MARK: - Airport

        Button(action: { }) {
          VStack {
            HStack {
              Image(systemName: Const.Symbol.plane)
                .resizable()
                .scaledToFit()
                .frame(height: iconFrameHeight)
                .foregroundColor(Color(Const.Color.buttonIcon))
              Spacer()
            }
            Spacer()
            Text("DGAA")
              .foregroundColor(Color(Const.Color.buttonIcon))
          }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
        .background(Color(Const.Color.buttonBackGround))
        .cornerRadius(littleCorner, corners: [.bottomRight, .topLeft])
        .cornerRadius(bigCorner, corners: [.bottomLeft, .topRight])
        .buttonStyle(PlainButtonStyle())

        // MARK: - Speech Recognition

        Button(action: { toggleListening() }) {
          VStack(alignment: .leading) {
            HStack {
              Image(systemName: isListening() ? Const.Symbol.microphone : Const.Symbol.mute)
                .resizable()
                .scaledToFit()
                .frame(height: iconFrameHeight)
                .foregroundColor(textColor(for: buttonState))
              Spacer()
            }
            Spacer()
            Toggle(isOn: Binding(
              get: { self.isListening() },
              set: { _ in
                self.toggleListening()
              }
            )) {
              Text(self.isListening() ? ButtonText.listening.localized : ButtonText.off.localized)
                .foregroundColor(textColor(for: buttonState))
            }
            .toggleStyle(SwitchToggleStyle(tint: toggleColor(for: buttonState)))
          }
          .frame(maxWidth: .infinity, maxHeight: .infinity)
          .padding()
          .background(backgroundColor(for: buttonState))
          .cornerRadius(bigCorner, corners: [.bottomRight, .topLeft])
          .cornerRadius(littleCorner, corners: [.bottomLeft, .topRight])
          .buttonStyle(PlainButtonStyle())
        }
        .onReceive(NotificationCenter.default.publisher(for: .transcriptionDidFoundTerm)) { _ in
          withAnimation {
            self.buttonState = .found
            self.lockState = true

            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
              withAnimation {
                self.buttonState = .normal
                self.lockState = false
              }
            }
          }
        }
        .onReceive(NotificationCenter.default.publisher(for: .didProcessedTranscription)) { _ in
          guard !self.lockState else { return }
          withAnimation {
            self.buttonState = .processed
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.07) {
              withAnimation {
                self.buttonState = .normal
              }
            }
          }
        }
      }
      HStack(spacing: buttonsSpacing) {

        // MARK: - Network

        Button(action: { }) {
          VStack {
            HStack {
              Image(systemName: networkStatusMonitor.isConnected ? Const.Symbol.online : Const.Symbol.offline)
                .resizable()
                .scaledToFit()
                .frame(height: iconFrameHeight)
                .foregroundColor(Color(Const.Color.buttonIcon))
              Spacer()
            }
            Spacer()
            Toggle(isOn: Binding(
              get: { self.networkStatusMonitor.isConnected },
              set: { _ in }
            )) {
              Text(networkStatusMonitor.isConnected ? ButtonText.online.localized : ButtonText.offline.localized)
                .foregroundColor(Color(Const.Color.buttonIcon))
            }
            .toggleStyle(SwitchToggleStyle(tint: Color(Const.Color.buttonIcon)))
            .disabled(true)
          }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
        .background(Color(Const.Color.buttonBackGround))
        .cornerRadius(bigCorner, corners: [.bottomRight, .topLeft])
        .cornerRadius(littleCorner, corners: [.bottomLeft, .topRight])
        .buttonStyle(PlainButtonStyle())
        .onAppear {
          self.networkStatusMonitor.startMonitoring()
        }

        // MARK: - Language

        Button(action: { self.showingLanguageActionSheet = true }) {
          VStack {
            HStack {
              Image(systemName: Const.Symbol.language)
                .resizable()
                .scaledToFit()
                .frame(height: iconFrameHeight)
                .foregroundColor(Color(Const.Color.buttonIcon))
              Spacer()
            }
            Spacer()
            Text(ButtonText.languageFlag.localized)
              .font(.system(size: flagFontSize))
              .frame(maxWidth: .infinity, maxHeight: .infinity)
          }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
        .background(Color(Const.Color.buttonBackGround))
        .cornerRadius(littleCorner, corners: [.bottomRight, .topLeft])
        .cornerRadius(bigCorner, corners: [.bottomLeft, .topRight])
        .actionSheet(isPresented: $showingLanguageActionSheet) {
          let languageButtons = SupportedLanguage.allCases
            .map { ($0, self.getLocalizedName(for: $0) ?? Const.Char.none) }
            .sorted { $0.1 < $1.1 }
            .compactMap { createLanguageButton(for: $0.0) }
          let cancelButton = ActionSheet.Button.cancel(Text(MenuText.cancel.localized)) {}
          let actionSheetButtons = languageButtons + [cancelButton]
          return ActionSheet(title: Text(MenuText.selectLanguage.localized), buttons: actionSheetButtons)
        }
      }
    }
    .padding(.bottom, verticalSizeClass == .compact ? buttonsPadding : buttonsPadding / 2)
    .padding(.leading, verticalSizeClass == .compact ? .zero : buttonsPadding)
    .padding(.top, verticalSizeClass == .compact ? buttonsPadding : .zero)
    .padding(.trailing, buttonsPadding)
    .frame(maxWidth: .infinity, maxHeight: .infinity)
  }

  // MARK: - Initializer

  /// Creates a new instance of ButtonView.
  init() {
    _networkStatusMonitor = StateObject(wrappedValue: NetworkStatusMonitor())
  }

  // MARK: - Private Helper Functions

  private func checkmarkOrNothing(for language: SupportedLanguage) -> String {
    languageViewModel.currentLanguage == language ? Const.Char.check : Const.Char.none
  }

  private func backgroundColor(for state: SpeechRecognitionButtonState) -> Color {
    switch state {
    case .normal, .fail:
      return Color(Const.Color.buttonBackGround)
    case .processed:
      return Color(Const.Color.buttonIcon)
    case .found:
      return Color(Const.Color.backgroundWhenRequestSuccessfullyExecuted)
    }
  }

  private func textColor(for state: SpeechRecognitionButtonState) -> Color {
    switch state {
    case .normal, .fail:
      return Color(Const.Color.buttonIcon)
    case .processed:
      return Color(Const.Color.buttonBackGround)
    case .found:
      return Color(Const.Color.foregroundWhenRequestSuccesfullyExecuted)
    }
  }

  private func toggleColor(for state: SpeechRecognitionButtonState) -> Color {
    switch state {
    case .normal, .processed, .fail:
      return Color(Const.Color.buttonIcon)
    case .found:
      return Color(Const.Color.foregroundWhenRequestSuccesfullyExecuted)
    }
  }

  private func createLanguageButton(for language: SupportedLanguage) -> ActionSheet.Button? {
    guard let languageName = getLocalizedName(for: language) else { return nil }
    return .default(Text(languageName + checkmarkOrNothing(for: language))) {
      languageViewModel.changeLanguage(to: language)
    }
  }

  private func getLocalizedName(for language: SupportedLanguage) -> String? {
    guard let languageName = MenuText(rawValue: String(describing: language)) else { return nil }
    return languageName.localized
  }

  private func isListening() -> Bool {
    recognitionProvider.isListening()
  }

  private func toggleListening() {
    do {
      if isListening() {
        try recognitionProvider.stopListening()
      } else {
        try recognitionProvider.startListening()
      }
    } catch {
      // TODO: manage errors
    }
  }
}

// MARK: - Preview Provider

/// A structure that adapts a custom View for Xcode’s canvas previews.
struct ButtonView_Previews: PreviewProvider {
  static var previews: some View {
    ButtonView()
  }
}
