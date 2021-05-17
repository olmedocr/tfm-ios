//
//  KeloUnitTests.swift
//  KeloUnitTests
//
//  Created by Raul Olmedo on 4/5/21.
//

import XCTest
import XCTest_Gherkin

class GroupUnitTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testGroupNameLength1() {
        NativeRunner.runScenario(featureFile: "CreateGroup.feature",
                                 scenario: "Valid Length 1",
                                 testCase: self)
    }

    func testGroupNameLength2() {
        NativeRunner.runScenario(featureFile: "CreateGroup.feature",
                                 scenario: "Valid Length 2",
                                 testCase: self)
    }

    func testGroupNameLength3() {
        NativeRunner.runScenario(featureFile: "CreateGroup.feature",
                                 scenario: "Invalid Length 1",
                                 testCase: self)
    }

    func testGroupNameLength4() {
        NativeRunner.runScenario(featureFile: "CreateGroup.feature",
                                 scenario: "Invalid Length 2",
                                 testCase: self)
    }

    func testGroupNameEmptiness() {
        NativeRunner.runScenario(featureFile: "CreateGroup.feature",
                                 scenario: "Emptiness",
                                 testCase: self)
    }

    func testGroupNameValidChars() {
        NativeRunner.runScenario(featureFile: "CreateGroup.feature",
                                 scenario: "Valid Characters",
                                 testCase: self)
    }

    func testGroupNameInvalidChars() {
        NativeRunner.runScenario(featureFile: "CreateGroup.feature",
                                 scenario: "Invalid Characters",
                                 testCase: self)
    }
}
