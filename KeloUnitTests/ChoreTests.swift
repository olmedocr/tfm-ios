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

}
