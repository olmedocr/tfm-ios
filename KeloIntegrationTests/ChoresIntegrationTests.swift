//
//  ChoresIntegrationTests.swift
//  KeloIntegrationTests
//
//  Created by Raul Olmedo on 5/5/21.
//

import XCTest
@testable import Kelo

class ChoresIntegrationTests: XCTestCase {

    override func setUpWithError() throws {
        let expectation = XCTestExpectation(description: "Wait for the creation of the group")
        let testGroup = Group(name: "GroupName", currency: "USD")

        DatabaseManager.shared.createGroup(group: testGroup) { (result) in
            switch result {
            case .failure(let err):
                XCTFail("Failed to do one time setup with error: \(err)")
            case .success(let group):
                DatabaseManager.shared.groupId = group.id
                expectation.fulfill()
            }
        }
        wait(for: [expectation], timeout: 2)
    }

    override func tearDownWithError() throws {
        let expectation = XCTestExpectation(description: "Wait for the creation of the group")

        DatabaseManager.shared.deleteGroup(groupId: DatabaseManager.shared.groupId!) { (result) in
            switch result {
            case .failure(let err):
                XCTFail("Failed to do one time teardown with error: \(err)")
            case .success:
                expectation.fulfill()
            }
        }
        wait(for: [expectation], timeout: 2)
    }

    func testChoreCreation() throws {
        let expectation = XCTestExpectation(description: "Wait for the creation of the chore")
        let tomorrow = Date().addingTimeInterval(86400)
        let testChore = Chore(name: "ChoreCreation", icon: "", assignee: "", expiration: tomorrow, points: 0)

        DatabaseManager.shared.createChore(chore: testChore) { (creationResult) in
            switch creationResult {
            case .failure(let err):
                XCTFail(err.localizedDescription)
            case .success(let createdChore):
                DatabaseManager.shared.deleteChore(choreId: createdChore.id!) { (deletionResult) in
                    switch deletionResult {
                    case .failure(let err):
                        XCTFail("Failed to do cleanup with error: \(err)")
                    case .success:
                        expectation.fulfill()
                    }
                }
            }
        }
        wait(for: [expectation], timeout: 2)
    }

    func testChoreRetrieval() throws {
        let expectation = XCTestExpectation(description: "Wait for the retrieval of the chore")
        let tomorrow = Date().addingTimeInterval(86400)
        let testChore = Chore(name: "ChoreRetrieval", icon: "", assignee: "", expiration: tomorrow, points: 0)

        DatabaseManager.shared.createChore(chore: testChore) { (creationResult) in
            switch creationResult {
            case .failure(let err):
                XCTFail(err.localizedDescription)
            case .success(let createdChore):
                DatabaseManager.shared.retrieveChore(choreId: createdChore.id!) { (retrievalResult) in
                    switch retrievalResult {
                    case .failure(let err):
                        XCTFail(err.localizedDescription)
                    case .success(let retrievedUser):
                        XCTAssertEqual(retrievedUser.id, createdChore.id)
                        DatabaseManager.shared.deleteChore(choreId: createdChore.id!) { (deletionResult) in
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

    func testChoreUpdate() throws {
        let expectation = XCTestExpectation(description: "Wait for the update of the chore")
        let tomorrow = Date().addingTimeInterval(86400)
        let testChore = Chore(name: "ChoreUpdate", icon: "", assignee: "", expiration: tomorrow, points: 0)
        var updatedChore = Chore(name: "UpdatedChore", icon: "", assignee: "", expiration: tomorrow, points: 0)

        DatabaseManager.shared.createChore(chore: testChore) { (creationResult) in
            switch creationResult {
            case .failure(let err):
                XCTFail(err.localizedDescription)
            case .success(let createdChore):
                updatedChore.id = createdChore.id
                DatabaseManager.shared.updateChore(chore: updatedChore) { (updateResult) in
                    switch updateResult {
                    case .failure(let err):
                        XCTFail(err.localizedDescription)
                    case .success:
                        XCTAssertEqual(createdChore.id, updatedChore.id)
                        DatabaseManager.shared.deleteChore(choreId: updatedChore.id!) { (deletionResult) in
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

    func testAllChoresDeletion() {
        let expectation = XCTestExpectation(description: "Wait for the deletion of the chores")
        let tomorrow = Date().addingTimeInterval(86400)
        let testChore1 = Chore(name: "AllChoresDeletion1", icon: "", assignee: "", expiration: tomorrow, points: 0)
        let testChore2 = Chore(name: "AllChoresDeletion2", icon: "", assignee: "", expiration: tomorrow, points: 0)

        DatabaseManager.shared.createChore(chore: testChore1) { (creationResult1) in
            switch creationResult1 {
            case .failure(let err):
                XCTFail(err.localizedDescription)
            case .success:
                DatabaseManager.shared.createChore(chore: testChore2) { (creationResult2) in
                    switch creationResult2 {
                    case .failure(let err):
                        XCTFail(err.localizedDescription)
                    case .success:
                        DatabaseManager.shared
                            .deleteAllChores { (deletionResult) in
                                switch deletionResult {
                                case .failure(let err):
                                    XCTFail(err.localizedDescription)
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

}
