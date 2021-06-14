//
//  RewardSteps.swift
//  KeloUnitTests
//
//  Created by Raul Olmedo on 14/6/21.
//

@testable import Kelo
import XCTest
import XCTest_Gherkin

final class RewardSteps: StepDefiner {

    private var reward = Reward()
    private var rewardDescription: String?
    private var operation: RewardOperation?

    private var isValidRewardName = false
    private var isValidReward = false

    private var user = User()

    override func defineSteps() {

        // MARK: - Reward Validation
        step("the user that fills up a invalid reward") {
            self.reward = Reward(id: "", name: "Beers")
        }

        step("the user that fills up a valid reward") {
            self.reward = Reward(id: "", name: "Beers", expiration: Date())
        }

        step("the user tries to create the reward") {
            switch Validations.reward(self.reward) {
            case .failure:
                self.isValidReward = false
            case .success:
                self.isValidReward = true
            }
        }

        step("the user will not be able to create the reward") {
            XCTAssertFalse(self.isValidReward)
        }

        step("the user will be able to create the reward") {
            XCTAssertTrue(self.isValidReward)
        }

        // MARK: - Reward Description Validation
        step("the user that enters the reward description \"(.*)\"") { (rewardDescription: String) in
            self.rewardDescription = rewardDescription
        }

        step("the user validates its reward") {
            switch Validations.rewardName(self.rewardDescription!) {
            case .failure:
                self.isValidRewardName = false
            case .success:
                self.isValidRewardName = true
            }
        }

        step("the reward description length must be less or equal than 48") {
            XCTAssertTrue(self.isValidRewardName)
        }

        step("the reward description length must be greater or equal than 5") {
            XCTAssertTrue(self.isValidRewardName)
        }

        step("the reward description length must not be greater than 48") {
            XCTAssertFalse(self.isValidRewardName)
        }

        step("the reward description length must not be less than 5") {
            XCTAssertFalse(self.isValidRewardName)
        }

        step("the reward description must not be empty") {
            XCTAssertFalse(self.isValidRewardName)
        }

        step("the reward description must only contain alphanumerical characters with spaces") {
            XCTAssertTrue(self.isValidRewardName)
        }

        step("the reward description must not contain special characters") {
            XCTAssertFalse(self.isValidRewardName)
        }

        // MARK: - Create Reward Permission
        step("a user that wants to create the reward") {
            self.operation = .update
        }

        // MARK: - Update Reward Permission
        step("a user that wants to update the reward") {
            self.operation = .update
        }

        // MARK: - Remove Reward Permission
        step("a user that wants to remove the reward") {
            self.operation = .remove
        }

        step("the user is not the admin of the group") {
            self.user.isAdmin = false
        }
        step("the user is the administrator of the group") {
            self.user.isAdmin = true
        }

        step("the user is permitted to modify it") {
            var hasEnoughPermissions = false

            switch Validations.rewardPermission(currentUser: self.user, operation: self.operation!) {
            case .failure:
                hasEnoughPermissions = false
            case .success:
                hasEnoughPermissions = true
            }

            XCTAssertTrue(hasEnoughPermissions)
        }
        step("the user is not permitted to modify it") {
            var hasEnoughPermissions = false

            switch Validations.rewardPermission(currentUser: self.user, operation: self.operation!) {
            case .failure:
                hasEnoughPermissions = false
            case .success:
                hasEnoughPermissions = true
            }

            XCTAssertFalse(hasEnoughPermissions)
        }
    }
}
