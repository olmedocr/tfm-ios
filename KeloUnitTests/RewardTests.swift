//
//  RewardSteps.swift
//  KeloUnitTests
//
//  Created by Raul Olmedo on 14/6/21.
//

import XCTest
import XCTest_Gherkin

class RewardTests: XCTestCase {

    func testRewardValidity() {
        NativeRunner.runScenario(featureFile: "Reward.feature",
                                 scenario: "Validate Valid Reward",
                                 testCase: self)
    }

    func testRewardInvalidity() {
        NativeRunner.runScenario(featureFile: "Reward.feature",
                                 scenario: "Validate Invalid Reward",
                                 testCase: self)
    }

    func testRewardNameLength1() {
        NativeRunner.runScenario(featureFile: "Reward.feature",
                                 scenario: "Valid Length 1",
                                 testCase: self)
    }

    func testRewardNameLength2() {
        NativeRunner.runScenario(featureFile: "Reward.feature",
                                 scenario: "Valid Length 2",
                                 testCase: self)
    }

    func testRewardNameLength3() {
        NativeRunner.runScenario(featureFile: "Reward.feature",
                                 scenario: "Invalid Length 1",
                                 testCase: self)
    }

    func testRewardNameLength4() {
        NativeRunner.runScenario(featureFile: "Reward.feature",
                                 scenario: "Invalid Length 2",
                                 testCase: self)
    }

    func testRewardNameEmptiness() {
        NativeRunner.runScenario(featureFile: "Reward.feature",
                                 scenario: "Emptiness",
                                 testCase: self)
    }

    func testRewardNameValidChars() {
        NativeRunner.runScenario(featureFile: "Reward.feature",
                                 scenario: "Valid Characters",
                                 testCase: self)
    }

    func testRewardNameInvalidChars() {
        NativeRunner.runScenario(featureFile: "Reward.feature",
                                 scenario: "Invalid Characters",
                                 testCase: self)
    }

    func testRewardCreationHasAdminPermissions() {
        NativeRunner.runScenario(featureFile: "Reward.feature",
                                 scenario: "(Admin) User Has Permissions For Creating the Reward",
                                 testCase: self)
    }

    func testRewardCreationHasNoPermissions() {
        NativeRunner.runScenario(featureFile: "Reward.feature",
                                 scenario: "User Has Not Permissions For Creating the Reward",
                                 testCase: self)
    }

    func testRewardUpdateHasAdminPermissions() {
        NativeRunner.runScenario(featureFile: "Reward.feature",
                                 scenario: "(Admin) User Has Permissions For Updating the Reward",
                                 testCase: self)
    }

    func testRewardUpdateHasNoPermissions() {
        NativeRunner.runScenario(featureFile: "Reward.feature",
                                 scenario: "User Has Not Permissions For Updating the Reward",
                                 testCase: self)
    }

    func testRewardRemovalHasAdminPermissions() {
        NativeRunner.runScenario(featureFile: "Reward.feature",
                                 scenario: "(Admin) User Has Permissions For Removing the Reward",
                                 testCase: self)
    }

    func testRewardRemovalHasNoPermissions() {
        NativeRunner.runScenario(featureFile: "Reward.feature",
                                 scenario: "User Has Not Permissions For Removing the Reward",
                                 testCase: self)
    }

}
