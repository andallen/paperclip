//
//  InkOSUITests.swift
//  InkOSUITests
//
//  Created by Andrew Allen on 12/23/25.
//

import XCTest

final class InkOSUITests: XCTestCase {

  override func setUpWithError() throws {
    // Put setup code here before each test method runs.

    // In UI tests it is usually best to stop immediately when a failure occurs.
    continueAfterFailure = false

    // Set the initial UI state required for tests before they run.
  }

  override func tearDownWithError() throws {
    // Put teardown code here after each test method finishes.
  }

  @MainActor
  func testExample() throws {
    let app = XCUIApplication()
    app.activate()
    app.scrollViews.firstMatch.tap()
    app.windows.firstMatch.swipeDown()
  }

  // @MainActor
  // func testLaunchPerformance() throws {
  //     // This measures how long it takes to launch your application.
  //     measure(metrics: [XCTApplicationLaunchMetric()]) {
  //         XCUIApplication().launch()
  //     }
  // }
}
