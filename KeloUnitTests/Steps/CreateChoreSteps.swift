//
//  CreateChoreSteps.swift
//  KeloUnitTests
//
//  Created by Raul Olmedo on 6/5/21.
//

@testable import Kelo
import XCTest
import XCTest_Gherkin

final class CreateChoreSteps: StepDefiner {

    private var choreName: String?
    private var isChoreNameValid = true

    override func defineSteps() {
        step("the user that enters a chore \"(.*)\"") { (choreName: String) in
            self.choreName = choreName
        }

        step("the user validates the chore name") {
            self.isChoreNameValid = Constants.choreNameRegex.matches(self.choreName!)
        }

        step("the chore name length must be less or equal than 32") {
            XCTAssertTrue(self.isChoreNameValid)
        }

        step("the chore name length must be greater or equal than 5") {
            XCTAssertTrue(self.isChoreNameValid)
        }

        step("the chore name length must not be greater than 32") {
            XCTAssertFalse(self.isChoreNameValid)
        }

        step("the chore name length must not be less than 5") {
            XCTAssertFalse(self.isChoreNameValid)
        }

        step("the chore name must not be empty") {
            XCTAssertFalse(self.isChoreNameValid)
        }

        step("the chore name must only contain alphanumerical characters with spaces") {
            XCTAssertTrue(self.isChoreNameValid)
        }

        step("the chore name must not contain special characters") {
            XCTAssertFalse(self.isChoreNameValid)
        }
    }
}
