//
//  ChoreUnitTests.swift
//  KeloUnitTests
//
//  Created by Raul Olmedo on 6/5/21.
//

import XCTest
import XCTest_Gherkin

class ChoreUnitTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testChoreNameLength1() {
        NativeRunner.runScenario(featureFile: "CreateChore.feature",
                                 scenario: "Valid Length 1",
                                 testCase: self)
    }

    func testChoreNameLength2() {
        NativeRunner.runScenario(featureFile: "CreateChore.feature",
                                 scenario: "Valid Length 2",
                                 testCase: self)
    }

    func testChoreNameLength3() {
        NativeRunner.runScenario(featureFile: "CreateChore.feature",
                                 scenario: "Invalid Length 1",
                                 testCase: self)
    }

    func testChoreNameLength4() {
        NativeRunner.runScenario(featureFile: "CreateChore.feature",
                                 scenario: "Invalid Length 2",
                                 testCase: self)
    }

    func testChoreNameEmptiness() {
        NativeRunner.runScenario(featureFile: "CreateChore.feature",
                                 scenario: "Emptiness",
                                 testCase: self)
    }

    func testChoreNameValidChars() {
        NativeRunner.runScenario(featureFile: "CreateChore.feature",
                                 scenario: "Valid Characters",
                                 testCase: self)
    }

    func testChoreNameInvalidChars() {
        NativeRunner.runScenario(featureFile: "CreateChore.feature",
                                 scenario: "Invalid Characters",
                                 testCase: self)
    }

}
