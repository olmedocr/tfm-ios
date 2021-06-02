//
//  CurrencyTests.swift
//  KeloUITests
//
//  Created by Raul Olmedo on 7/5/21.
//

import XCTest

private let groupName = "Hobo Crib"
private let userName = "The Man"

class CurrencyTests: XCTestCase {

    var app: XCUIApplication!

    override func setUp() {
        continueAfterFailure = true

        app = XCUIApplication()
        app.launchArguments += ["-hasBeenLaunchedBefore", "NO"]

        app.launch()
        app.buttons["Create Group"].tap()
        app.textFields.element.tap()
        app.textFields.element.typeText(groupName)
        app.keyboards.buttons["Done"].tap()
    }

    func testCurrencyEURIsDefault() throws {
        XCTAssert(app.buttons["EUR"].exists)
    }

    func testSelectedCurrencyAppears() throws {
        app.buttons["EUR"].tap()
        app.swipeUp()
        app.tables.cells.element(boundBy: 7).tap()

        XCTAssert(app.buttons["ARS"].exists)
    }

    func testCurrencySelectionByAdmin() throws {
        app.buttons["Continue"].tap()
        app.textFields.element.tap()
        app.textFields.element.typeText(userName)
        app.keyboards.buttons["Done"].tap()
        app.buttons["Continue"].tap()
        app.tabBars.buttons["Settings"].tap()
        app.tables.cells.element(boundBy: 2).tap()

        app.navigationBars.buttons.element(boundBy: 0).tap()
        app.tabBars.buttons["Settings"].tap()
        app.buttons["Leave Group"].tap()
        app.alerts["Are you sure?"].buttons["Leave"].tap()
    }

}
