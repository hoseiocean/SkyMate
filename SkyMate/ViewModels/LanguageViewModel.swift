//
//  LanguageViewModel.swift
//  SkyMate
//
//  Created by Thomas Heinis on 17/07/2023.
//

import Combine
import Foundation

/// `LanguageViewModel` is an observable object that provides a bridge between the user interface
/// and the underlying language data management provided by the `LanguageManager`.
final class LanguageViewModel: ObservableObject {

  // MARK: - Private properties

  private let languageManager = LanguageManager.shared

  private var cancellables = Set<AnyCancellable>()

  // MARK: - Public properties

  /// The current language setting of the application. This property is published
  /// so that any changes will update the user interface.
  @Published var currentLanguage: SupportedLanguage = .defaultLanguage

  // MARK: - Initializer

  /// Initializer that sets up the Combine pipeline.
  init() {
    languageManager.currentLanguage
      .receive(on: DispatchQueue.main)
      .sink { [weak self] language in
        guard let self else { return }
        self.currentLanguage = language
      }
      .store(in: &cancellables)
  }

  // MARK: - Public methods

  /// Changes the current language of the application.
  ///
  /// - Parameter newLanguage: The `SupportedLanguage` that the application should use.
  func changeLanguage(to newLanguage: SupportedLanguage) {
    languageManager.setLanguage(newLanguage)
  }
}
