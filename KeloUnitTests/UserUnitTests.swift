//
//  KeloUnitTests.swift
//  KeloUnitTests
//
//  Created by Raul Olmedo on 4/5/21.
//

import XCTest
import XCTest_Gherkin

class UserUnitTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testUserNameLength1() {
        NativeRunner.runScenario(featureFile: "CreateUser.feature",
                                 scenario: "Valid Length 1",
                                 testCase: self)
    }

    func testUserNameLength2() {
        NativeRunner.runScenario(featureFile: "CreateUser.feature",
                                 scenario: "Valid Length 2",
                                 testCase: self)
    }

    func testUserNameLength3() {
        NativeRunner.runScenario(featureFile: "CreateUser.feature",
                                 scenario: "Invalid Length 1",
                                 testCase: self)
    }

    func testUserNameLength4() {
        NativeRunner.runScenario(featureFile: "CreateUser.feature",
                                 scenario: "Invalid Length 2",
                                 testCase: self)
    }

    func testUserNameEmptiness() {
        NativeRunner.runScenario(featureFile: "CreateUser.feature",
                                 scenario: "Emptiness",
                                 testCase: self)
    }

    func testUserNameValidChars() {
        NativeRunner.runScenario(featureFile: "CreateUser.feature",
                                 scenario: "Valid Characters",
                                 testCase: self)
    }

    func testUserNameInvalidChars1() {
        NativeRunner.runScenario(featureFile: "CreateUser.feature",
                                 scenario: "Invalid Characters 1",
                                 testCase: self)
    }

    func testUserNameInvalidChars2() {
        NativeRunner.runScenario(featureFile: "CreateUser.feature",
                                 scenario: "Invalid Characters 2",
                                 testCase: self)
    }
}
