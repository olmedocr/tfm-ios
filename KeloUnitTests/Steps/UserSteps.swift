//
//  CreateUserSteps.swift
//  KeloTests
//
//  Created by Raul Olmedo on 15/4/21.
//

@testable import Kelo
import XCTest
import XCTest_Gherkin

final class UserSteps: StepDefiner {

    private var userName: String?
    private var isUsernameValid = true

    private var user = User()
    private var userToBeRemoved = User()

    // swiftlint:disable function_body_length
    override func defineSteps() {
        step("the user that enters its username \"(.*)\"") { (userName: String) in
            self.userName = userName
        }

        step("the user validates its username") {
            switch Validations.userName(self.userName!) {
            case .failure:
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

        // MARK: - Delete User Action
        step("the user whose \"(.*)\"") { (userId: String) in
            self.user.id = userId
            self.user.isAdmin = false
        }

        step("the user \"(.*)\" who is not the admin of the group") { (userId: String) in
            self.user.id = userId
            self.user.isAdmin = false
        }

        step("the user \"(.*)\" who is admin of the group") { (userId: String) in
            self.user.id = userId
            self.user.isAdmin = true
        }

        step("the user tries to remove a certain user \"(.*)\"") { (userId: String) in
            self.userToBeRemoved.id = userId
        }

        step("the action of removal will not be executed") {
            switch Validations.userPermission(self.userToBeRemoved, currrentUser: self.user, operation: .remove) {
            case .failure:
                break
            case .success:
                XCTFail("The operation should be invalid")
            }
        }

        step("the action of removal will be executed") {
            switch Validations.userPermission(self.userToBeRemoved, currrentUser: self.user, operation: .remove) {
            case .failure(let err):
                XCTFail(err.localizedDescription)
            case .success:
               break
            }
        }
    }

}
