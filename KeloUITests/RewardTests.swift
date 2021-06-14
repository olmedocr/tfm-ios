//
//  RewardTests.swift
//  KeloUITests
//
//  Created by Raul Olmedo on 14/6/21.
//

import XCTest

private let groupName = "Hobo Crib"
private let userName = "The Man"
private let rewardName = "Free dinner"

class RewardTests: XCTestCase {

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

        app.tabBars.buttons["Settings"].tap()
    }

    override class func tearDown() {
        app.tabBars.buttons["Settings"].tap()
        app.buttons["Leave Group"].tap()
        app.alerts["Are you sure?"].buttons["Leave"].tap()
    }

    override func setUp() {
        continueAfterFailure = false
    }

    func testAddReward() throws {
        guard let app = RewardTests.app else {
            XCTFail("Unknown error")
            return
        }

        app.tables.cells.element(boundBy: 2).waitForExistence(timeout: 5)
        app.tables.cells.element(boundBy: 2).tap()

        app.textFields.element.tap()
        app.textFields.element.typeText(rewardName)
        app.keyboards.buttons["Done"].tap()

        app.buttons["Select period"].tap()
        app.tables.cells.element(boundBy: 0).tap()
        XCTAssert(app.staticTexts.element(matching: .any, identifier: rewardName).label == rewardName)

        app.navigationBars.buttons.element(boundBy: 0).tap()
    }

    func testEditReward() throws {
        guard let app = RewardTests.app else {
            XCTFail("Unknown error")
            return
        }

        app.tables.cells.element(boundBy: 2).waitForExistence(timeout: 5)
        app.tables.cells.element(boundBy: 2).tap()

        app.textFields.element.tap()
        app.textFields.element.typeText(rewardName)
        app.keyboards.buttons["Done"].tap()

        app.buttons["Select period"].tap()
        app.tables.cells.element(boundBy: 0).tap()

        app.navigationBars.buttons["Save"].tap()

        app.tables.cells.element(boundBy: 2).tap()
        XCTAssertTrue(app.textFields[rewardName].exists)
        XCTAssertTrue(app.buttons["No frequency"].exists)

        app.navigationBars.buttons.element(boundBy: 0).tap()
    }

}
