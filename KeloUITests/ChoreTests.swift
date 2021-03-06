//
//  ChoreTests.swift
//  KeloUITests
//
//  Created by Raul Olmedo on 7/5/21.
//

import XCTest

private let groupName = "Hobo Crib"
private let userName = "The Man"
private let choreName = "Clean ma shiieeet"

class ChoreTests: XCTestCase {

    static var app: XCUIApplication!

    override class func setUp() {
        app = XCUIApplication()
        app.launchArguments += ["-hasBeenLaunchedBefore", "NO"]

        app.launch()
        app.buttons["Create Group"].tap()
        app.textFields.element.tap()
        app.textFields.element.typeText(groupName)
        app.keyboards.buttons["Done"].tap()
        app.buttons["Continue"].tap()
        app.textFields.element.tap()
        app.textFields.element.typeText(userName)
        app.keyboards.buttons["Done"].tap()
        app.buttons["Continue"].tap()
    }

    override class func tearDown() {
        app.tabBars.buttons["Settings"].tap()
        app.buttons["Leave Group"].tap()
        app.alerts["Are you sure?"].buttons["Leave"].tap()
    }

    override func setUp() {
        continueAfterFailure = false
    }

    func testAddChore() throws {

        guard let app = ChoreTests.app else {
            XCTFail("Unknown error")
            return
        }

        let formatter = DateFormatter()
        formatter.timeStyle = .none
        formatter.dateStyle = .short
        formatter.timeZone = TimeZone.current

        let today = formatter.string(from: Date())

        app.navigationBars.buttons["Add"].tap()

        _ = app.textFields.element.waitForExistence(timeout: 10)
        app.textFields.element.tap()

        app.textFields.element.typeText(choreName)
        app.keyboards.buttons["Done"].tap()

        app.buttons["Select a User"].tap()
        app.tables.cells.element(boundBy: 0).tap()
        app.buttons["Medium"].tap()
        app.navigationBars.buttons["Save"].tap()

        XCTAssert(app.staticTexts.element(matching: .any, identifier: choreName).label == choreName)
        XCTAssert(app.staticTexts.element(matching: .any, identifier: today).label == today)
        XCTAssert(app.images.element(matching: .any, identifier: "Yellow").identifier == "Yellow")
    }

    func testEditChore() throws {

        guard let app = ChoreTests.app else {
            XCTFail("Unknown error")
            return
        }

        _ = app.tables.cells.element(boundBy: 0).waitForExistence(timeout: 10)
        app.tables.cells.element(boundBy: 0).tap()

        _ = app.textFields[choreName].waitForExistence(timeout: 5)
        XCTAssertTrue(app.textFields[choreName].exists)
        XCTAssertTrue(app.buttons[userName + " " + NSLocalizedString("(You)", comment: "")].exists)
        XCTAssertTrue(app.buttons["Medium"].isSelected)

        app.navigationBars.buttons.element(boundBy: 0).tap()
    }

    func testAssigneeSelection() throws {

        guard let app = ChoreTests.app else {
            XCTFail("Unknown error")
            return
        }

        _ = app.navigationBars.element.waitForExistence(timeout: 5)
        app.navigationBars.buttons["Add"].tap()

        XCTAssertFalse(app.buttons[userName + " " + NSLocalizedString("(You)", comment: "")].exists)
        app.buttons["Select a User"].tap()
        app.tables.cells.element(boundBy: 0).tap()
        XCTAssertTrue(app.buttons[userName + " " + NSLocalizedString("(You)", comment: "")].exists)

        app.navigationBars.buttons.element(boundBy: 0).tap()
    }

    func testCompletedChores() throws {

        guard let app = ChoreTests.app else {
            XCTFail("Unknown error")
            return
        }

        _ = app.navigationBars.element.waitForExistence(timeout: 5)
        app.navigationBars.buttons["Checkmark"].tap()

        XCTAssert(app.staticTexts.element(matching: .any, identifier: "Completed").exists)

        app.navigationBars.buttons["Checkmark"].tap()
    }

}
