//
// InkOSUITests.swift
// InkOSUITests
//
// Basic UI tests for the digital paper canvas.
//

import XCTest

final class InkOSUITests: XCTestCase {
  var app: XCUIApplication!

  override func setUpWithError() throws {
    continueAfterFailure = false
    app = XCUIApplication()
    app.launch()
  }

  // MARK: - Basic Launch

  func testAppLaunch() throws {
    // Verify the canvas is present.
    let canvas = app.otherElements["note_canvas"]
    XCTAssertTrue(canvas.waitForExistence(timeout: 5), "Canvas should exist")
  }

  // MARK: - Sidebar

  func testSidebarOpensAndCloses() throws {
    // Open sidebar.
    let hamburger = app.buttons["hamburger_open_button"]
    XCTAssertTrue(hamburger.waitForExistence(timeout: 5))
    hamburger.tap()

    // Verify sidebar is visible.
    let sidebar = app.otherElements["sidebar_view"]
    XCTAssertTrue(sidebar.waitForExistence(timeout: 3))

    // Close sidebar.
    let close = app.buttons["sidebar_hamburger_close"]
    XCTAssertTrue(close.exists)
    close.tap()
  }

  // MARK: - Send Button

  func testSendButtonExistsAndDisabledWhenEmpty() throws {
    // The send button should exist but be disabled on an empty canvas.
    let send = app.buttons["send_button"]
    XCTAssertTrue(send.waitForExistence(timeout: 5))
    XCTAssertFalse(send.isEnabled, "Send should be disabled on empty canvas")
  }
}
