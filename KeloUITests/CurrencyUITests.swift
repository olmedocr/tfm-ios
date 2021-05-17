//
//  CurrencyUITests.swift
//  KeloUITests
//
//  Created by Raul Olmedo on 7/5/21.
//

import XCTest

class CurrencyUITests: XCTestCase {

    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false

        app = XCUIApplication()
        app.launchArguments += ["-hasBeenLaunchedBefore", "NO"]

        app.launch()
        app.buttons["Create Group"].tap()
        app.textFields.element.tap()
        app.textFields.element.typeText("Hobo Crib")
        app.keyboards.buttons["Done"].tap()
    }

    override func tearDownWithError() throws {
        // TODO: delete group from settings
    }

    func testCurrencyEURIsDefault() throws {
        XCTAssert(app.staticTexts["EUR"].exists)
        XCTAssert(app.images["Currency Flag"].exists)
    }

    func testSelectedCurrencyAppears() throws {
        app.buttons["🤑"].tap()
        app.swipeUp()
        app.tables.cells.element(boundBy: 7).tap()

        XCTAssert(app.staticTexts["ARS"].exists)
        XCTAssert(app.images["Currency Flag"].exists)
    }
}
