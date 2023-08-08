//
//  DictionaryManagerTests.swift
//  SkyMateTests
//
//  Created by Thomas Heinis on 07/08/2023.
//

@testable import SkyMate
import XCTest

final class DictionaryManagerTests: XCTestCase {

  override func setUpWithError() throws {
    // Put setup code here. This method is called before the invocation of each test method in the class.
  }

  override func tearDownWithError() throws {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
  }

  func test_Deinit_ShouldClearsCache() {
    var deinitCalled = false
    var manager: DictionaryManager? = DictionaryManager()

    manager?.isTesting = true
    manager?.deinitCallback = {
      deinitCalled = true
    }

    manager = nil

    XCTAssertTrue(deinitCalled)
  }

  func test_LanguageDidChangeNotification_ClearsCache() {
    // Given: Remplissez le cache avec des données
    _ = try? DictionaryManager.shared.term(forKey: "someKey", ofType: .answer)

    // When: Envoyez la notification languageDidChange
    NotificationCenter.default.post(name: .languageDidChange, object: nil)

    // Then: Vérifiez si le cache est vidé
    let result = try? DictionaryManager.shared.term(forKey: "someKey", ofType: .answer)
    XCTAssertNil(result)
  }

  func test_FetchTermForKey_ShouldReturnExpectedTerm() throws {
    // Given
    let keyString = "OK"

    // When
    let result = try? DictionaryManager.shared.fetchTerm(forKey: keyString)

    // Then
    XCTAssertNotNil(result, "Result should not be nil for known key")
  }

  func test_FetchTermForFalseKey_ShouldReturnNil() throws {
    // Given
    let falseKeyString = "OKIDOKI"

    // When
    let result = try? DictionaryManager.shared.fetchTerm(forKey: falseKeyString)

    // Then
    XCTAssertNil(result, "Result should be nil for false key")
  }

  func test_FetchTermForKeyAndGivenType_ReturnsExpectedTerm() throws {
    // Given
    let keyString = "commande"
    let termType = SMTermType.command
    print("keyString", keyString)
    // When
    let result = try? DictionaryManager.shared.fetchTerm(forKey: keyString, ofType: termType)

    // Then
    XCTAssertNotNil(result, "Result should not be nil for known key")
  }

  func test_FetchTermForKeyAndGivenListOfTypes_ShouldReturnExpectedTerm() throws {

    // Given
    let keyString = "zulu"
    let termsTypesArray: [SMTermType] = [.answer, .letter]

    // When
    let result = try? DictionaryManager.shared.fetchTerm(forKey: keyString, ofExpectedTypes: termsTypesArray)

    // Then
    XCTAssertNotNil(result, "Result should not be nil for known key")
  }

  func test_FetchTermForKeyAndGivenListOfTypes_ShouldReturnNil() throws {

    // Given
    let keyString = "zulu"
    let termsTypesArray: [SMTermType] = [.command]

    // When
    let result = try? DictionaryManager.shared.fetchTerm(forKey: keyString, ofExpectedTypes: termsTypesArray)

    // Then
    XCTAssertNil(result, "Result should be nil for pair key / type")
  }

  func test_ContentForFalseLanguage_ShouldReturnNil() throws {
    DispatchQueue.main.async {
      let memorisedLanguage = LanguageManager.shared.currentLanguage.value

      // Given
      let falseLanguage: SupportedLanguage = .dummish
      LanguageManager.shared.setLanguage(falseLanguage)

      // When
      let result = try? DictionaryManager.shared.content(forSMTermType: .command, inLanguage: falseLanguage)

      // Then
      XCTAssertNil(result, "Result should be nil for false key")
      LanguageManager.shared.setLanguage(memorisedLanguage)
    }
  }

  func test_EmptyContentForLanguage_ShouldReturnNil() throws {
    DispatchQueue.main.async {
      let memorisedLanguage = LanguageManager.shared.currentLanguage.value

      // Given
      let language: SupportedLanguage = .spanish
      LanguageManager.shared.setLanguage(language)

      // When
      let result = try? DictionaryManager.shared.content(forSMTermType: .letter, inLanguage: language)

      // Then
      XCTAssertNil(result, "Result should be nil for false key")
      LanguageManager.shared.setLanguage(memorisedLanguage)
    }
  }
}
