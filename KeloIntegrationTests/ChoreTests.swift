//
//  ChoreTests.swift
//  KeloIntegrationTests
//
//  Created by Raul Olmedo on 5/5/21.
//

import XCTest
@testable import Kelo

class ChoreTests: XCTestCase {
    var isAddListenerTriggered: Bool!
    var isDeleteListenerTriggered: Bool!
    var isModifyListenerTriggered: Bool!

    override func setUp() {
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

    override func tearDown() {
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
        let testChore = Chore(name: "ChoreCreation")

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
        let testChore = Chore(name: "ChoreRetrieval")

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
        let testChore = Chore(name: "ChoreUpdate")
        var updatedChore = Chore(name: "UpdatedChore")

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

    func testAllChoresDeletion() throws {
        let expectation = XCTestExpectation(description: "Wait for the deletion of the chores")
        let testChore1 = Chore(name: "AllChoresDeletion1")
        let testChore2 = Chore(name: "AllChoresDeletion2")

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

    func testChoreDeletion() throws {
        let expectation = XCTestExpectation(description: "Wait for the deletion of the chore")
        let testChore = Chore(name: "ChoreDeletion")

        DatabaseManager.shared.createChore(chore: testChore) { (creationResult) in
            switch creationResult {
            case .failure(let err):
                XCTFail(err.localizedDescription)
            case .success(let createdChore):
                DatabaseManager.shared.deleteChore(choreId: createdChore.id!) { (deletionResult) in
                    switch deletionResult {
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

    func testChoreCompletion() throws {
        let expectation = XCTestExpectation(description: "Wait for the completion of the chore")
        let testUser = User(name: "UserName", points: 10)
        var testChore = Chore(name: "ChoreCompletion", points: 30)

        DatabaseManager.shared.createUser(user: testUser) { (creationResult1) in
            switch creationResult1 {
            case .failure(let err):
                log.error(err)
            case .success(let createdUser):
                DatabaseManager.shared.userId = createdUser.id
                testChore.assignee = createdUser.id!
                DatabaseManager.shared.createChore(chore: testChore) { (creationResult2) in
                    switch creationResult2 {
                    case .failure(let err):
                        XCTFail(err.localizedDescription)
                    case .success(let createdChore):
                        DatabaseManager.shared.completeChore(chore: createdChore) { (completionResult) in
                            switch completionResult {
                            case .failure(let err):
                                XCTFail(err.localizedDescription)
                            case .success:
                                DatabaseManager.shared
                                    .retrieveUser(userId: DatabaseManager.shared.userId!) { (retrievalResult) in
                                        switch retrievalResult {
                                        case .failure(let err):
                                            XCTFail(err.localizedDescription)
                                        case .success(let retrievedUser):
                                            XCTAssert(retrievedUser.points == testChore.points + testUser.points)
                                            expectation.fulfill()
                                        }
                                    }
                            }
                        }
                    }
                }
            }
        }
        wait(for: [expectation], timeout: 4)
    }

    func testChoreAdditionListener() throws {
        let expectation = XCTestExpectation(description: "Wait for the creation of the chore")
        let testChore = Chore(name: "ChoreAddListener")

        DatabaseManager.shared.delegate = self

        DatabaseManager.shared.subscribeToChoreList { (result) in
            switch result {
            case .failure(let err):
                XCTFail(err.localizedDescription)
            case .success:
                DatabaseManager.shared.createChore(chore: testChore) { (creationResult) in
                    switch creationResult {
                    case .failure(let err):
                        XCTFail(err.localizedDescription)
                    case .success(_):
                        _ = XCTWaiter
                            .wait(for: [XCTestExpectation(description: "Wait for the trigger of the listener")],
                                  timeout: 5.0)
                        XCTAssertTrue(self.isAddListenerTriggered)
                        expectation.fulfill()
                    }
                }
            }
        }
        wait(for: [expectation], timeout: 20)
    }

    func testChoreUpdateListener() throws {
        let expectation = XCTestExpectation(description: "Wait for the update of the chore")
        let testChore = Chore(name: "ChoreUpdateListener")

        DatabaseManager.shared.delegate = self

        DatabaseManager.shared.subscribeToChoreList { (result) in
            switch result {
            case .failure(let err):
                XCTFail(err.localizedDescription)
            case .success:
                DatabaseManager.shared.createChore(chore: testChore) { (creationResult) in
                    switch creationResult {
                    case .failure(let err):
                        XCTFail(err.localizedDescription)
                    case .success(let createdChore):
                        let updatedChore = Chore(id: createdChore.id, name: "UpdatedChore")
                        DatabaseManager.shared.updateChore(chore: updatedChore) { (updateResult) in
                            switch updateResult {
                            case .failure(let err):
                                log.error(err.localizedDescription)
                            case .success:
                                _ = XCTWaiter
                                    .wait(for: [XCTestExpectation(description: "Wait for the trigger of the listener")],
                                          timeout: 5.0)
                                XCTAssertTrue(self.isModifyListenerTriggered)
                                expectation.fulfill()
                            }
                        }
                    }
                }
            }
        }
        wait(for: [expectation], timeout: 20)
    }

    func testChoreDeletionListener() throws {
        let expectation = XCTestExpectation(description: "Wait for the deletion of the chore")
        let testChore = Chore(name: "ChoreDeletionListener")

        DatabaseManager.shared.delegate = self

        DatabaseManager.shared.subscribeToChoreList { (result) in
            switch result {
            case .failure(let err):
                XCTFail(err.localizedDescription)
            case .success:
                DatabaseManager.shared.createChore(chore: testChore) { (creationResult) in
                    switch creationResult {
                    case .failure(let err):
                        XCTFail(err.localizedDescription)
                    case .success(let createdChore):
                        DatabaseManager.shared.deleteChore(choreId: createdChore.id!) { (deletionResult) in
                            switch deletionResult {
                            case .failure(let err):
                                log.error(err.localizedDescription)
                            case .success:
                                _ = XCTWaiter
                                    .wait(for: [XCTestExpectation(description: "Wait for the trigger of the listener")],
                                          timeout: 5.0)
                                XCTAssertTrue(self.isDeleteListenerTriggered)
                                expectation.fulfill()
                            }
                        }
                    }
                }
            }
        }
        wait(for: [expectation], timeout: 20)
    }

}

extension ChoreTests: DatabaseManagerDelegate {
    func didAddChore(chore: Chore) {
        isAddListenerTriggered = true
    }

    func didModifyChore(chore: Chore) {
        isModifyListenerTriggered = true
    }

    func didDeleteChore(chore: Chore) {
        isDeleteListenerTriggered = true
    }

}
