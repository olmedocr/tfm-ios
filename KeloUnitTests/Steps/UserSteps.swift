//
//  CreateUserSteps.swift
//  KeloTests
//
//  Created by Raul Olmedo on 15/4/21.
//

@testable import Kelo
import XCTest
import XCTest_Gherkin

final class CreateUserSteps: StepDefiner {

    private var userName: String?
    private var isUsernameValid = true

    override func defineSteps() {
        step("the user that enters its username \"(.*)\"") { (userName: String) in
            self.userName = userName
        }

        step("the user validates its username") {
            switch Validations.userName(self.userName!) {
            case .failure(_):
                self.isUsernameValid = false
            case .success:
                self.isUsernameValid = true
            }
        }

        step("the username length must be less or equal than 32") {
            XCTAssertTrue(self.isUsernameValid)
        }

        step("the username length must be greater or equal than 3") {
            XCTAssertTrue(self.isUsernameValid)
        }

        step("the username length must not be greater than 32") {
            XCTAssertFalse(self.isUsernameValid)
        }

        step("the username length must not be less than 3") {
            XCTAssertFalse(self.isUsernameValid)
        }

        step("the username must not be empty") {
            XCTAssertFalse(self.isUsernameValid)
        }

        step("the username must only contain alphabetical characters with spaces") {
            XCTAssertTrue(self.isUsernameValid)
        }

        step("the username must not contain numbers") {
            XCTAssertFalse(self.isUsernameValid)
        }

        step("the username must not contain special characters") {
            XCTAssertFalse(self.isUsernameValid)
        }
    }
}
