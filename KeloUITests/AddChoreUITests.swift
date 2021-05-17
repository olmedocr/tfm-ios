//
//  AddChoreUITests.swift
//  KeloUITests
//
//  Created by Raul Olmedo on 7/5/21.
//

import XCTest

class AddChoreUITests: XCTestCase {

    static var app: XCUIApplication!

    override class func setUp() {
        app = XCUIApplication()
        app.launchArguments += ["-hasBeenLaunchedBefore", "NO"]

        app.launch()
        app.buttons["Create Group"].tap()
        app.textFields.element.tap()
        app.textFields.element.typeText("Hobo Crib")
        app.keyboards.buttons["Done"].tap()
        app.buttons["Continue"].tap()
        app.textFields.element.tap()
        app.textFields.element.typeText("The Man")
        app.keyboards.buttons["Done"].tap()
        app.buttons["Continue"].tap()
    }

    override func setUpWithError() throws {
        continueAfterFailure = false

    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testAddChore() throws {
        // TODO: implement
        guard let app = AddChoreUITests.app else {
            XCTFail("Unknown error")
            return
        }

        // app.buttons["Edit"].tap()
    }
}
