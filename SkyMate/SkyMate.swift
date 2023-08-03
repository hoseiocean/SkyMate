//
//  SkyMate.swift
//  SkyMate
//
//  Created by Thomas Heinis on 11/06/2023.
//

import FirebaseCore
import SwiftUI

// MARK: - AppDelegate

/// `AppDelegate` acts as the delegate for the application, handling app lifecycle events.
class AppDelegate: NSObject, UIApplicationDelegate {

  // MARK: - AppDelegate

  /// This method is invoked when the application has completed its launch.
  /// It configures the Firebase services within the app.
  /// - Parameters:
  ///   - application: The singleton app object.
  ///   - launchOptions: A dictionary indicating the reason the app was launched (if any).
  /// - Returns: False if the app cannot handle the URL resource or continue a user activity,
  /// otherwise true.
  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    FirebaseApp.configure()
    return true
  }
}

// MARK: - Main App

/// `SkyMate` is the main SwiftUI application. It creates the window and root view and responds
/// to system events.
@main final class SkyMate: App {

  // MARK: - App body

  /// Defines the content and behavior for the app.
  var body: some Scene {
    WindowGroup {
      let contentView = ContentView()
        .environmentObject(RecognitionProvider.shared)
      contentView
    }
  }

  // MARK: - AppDelegate

  /// Adopts the `UIApplicationDelegate` protocol via the `AppDelegate` class.
  @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate

  // MARK: - RecognitionProvider

  /// An observed instance of `RecognitionProvider` which manages the recognition service.
  @ObservedObject private var recognitionProvider: RecognitionProvider

  // MARK: - Initialization

  /// Initializes a new instance of `SkyMate`, setting up the recognition provider and starts it.
  init() {
    self.recognitionProvider = RecognitionProvider.shared
    Task {
      await self.recognitionProvider.start()
    }
  }
}
