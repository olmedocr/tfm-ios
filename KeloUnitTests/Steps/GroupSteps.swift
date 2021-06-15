//
//  CreateGroupSteps.swift
//  KeloTests
//
//  Created by Raul Olmedo on 15/4/21.
//

@testable import Kelo
import XCTest
import XCTest_Gherkin

final class GroupSteps: StepDefiner {

    private var groupName: String?
    private var userName: String?
    private var selectedCurrency: Currency?

    private var isGroupNameValid = true

    private var user = User()

    override func defineSteps() {

        // MARK: - Group name validation
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

        // MARK: - Group name update validation
        step("a user that wants to update the group name") {}

        step("the user is the unique administrator of the group") {
            self.user.isAdmin = true
        }

        step("the user is not the unique administrator of the group") {
            self.user.isAdmin = false
        }

        step("the user is permitted to modify the group name") {
            XCTAssertTrue(self.user.isAdmin)
        }

        step("the user is not permitted to modify the group name") {
            XCTAssertFalse(self.user.isAdmin)
        }
    }

}
