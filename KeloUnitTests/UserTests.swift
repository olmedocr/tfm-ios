//
//  UserTests.swift
//  KeloUnitTests
//
//  Created by Raul Olmedo on 4/5/21.
//

import XCTest
import XCTest_Gherkin

class UserTests: XCTestCase {

    func testUserNameLength1() {
        NativeRunner.runScenario(featureFile: "User.feature",
                                 scenario: "Valid Length 1",
                                 testCase: self)
    }

    func testUserNameLength2() {
        NativeRunner.runScenario(featureFile: "User.feature",
                                 scenario: "Valid Length 2",
                                 testCase: self)
    }

    func testUserNameLength3() {
        NativeRunner.runScenario(featureFile: "User.feature",
                                 scenario: "Invalid Length 1",
                                 testCase: self)
    }

    func testUserNameLength4() {
        NativeRunner.runScenario(featureFile: "User.feature",
                                 scenario: "Invalid Length 2",
                                 testCase: self)
    }

    func testUserNameEmptiness() {
        NativeRunner.runScenario(featureFile: "User.feature",
                                 scenario: "Emptiness",
                                 testCase: self)
    }

    func testUserNameValidChars() {
        NativeRunner.runScenario(featureFile: "User.feature",
                                 scenario: "Valid Characters",
                                 testCase: self)
    }

    func testUserNameInvalidChars1() {
        NativeRunner.runScenario(featureFile: "User.feature",
                                 scenario: "Invalid Characters 1",
                                 testCase: self)
    }

    func testUserNameInvalidChars2() {
        NativeRunner.runScenario(featureFile: "User.feature",
                                 scenario: "Invalid Characters 2",
                                 testCase: self)
    }
}
