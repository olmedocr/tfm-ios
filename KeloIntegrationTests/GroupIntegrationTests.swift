//
//  KeloIntegrationTests.swift
//  KeloIntegrationTests
//
//  Created by Raul Olmedo on 22/4/21.
//

import XCTest
@testable import Kelo

class GroupIntegrationTests: XCTestCase {

    func testGroupCreation() throws {
        let expectation = XCTestExpectation(description: "Wait for the creation of the group")
        let testGroup = Group(name: "GroupCreation", currency: "USD")

        DatabaseManager.shared.createGroup(group: testGroup) { (result) in
            switch result {
            case .failure(let err):
                XCTFail(err.localizedDescription)
            case .success(let group):
                DatabaseManager.shared.deleteGroup(groupId: group.id!) { (result) in
                    switch result {
                    case .success:
                        expectation.fulfill()
                    case .failure(let err):
                        XCTFail("Failed to do cleanup with error: \(err)")
                    }
                }
            }
        }
        wait(for: [expectation], timeout: 2)
    }

    func testGroupRetrieval() throws {
        let expectation = XCTestExpectation(description: "Wait for the retrieval of the group")
        let testGroup = Group(name: "GroupRetrieval", currency: "USD")

        DatabaseManager.shared.createGroup(group: testGroup) { (creationResult) in
            switch creationResult {
            case .failure(let err):
                XCTFail("\(err)")
            case .success(let createdGroup):
                DatabaseManager.shared.retrieveGroup(groupId: createdGroup.id!) { (retrievalResult) in
                    switch retrievalResult {
                    case .failure(let err):
                        XCTFail(err.localizedDescription)
                    case .success(let retrievedGroup):
                        XCTAssertEqual(retrievedGroup.id, createdGroup.id)
                        DatabaseManager.shared.deleteGroup(groupId: createdGroup.id!) { (deletionResult) in
                            switch deletionResult {
                            case .success:
                                expectation.fulfill()
                            case .failure(let err):
                                XCTFail("Failed to do cleanup with error: \(err)")
                            }
                        }
                    }
                }
            }
        }
        wait(for: [expectation], timeout: 2)
    }

    func testGroupUpdate() throws {
        let expectation = XCTestExpectation(description: "Wait for the group update")
        let testGroup = Group(name: "GroupUpdate", currency: "USD")
        var updatedGroup = Group(name: "UpdatedGroupName", currency: "USD")

        DatabaseManager.shared.createGroup(group: testGroup) { (creationResult) in
            switch creationResult {
            case .failure(let err):
                XCTFail(err.localizedDescription)
            case .success(let createdGroup):
                updatedGroup.id = createdGroup.id
                DatabaseManager.shared.updateGroup(group: updatedGroup) { (updateResult) in
                    switch updateResult {
                    case .failure(let err):
                        XCTFail(err.localizedDescription)
                    case .success:
                        XCTAssertEqual(createdGroup.id, updatedGroup.id)
                        DatabaseManager.shared.deleteGroup(groupId: updatedGroup.id!) { (deletionResult) in
                            switch deletionResult {
                            case .failure(let err):
                                XCTFail("Failed to do cleanup with error: \(err)")
                            case .success:
                                expectation.fulfill()
                            }
                        }
                    }
                }
            }
        }
        wait(for: [expectation], timeout: 2)
    }

    func testGroupDeletion() throws {
        let expectation = XCTestExpectation(description: "Wait for the group deletion")
        let testGroup = Group(name: "GroupDeletion", currency: "USD")

        DatabaseManager.shared.createGroup(group: testGroup) { (creationResult) in
            switch creationResult {
            case .failure(let err):
                XCTFail(err.localizedDescription)
            case .success(let createdGroup):
                DatabaseManager.shared.deleteGroup(groupId: createdGroup.id!) { (result) in
                    switch result {
                    case .failure(let err):
                        XCTFail(err.localizedDescription)
                    case .success:
                        expectation.fulfill()
                    }
                }
            }
        }
        wait(for: [expectation], timeout: 2)
    }

    func testGroupAvailability() throws {
        let expectation = XCTestExpectation(description: "Wait for the group deletion")
        let testGroup = Group(name: "GroupAvailability", currency: "USD")

        DatabaseManager.shared.createGroup(group: testGroup) { (creationResult) in
            switch creationResult {
            case .failure(let err):
                XCTFail(err.localizedDescription)
            case .success(let createdGroup):
                DatabaseManager.shared.checkGroupAvailability(groupId: createdGroup.id!) { (result) in
                    switch result {
                    case .failure(let err):
                        XCTFail(err.localizedDescription)
                    case .success:
                        DatabaseManager.shared.deleteGroup(groupId: createdGroup.id!) { (deletionResult) in
                            switch deletionResult {
                            case .failure(let err):
                                XCTFail("Failed to do cleanup with error: \(err)")
                            case .success:
                                expectation.fulfill()
                            }
                        }
                    }
                }
            }
        }
        wait(for: [expectation], timeout: 3)
    }
}
