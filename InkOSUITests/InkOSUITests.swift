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

    // MARK: - Diagnostic Test

    @MainActor
    func testAppLaunchDiagnostic() throws {
        // Diagnostic test to understand black screen issue.
        // Captures screenshot immediately after launch.

        print("[Test] App launched - capturing initial state")
        Thread.sleep(forTimeInterval: 2.0)
        saveScreenshot(name: "app_launch_state")

        // Print element hierarchy to understand what's visible.
        print("[Test] Windows count: \(app.windows.count)")
        print("[Test] ScrollViews count: \(app.scrollViews.count)")
        print("[Test] StaticTexts count: \(app.staticTexts.count)")
        print("[Test] Buttons count: \(app.buttons.count)")

        // Check for notebook canvas.
        let canvas = app.scrollViews["notebook_canvas"]
        let canvasExists = canvas.waitForExistence(timeout: 5)
        print("[Test] notebook_canvas exists: \(canvasExists)")

        // Check for any scrollviews.
        if app.scrollViews.count > 0 {
            let firstScrollView = app.scrollViews.element(boundBy: 0)
            print("[Test] First scrollview frame: \(firstScrollView.frame)")
            print("[Test] First scrollview identifier: \(firstScrollView.identifier)")
        }

        // Check for static texts (would show if minimal preview loaded).
        for i in 0..<min(app.staticTexts.count, 5) {
            let text = app.staticTexts.element(boundBy: i)
            print("[Test] StaticText \(i): '\(text.label)'")
        }

        // Check for blob.
        let blob = app.otherElements["alan_presence_blob"]
        print("[Test] alan_presence_blob exists: \(blob.exists)")

        // Assert something is visible.
        XCTAssertTrue(canvasExists || app.staticTexts.count > 0,
            "Either canvas or text elements should be visible")

        saveScreenshot(name: "app_diagnostic_final")
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

    // MARK: - Toolbar Mode Switching Tests

    @MainActor
    func testToolbarModeSwitching() throws {
        // Test that tapping pencil and keyboard icons properly toggles the selected state.

        // Wait for app to load.
        let canvas = app.scrollViews["notebook_canvas"]
        XCTAssertTrue(canvas.waitForExistence(timeout: 10), "Notebook canvas should load")

        // Find toolbar buttons.
        let pencilButton = app.buttons["pencil_mode_button"]
        let keyboardButton = app.buttons["keyboard_mode_button"]

        XCTAssertTrue(pencilButton.waitForExistence(timeout: 5), "Pencil button should exist")
        XCTAssertTrue(keyboardButton.waitForExistence(timeout: 5), "Keyboard button should exist")

        // Log all buttons in the input bar.
        let inputBar = app.otherElements["canvas_input_bar"]
        print("[Test] canvas_input_bar exists: \(inputBar.exists)")
        if inputBar.exists {
            print("[Test] canvas_input_bar frame: \(inputBar.frame)")
            let buttons = inputBar.buttons
            print("[Test] Buttons in input bar: \(buttons.count)")
            for i in 0..<buttons.count {
                let btn = buttons.element(boundBy: i)
                print("[Test]   Button[\(i)]: id=\(btn.identifier), label=\(btn.label), value=\(btn.value ?? "nil"), frame=\(btn.frame), enabled=\(btn.isEnabled), hittable=\(btn.isHittable)")
            }
        }

        // Screenshot initial state (pencil should be selected).
        saveScreenshot(name: "toolbar_01_initial_pencil_selected")
        print("[Test] === INITIAL STATE ===")
        print("[Test] Pencil: value=\(pencilButton.value ?? "nil"), hittable=\(pencilButton.isHittable), enabled=\(pencilButton.isEnabled)")
        print("[Test] Keyboard: value=\(keyboardButton.value ?? "nil"), hittable=\(keyboardButton.isHittable), enabled=\(keyboardButton.isEnabled)")

        // Tap keyboard button.
        print("[Test] === TAPPING KEYBOARD ===")
        print("[Test] Keyboard button frame: \(keyboardButton.frame)")
        keyboardButton.tap()
        Thread.sleep(forTimeInterval: 2.0)

        saveScreenshot(name: "toolbar_02_after_keyboard_tap")
        print("[Test] === AFTER KEYBOARD TAP ===")
        print("[Test] Pencil: value=\(pencilButton.value ?? "nil"), hittable=\(pencilButton.isHittable)")
        print("[Test] Keyboard: value=\(keyboardButton.value ?? "nil"), hittable=\(keyboardButton.isHittable)")

        // Check if mode actually changed by verifying accessibility values.
        var pencilValue = pencilButton.value as? String ?? ""
        var keyboardValue = keyboardButton.value as? String ?? ""
        print("[Test] Expected: pencil='', keyboard='selected'")
        print("[Test] Actual:   pencil='\(pencilValue)', keyboard='\(keyboardValue)'")

        XCTAssertEqual(keyboardValue, "selected",
            "Keyboard should be selected after tapping it")
        XCTAssertNotEqual(pencilValue, "selected",
            "Pencil should NOT be selected after tapping keyboard")

        // Toolbar should remain hittable even with the keyboard up
        // (keyboard safe area pushes toolbar above the keyboard).
        let pencilAfterKeyboard = app.buttons["pencil_mode_button"]
        print("[Test] Pencil hittable with keyboard up: \(pencilAfterKeyboard.isHittable)")
        print("[Test] Pencil frame with keyboard up: \(pencilAfterKeyboard.frame)")
        saveScreenshot(name: "toolbar_02b_keyboard_up")

        // Switch back to pencil (should work even with keyboard visible).
        print("[Test] === TAPPING PENCIL (switch back, keyboard may be up) ===")
        XCTAssertTrue(pencilAfterKeyboard.waitForExistence(timeout: 5), "Pencil should exist")
        if pencilAfterKeyboard.isHittable {
            pencilAfterKeyboard.tap()
        } else {
            // Fallback: dismiss keyboard first if toolbar is still covered.
            print("[Test] Pencil not hittable, dismissing keyboard first")
            app.scrollViews["notebook_canvas"].tap()
            Thread.sleep(forTimeInterval: 1.0)
            app.buttons["pencil_mode_button"].tap()
        }
        Thread.sleep(forTimeInterval: 2.0)

        saveScreenshot(name: "toolbar_03_after_pencil_tap")
        pencilValue = (app.buttons["pencil_mode_button"].value as? String) ?? ""
        keyboardValue = (app.buttons["keyboard_mode_button"].value as? String) ?? ""
        print("[Test] === AFTER PENCIL TAP ===")
        print("[Test] Expected: pencil='selected', keyboard=''")
        print("[Test] Actual:   pencil='\(pencilValue)', keyboard='\(keyboardValue)'")

        XCTAssertEqual(pencilValue, "selected",
            "Pencil should be selected after tapping it back")

        // Third round: keyboard again, then pencil directly (no keyboard dismiss).
        print("[Test] === TAPPING KEYBOARD (second time) ===")
        app.buttons["keyboard_mode_button"].tap()
        Thread.sleep(forTimeInterval: 2.0)

        pencilValue = (app.buttons["pencil_mode_button"].value as? String) ?? ""
        keyboardValue = (app.buttons["keyboard_mode_button"].value as? String) ?? ""
        print("[Test] After second keyboard tap: pencil='\(pencilValue)', keyboard='\(keyboardValue)'")
        XCTAssertEqual(keyboardValue, "selected", "Keyboard selected on second tap")

        // Try to tap pencil directly with keyboard up.
        let pencilDirect = app.buttons["pencil_mode_button"]
        print("[Test] Pencil hittable (round 2): \(pencilDirect.isHittable)")
        if pencilDirect.isHittable {
            pencilDirect.tap()
        } else {
            print("[Test] Still not hittable with keyboard up, dismissing first")
            app.scrollViews["notebook_canvas"].tap()
            Thread.sleep(forTimeInterval: 1.0)
            app.buttons["pencil_mode_button"].tap()
        }
        Thread.sleep(forTimeInterval: 2.0)

        saveScreenshot(name: "toolbar_05_pencil_final")
        pencilValue = (app.buttons["pencil_mode_button"].value as? String) ?? ""
        keyboardValue = (app.buttons["keyboard_mode_button"].value as? String) ?? ""
        print("[Test] === FINAL STATE ===")
        print("[Test] Expected: pencil='selected', keyboard=''")
        print("[Test] Actual:   pencil='\(pencilValue)', keyboard='\(keyboardValue)'")

        XCTAssertEqual(pencilValue, "selected",
            "Pencil should be selected on final switch")
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

    // MARK: - Attachment Menu Tests

    @MainActor
    func testPaperclipMenuAppearsAboveToolbar() throws {
        // Criteria:
        // 1. Tapping paperclip button shows the attachment menu
        // 2. The toolbar (canvas_input_bar) remains visible while menu is open
        // 3. Tapping outside dismisses the menu

        // Wait for canvas to load.
        let canvas = app.scrollViews["notebook_canvas"]
        XCTAssertTrue(canvas.waitForExistence(timeout: 10), "Notebook canvas should load")

        // Find the paperclip button.
        let paperclipButton = app.buttons["paperclip_button"]
        XCTAssertTrue(paperclipButton.waitForExistence(timeout: 5), "Paperclip button should exist")
        print("[Test] Paperclip button exists: \(paperclipButton.exists), frame: \(paperclipButton.frame)")

        // Verify the toolbar is visible before tap.
        let inputBar = app.otherElements["canvas_input_bar"]
        XCTAssertTrue(inputBar.exists, "Toolbar should be visible before tap")

        // Save screenshot before tap.
        saveScreenshot(name: "paperclip_before_tap")

        // CRITERION 1: Tap the paperclip — menu should appear.
        paperclipButton.tap()
        Thread.sleep(forTimeInterval: 0.5)

        saveScreenshot(name: "paperclip_after_tap")

        let attachmentMenu = app.otherElements["attachment_menu"]
        let menuExists = attachmentMenu.waitForExistence(timeout: 3)
        print("[Test] Attachment menu exists after tap: \(menuExists)")

        // Debug: dump the view hierarchy if menu doesn't appear.
        if !menuExists {
            print("[Test] DEBUG — All buttons: \(app.buttons.allElementsBoundByIndex.map { ($0.identifier, $0.label) })")
            print("[Test] DEBUG — All otherElements: \(app.otherElements.allElementsBoundByIndex.map { ($0.identifier, $0.label) })")
        }

        XCTAssertTrue(menuExists, "Attachment menu should appear after tapping paperclip")

        // CRITERION 2: Toolbar should STILL be visible.
        XCTAssertTrue(inputBar.exists, "Toolbar should remain visible while menu is open")
        print("[Test] Toolbar visible while menu open: \(inputBar.exists)")

        // CRITERION 3: Tap outside to dismiss the menu.
        canvas.tap()
        Thread.sleep(forTimeInterval: 0.5)

        saveScreenshot(name: "paperclip_after_dismiss")

        let menuAfterDismiss = app.otherElements["attachment_menu"].exists
        print("[Test] Menu exists after dismiss tap: \(menuAfterDismiss)")
        XCTAssertFalse(menuAfterDismiss, "Menu should disappear after tapping outside")

        // Toolbar should still be there.
        XCTAssertTrue(inputBar.exists, "Toolbar should still be visible after menu dismiss")
    }

}
