//
//  GroupTests.swift
//  KeloUITests
//
//  Created by Raul Olmedo on 1/6/21.
//

import XCTest

private let groupName = "Hobo Crib"
private let userName = "The Man"
private let choreName = "Clean ma shiieeet"

class GroupTests: XCTestCase {

    var app: XCUIApplication!

    override func setUp() {
        continueAfterFailure = false

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

    func testLeaveGroup() throws {
        app.tabBars.buttons["Settings"].tap()
        app.buttons["Leave Group"].tap()
        XCTAssertTrue(app.alerts["Are you sure?"].exists)
        app.alerts["Are you sure?"].buttons["Leave"].tap()
        app.alerts["Attention!"].buttons["OK"].tap()
    }

    func testDeleteGroupByAdmin() throws {
        app.tabBars.buttons["Settings"].tap()
        app.swipeUp()
        app.buttons["Delete Group"].tap()
        XCTAssertTrue(app.alerts["Are you sure?"].exists)
        app.alerts["Are you sure?"].buttons["Delete"].tap()
        app.alerts["Attention!"].buttons["OK"].tap()
    }

    func testGroupNameUpdateByAdmin() throws {
        // TODO:
    }

    func testUserNameUpdateByAdmin() throws {
        // TODO: y ponerlo en UserTests
    }

}
