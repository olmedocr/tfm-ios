//
//  ChoreTests.swift
//  KeloUnitTests
//
//  Created by Raul Olmedo on 6/5/21.
//

import XCTest
import XCTest_Gherkin

class ChoreTests: XCTestCase {

    func testChoreNameLength1() {
        NativeRunner.runScenario(featureFile: "Chore.feature",
                                 scenario: "Valid Length 1",
                                 testCase: self)
    }

    func testChoreNameLength2() {
        NativeRunner.runScenario(featureFile: "Chore.feature",
                                 scenario: "Valid Length 2",
                                 testCase: self)
    }

    func testChoreNameLength3() {
        NativeRunner.runScenario(featureFile: "Chore.feature",
                                 scenario: "Invalid Length 1",
                                 testCase: self)
    }

    func testChoreNameLength4() {
        NativeRunner.runScenario(featureFile: "Chore.feature",
                                 scenario: "Invalid Length 2",
                                 testCase: self)
    }

    func testChoreNameEmptiness() {
        NativeRunner.runScenario(featureFile: "Chore.feature",
                                 scenario: "Emptiness",
                                 testCase: self)
    }

    func testChoreNameValidChars() {
        NativeRunner.runScenario(featureFile: "Chore.feature",
                                 scenario: "Valid Characters",
                                 testCase: self)
    }

    func testChoreNameInvalidChars() {
        NativeRunner.runScenario(featureFile: "Chore.feature",
                                 scenario: "Invalid Characters",
                                 testCase: self)
    }

    func testChoreUpdateHasPermissions() {
        NativeRunner.runScenario(featureFile: "Chore.feature",
                                 scenario: "User Has Permissions For Updating a Chore",
                                 testCase: self)
    }

    func testChoreUpdateHasNoPermissions() {
        NativeRunner.runScenario(featureFile: "Chore.feature",
                                 scenario: "User Has Not Permissions For Updating a Chore",
                                 testCase: self)
    }

    func testChoreRemovalHasAdminPermissions() {
        NativeRunner.runScenario(featureFile: "Chore.feature",
                                 scenario: "(Admin) User Has Permissions For Removing a Chore",
                                 testCase: self)
    }

    func testChoreRemovalHasPermissions() {
        NativeRunner.runScenario(featureFile: "Chore.feature",
                                 scenario: "(Creator) User Has Permissions For Removing a Chore",
                                 testCase: self)
    }

    func testChoreRemovalHasNoPermissions() {
        NativeRunner.runScenario(featureFile: "Chore.feature",
                                 scenario: "User Has Not Permissions For Removing a Chore",
                                 testCase: self)
    }

    func testChoreCompletionHasAdminPermissions() {
        NativeRunner.runScenario(featureFile: "Chore.feature",
                                 scenario: "(Admin) User Has Permissions For Completing a Chore",
                                 testCase: self)
    }

    func testChoreCompletionHasPermissions() {
        NativeRunner.runScenario(featureFile: "Chore.feature",
                                 scenario: "(Creator/Assignee) User Has Permissions For Completing a Chore",
                                 testCase: self)
    }

    func testChoreCompletionHasNoPermissions() {
        NativeRunner.runScenario(featureFile: "Chore.feature",
                                 scenario: "User Has Not Permissions For Completing a Chore",
                                 testCase: self)
    }

    func testChoreUpdateHasAdminPermissions() {
        NativeRunner.runScenario(featureFile: "Chore.feature",
                                 scenario: "(Admin) User Has Permissions For Updating a Chore",
                                 testCase: self)
    }

}
