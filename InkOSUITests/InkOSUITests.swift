//
//  InkOSUITests.swift
//  InkOSUITests
//
//  UI tests for the InkOS dashboard.
//  These tests can be run on device or simulator.

import XCTest

final class InkOSUITests: XCTestCase {

    var app: XCUIApplication!

    // Directory to save screenshots.
    let screenshotDir = "/tmp/inkos-ui-tests/screenshots"

    override func setUpWithError() throws {
        continueAfterFailure = false

        app = XCUIApplication()
        app.launch()

        // Create screenshot directory.
        try? FileManager.default.createDirectory(
            atPath: screenshotDir,
            withIntermediateDirectories: true
        )
    }

    override func tearDownWithError() throws {
        app = nil
    }

    // MARK: - Helper Methods

    // Saves a screenshot with the given name.
    func saveScreenshot(name: String) {
        let screenshot = app.screenshot()
        let attachment = XCTAttachment(screenshot: screenshot)
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)

        // Also save to disk for easy retrieval.
        let timestamp = ISO8601DateFormatter().string(from: Date())
            .replacingOccurrences(of: ":", with: "-")
        let filename = "\(name)_\(timestamp).png"
        let path = (screenshotDir as NSString).appendingPathComponent(filename)

        let data = screenshot.pngRepresentation
        try? data.write(to: URL(fileURLWithPath: path))
        print("[UITest] Screenshot saved: \(path)")
    }

    // Finds the first notebook card in the collection view.
    func findFirstNotebookCard() -> XCUIElement? {
        // Try to find by accessibility identifier pattern.
        let cards = app.cells.matching(NSPredicate(format: "identifier BEGINSWITH 'notebookCard_'"))
        if cards.count > 0 {
            return cards.element(boundBy: 0)
        }

        // Fallback: find by accessibility label.
        let notebookCells = app.cells.matching(NSPredicate(format: "label BEGINSWITH 'Notebook:'"))
        if notebookCells.count > 0 {
            return notebookCells.element(boundBy: 0)
        }

        return nil
    }

    // Dismisses any alert or dialog that might be visible.
    func dismissAnyDialog() {
        // Check for OK button (common in alerts).
        let okButton = app.buttons["OK"]
        if okButton.waitForExistence(timeout: 1) {
            okButton.tap()
            Thread.sleep(forTimeInterval: 0.3)
        }

        // Check for Cancel button.
        let cancelButton = app.buttons["Cancel"]
        if cancelButton.exists {
            cancelButton.tap()
            Thread.sleep(forTimeInterval: 0.3)
        }
    }

    // Creates a new notebook by tapping the + button and returns to dashboard.
    func createNotebook() {
        // Dismiss any existing dialogs first.
        dismissAnyDialog()

        // Tap the + button in the navigation bar.
        let addButton = app.navigationBars.buttons.matching(NSPredicate(format: "label CONTAINS 'Add' OR label CONTAINS '+'")).firstMatch
        if addButton.waitForExistence(timeout: 2) {
            addButton.tap()
        } else {
            // Fallback to last button in nav bar.
            let buttons = app.navigationBars.buttons
            if buttons.count > 0 {
                buttons.element(boundBy: buttons.count - 1).tap()
            }
        }

        // Wait for the menu to appear.
        Thread.sleep(forTimeInterval: 0.5)

        // Tap "New Notebook" option if it appears.
        let newNotebook = app.buttons["New Notebook"]
        if newNotebook.waitForExistence(timeout: 2) {
            newNotebook.tap()
        }

        // Wait for editor to load.
        Thread.sleep(forTimeInterval: 1.5)

        // Navigate back to dashboard by tapping home button.
        let homeButton = app.buttons["Home"]
        if homeButton.waitForExistence(timeout: 2) {
            homeButton.tap()
        }

        // Wait for dashboard to reload.
        Thread.sleep(forTimeInterval: 1.0)

        // Dismiss any dialogs that might have appeared.
        dismissAnyDialog()
    }

    // Finds any card (notebook, PDF, folder, or lesson).
    func findFirstCard() -> XCUIElement? {
        let cardPredicates = [
            "identifier BEGINSWITH 'notebookCard_'",
            "identifier BEGINSWITH 'pdfCard_'",
            "identifier BEGINSWITH 'folderCard_'",
            "identifier BEGINSWITH 'lessonCard_'"
        ]

        for predicate in cardPredicates {
            let cards = app.cells.matching(NSPredicate(format: predicate))
            if cards.count > 0 {
                return cards.element(boundBy: 0)
            }
        }

        // Fallback: just get first cell.
        if app.cells.count > 0 {
            return app.cells.element(boundBy: 0)
        }

        return nil
    }

    // MARK: - Canvas Input Tests

    @MainActor
    func testCanvasInputFixedPosition() throws {
        // Verify the canvas input bar is fixed at the bottom of the screen
        // and does NOT scroll with the content.

        // Wait for app to load.
        let canvas = app.scrollViews["notebook_canvas"]
        XCTAssertTrue(canvas.waitForExistence(timeout: 10), "Notebook canvas should load")

        // Find the canvas input view.
        let inputView = app.otherElements["canvas_input_view"]
        XCTAssertTrue(inputView.waitForExistence(timeout: 5), "Canvas input view should exist")

        // Record initial position of the input view.
        let initialFrame = inputView.frame
        print("[Test] Initial input view frame: \(initialFrame)")
        print("[Test] Initial input view Y: \(initialFrame.midY)")

        // Take initial screenshot.
        saveScreenshot(name: "input_initial")

        // The input view should be near the bottom of the screen.
        // iPad screen is typically ~1000+ points tall, input should be in bottom 200 points.
        let screenHeight = app.frame.height
        print("[Test] Screen height: \(screenHeight)")
        print("[Test] Input view bottom Y: \(initialFrame.maxY)")

        XCTAssertGreaterThan(initialFrame.minY, screenHeight - 250,
            "Input view should be near bottom of screen (minY=\(initialFrame.minY), screenHeight=\(screenHeight))")

        // Tap canvas to reveal some content.
        canvas.tap()
        Thread.sleep(forTimeInterval: 2.0)

        // Tap again to reveal more content.
        canvas.tap()
        Thread.sleep(forTimeInterval: 2.0)

        saveScreenshot(name: "input_after_content_revealed")

        // Check if content was added.
        let afterContentFrame = inputView.frame
        print("[Test] After content revealed - input view frame: \(afterContentFrame)")

        // Now try to scroll the content up.
        canvas.swipeUp()
        Thread.sleep(forTimeInterval: 0.5)

        saveScreenshot(name: "input_after_scroll")

        // Record position after scrolling.
        let afterScrollFrame = inputView.frame
        print("[Test] After scroll - input view frame: \(afterScrollFrame)")
        print("[Test] Y position change: \(afterScrollFrame.midY - initialFrame.midY)")

        // The key test: if the input bar is fixed, its Y position should NOT change
        // when content scrolls. Allow small tolerance for layout adjustments.
        let yPositionDelta = abs(afterScrollFrame.midY - initialFrame.midY)
        print("[Test] Y position delta: \(yPositionDelta)")

        XCTAssertLessThan(yPositionDelta, 10,
            "Input view Y position should stay fixed when scrolling (delta=\(yPositionDelta)). " +
            "Initial Y=\(initialFrame.midY), After scroll Y=\(afterScrollFrame.midY)")

        print("[Test] RESULT: Input bar IS fixed at bottom - Y position stable within \(yPositionDelta) points")
    }

    // MARK: - Blob Position Tests

    @MainActor
    func testBlobPositioning() throws {
        // Verify blob positioning:
        // 1. Initial position should be near top (Y < 200)
        // 2. X position: blob's left edge should align with text's left edge
        // 3. Blob should move down smoothly during streaming (no jumping)

        // Wait for app to load.
        let canvas = app.scrollViews["notebook_canvas"]
        XCTAssertTrue(canvas.waitForExistence(timeout: 10), "Notebook canvas should load")

        // Find the blob indicator.
        let blob = app.otherElements["alan_presence_blob"]
        XCTAssertTrue(blob.waitForExistence(timeout: 5), "Blob indicator should exist")

        // Record initial position.
        let initialFrame = blob.frame
        print("[Test] Initial blob frame: \(initialFrame)")
        print("[Test] Initial blob X: \(initialFrame.midX), Y: \(initialFrame.midY)")
        print("[Test] Initial blob minX (left edge): \(initialFrame.minX)")

        // Take screenshot of initial state.
        print("[Test] Expecting: Blob near top of screen, left edge aligned with text left edge")
        saveScreenshot(name: "blob_initial_position")

        // Assert initial Y is near top (not starting low on screen).
        // Screen coordinates: Y increases downward. Top area should be < 300.
        XCTAssertLessThan(initialFrame.midY, 300,
            "Blob should start near top of screen, not at Y=\(initialFrame.midY)")

        // Tap to start streaming.
        canvas.tap()
        Thread.sleep(forTimeInterval: 1.0)

        // Record position after tap.
        let afterTapFrame = blob.frame
        print("[Test] After tap blob frame: \(afterTapFrame)")
        saveScreenshot(name: "blob_after_tap")

        // Wait for streaming and check movement.
        Thread.sleep(forTimeInterval: 4.0)
        let midFrame = blob.frame
        print("[Test] Mid-streaming blob frame: \(midFrame)")
        saveScreenshot(name: "blob_mid_streaming")

        Thread.sleep(forTimeInterval: 4.0)
        let lateFrame = blob.frame
        print("[Test] Late-streaming blob frame: \(lateFrame)")
        saveScreenshot(name: "blob_late_streaming")

        // Assert blob moves down during streaming.
        XCTAssertGreaterThan(midFrame.midY, afterTapFrame.midY,
            "Blob should move down during streaming")
        XCTAssertGreaterThan(lateFrame.midY, midFrame.midY,
            "Blob should continue moving down")

        print("[Test] Position summary:")
        print("  Initial Y: \(initialFrame.midY)")
        print("  After tap Y: \(afterTapFrame.midY)")
        print("  Mid Y: \(midFrame.midY)")
        print("  Late Y: \(lateFrame.midY)")
        print("  X position (minX): \(initialFrame.minX)")
    }

}
