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

    private var chore = Chore()
    private var choreName: String?
    private var selectedDate: Date?

    private var isChoreNameValid = false
    private var isChoreValid = false

    // swiftlint:disable function_body_length
    override func defineSteps() {
        step("the user that fills up a chore without an assignee") {
            self.chore = Chore(id: "", name: "Do the laundry")
        }

        step("the user tries to create the chore") {
            switch Validations.chore(self.chore) {
            case .failure(_):
                self.isChoreValid = false
            case .success:
                self.isChoreValid = true
            }
        }

        step("the user will not be able to create it") {
            XCTAssertFalse(self.isChoreValid)
        }

        step("the user wants to create a new chore") {}

        step("the user enters the add chore page") {}

        step("the user selects a new expiration date") {
            self.selectedDate = Date().addingTimeInterval(86400)
            self.chore.expiration = self.selectedDate!
        }

        step("the user will see that the importance is set to Low by default") {
            XCTAssertTrue(self.chore.points == Chore.Importance.low.rawValue)
        }

        step("the user will see that the expiration date is set to today by default") {
            let today = Calendar.current.dateComponents([.day, .year, .month], from: Date())
            let choreDate = Calendar.current.dateComponents([.day, .year, .month], from: self.chore.expiration)

            XCTAssertTrue(today == choreDate)

        }

        step("the user will see that the expiration date is set to the one selected") {
            XCTAssertTrue(self.chore.expiration == self.selectedDate)
        }

        step("the user that enters a chore \"(.*)\"") { (choreName: String) in
            self.choreName = choreName
        }

        step("the user validates the chore name") {
            switch Validations.choreName(self.choreName!) {
            case .failure(_):
                self.isChoreNameValid = false
            case .success:
                self.isChoreNameValid = true
            }
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
