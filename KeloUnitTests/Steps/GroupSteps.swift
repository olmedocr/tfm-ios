//
//  CreateGroupSteps.swift
//  KeloTests
//
//  Created by Raul Olmedo on 15/4/21.
//

@testable import Kelo
import XCTest
import XCTest_Gherkin

final class CreateGroupSteps: StepDefiner {

    private var groupName: String?
    private var userName: String?
    private var selectedCurrency: Currency?
    private var isGroupNameValid = true

    override func defineSteps() {
        step("the user that enters its group name \"(.*)\"") { (groupName: String) in
            self.groupName = groupName
        }

        step("the user validates its group name") {
            switch Validations.groupName(self.groupName!) {
            case .failure:
                self.isGroupNameValid = false
            case .success:
                self.isGroupNameValid = true
            }
        }

        step("the group name length must be less or equal than 32") {
            XCTAssertTrue(self.isGroupNameValid)
        }

        step("the group name length must be greater or equal than 5") {
            XCTAssertTrue(self.isGroupNameValid)
        }

        step("the group name length must not be greater than 32") {
            XCTAssertFalse(self.isGroupNameValid)
        }

        step("the group name length must not be less than 5") {
            XCTAssertFalse(self.isGroupNameValid)
        }

        step("the group name must not be empty") {
            XCTAssertFalse(self.isGroupNameValid)
        }

        step("the group name must only contain alphanumerical characters with spaces") {
            XCTAssertTrue(self.isGroupNameValid)
        }

        step("the group name must not contain special characters") {
            XCTAssertFalse(self.isGroupNameValid)
        }
    }
}
