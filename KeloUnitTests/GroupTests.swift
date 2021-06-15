//
//  GroupTests.swift
//  KeloUnitTests
//
//  Created by Raul Olmedo on 4/5/21.
//

import XCTest
import XCTest_Gherkin

class GroupTests: XCTestCase {

    func testGroupNameLength1() {
        NativeRunner.runScenario(featureFile: "Group.feature",
                                 scenario: "Valid Length 1",
                                 testCase: self)
    }

    func testGroupNameLength2() {
        NativeRunner.runScenario(featureFile: "Group.feature",
                                 scenario: "Valid Length 2",
                                 testCase: self)
    }

    func testGroupNameLength3() {
        NativeRunner.runScenario(featureFile: "Group.feature",
                                 scenario: "Invalid Length 1",
                                 testCase: self)
    }

    func testGroupNameLength4() {
        NativeRunner.runScenario(featureFile: "Group.feature",
                                 scenario: "Invalid Length 2",
                                 testCase: self)
    }

    func testGroupNameEmptiness() {
        NativeRunner.runScenario(featureFile: "Group.feature",
                                 scenario: "Emptiness",
                                 testCase: self)
    }

    func testGroupNameValidChars() {
        NativeRunner.runScenario(featureFile: "Group.feature",
                                 scenario: "Valid Characters",
                                 testCase: self)
    }

    func testGroupNameInvalidChars() {
        NativeRunner.runScenario(featureFile: "Group.feature",
                                 scenario: "Invalid Characters",
                                 testCase: self)
    }

    func testGroupUpdatePermissionByAdmin() {
        NativeRunner.runScenario(featureFile: "Group.feature",
                                 scenario: "(Admin) User Has Permissions For Updating the Group Name",
                                 testCase: self)
    }

    func testGroupUpdatePermission() {
        NativeRunner.runScenario(featureFile: "Group.feature",
                                 scenario: "User Has Not Permissions For Updating the Group Name",
                                 testCase: self)
    }

}
