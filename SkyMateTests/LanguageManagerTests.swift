//
//  LanguageManagerTests.swift
//  SkyMateTests
//
//  Created by Thomas Heinis on 07/08/2023.
//

@testable import SkyMate
import XCTest

final class LanguageManagerTests: XCTestCase {
  weak var weakLanguageManager: LanguageManager?
  
  func testLanguageManagerDeinit() {
    DispatchQueue.main.async {
      // Create an autoreleasepool to catch any lingering references.
      autoreleasepool {
        let languageManager = LanguageManager()
        self.weakLanguageManager = languageManager
      }
      
      // At this point, if there are no strong references to languageManager, it should be nil.
      XCTAssertNil(self.weakLanguageManager, "LanguageManager was not deallocated!")
    }
  }
}
