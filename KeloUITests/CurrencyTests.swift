//
//  CurrencyTests.swift
//  KeloUITests
//
//  Created by Raul Olmedo on 7/5/21.
//

import XCTest

private let groupName = "Hobo Crib"

class CurrencyTests: XCTestCase {

    static var app: XCUIApplication!

    override class func setUp() {
        app = XCUIApplication()
        app.launchArguments += ["-hasBeenLaunchedBefore", "NO"]

        app.launch()
        app.buttons["Create Group"].tap()
        app.textFields.element.tap()
        app.textFields.element.typeText(groupName)
        app.keyboards.buttons["Done"].tap()
    }

    override func setUp() {
        continueAfterFailure = false
    }

    override class func tearDown() {
        app.tabBars.buttons["Settings"].tap()
        app.buttons["Leave Group"].tap()
        app.alerts["Are you sure?"].buttons["Leave"].tap()
    }

    func testCurrencyEURIsDefault() throws {
        guard let app = CurrencyTests.app else {
            XCTFail("Unknown error")
            return
        }

        XCTAssert(app.staticTexts["EUR"].exists)
        XCTAssert(app.images["Currency Flag"].exists)
    }

    func testSelectedCurrencyAppears() throws {
        guard let app = CurrencyTests.app else {
            XCTFail("Unknown error")
            return
        }

        app.buttons["🤑"].tap()
        app.swipeUp()
        app.tables.cells.element(boundBy: 7).tap()

        XCTAssert(app.staticTexts["ARS"].exists)
        XCTAssert(app.images["Currency Flag"].exists)
    }
}
