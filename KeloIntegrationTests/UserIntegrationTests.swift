//
//  UserIntegrationTests.swift
//  KeloIntegrationTests
//
//  Created by Raul Olmedo on 22/4/21.
//

import XCTest
@testable import Kelo

class UserIntegrationTests: XCTestCase {

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

    func testUserCreation() throws {
        let expectation = XCTestExpectation(description: "Wait for the creation of the user")
        let testUser = User(name: "UserCreation", points: 0)

        DatabaseManager.shared.createUser(user: testUser) { (creationResult) in
            switch creationResult {
            case .failure(let err):
                XCTFail(err.localizedDescription)
            case .success(let createdUser):
                DatabaseManager.shared.deleteUser(userId: createdUser.id!) { (deletionResult) in
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

    func testUserRetrieval() throws {
        let expectation = XCTestExpectation(description: "Wait for the retrieval of the user")
        let testUser = User(name: "UserRetrieval", points: 0)

        DatabaseManager.shared.createUser(user: testUser) { (creationResult) in
            switch creationResult {
            case .failure(let err):
                XCTFail(err.localizedDescription)
            case .success(let createdUser):
                DatabaseManager.shared.retrieveUser(userId: createdUser.id!) { (retrievalResult) in
                    switch retrievalResult {
                    case .failure(let err):
                        XCTFail(err.localizedDescription)
                    case .success(let retrievedUser):
                        XCTAssertEqual(retrievedUser.id, createdUser.id)
                        DatabaseManager.shared.deleteUser(userId: createdUser.id!) { (deletionResult) in
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

    func testAllUsersRetrieval() throws {
        let expectation = XCTestExpectation(description: "Wait for the retrieval of all users")
        let testUser1 = User(name: "AllUsersRetrieval1", points: 0)
        let testUser2 = User(name: "AllUsersRetrieval2", points: 0)

        DatabaseManager.shared.createUser(user: testUser1) { (creationResult1) in
            switch creationResult1 {
            case .failure(let err):
                XCTFail(err.localizedDescription)
            case .success:
                DatabaseManager.shared
                    .createUser(user: testUser2) { (creationResult2) in
                        switch creationResult2 {
                        case .failure(let err):
                            XCTFail(err.localizedDescription)
                        case .success:
                            DatabaseManager.shared
                                .retrieveAllUsers { (retrievalResult) in
                                    switch retrievalResult {
                                    case .failure(let err):
                                        XCTFail(err.localizedDescription)
                                    case .success(let retrievedUsers):
                                        XCTAssert(retrievedUsers.count == 2)
                                        expectation.fulfill()
                                    }
                                }
                        }
                    }
            }
        }
        wait(for: [expectation], timeout: 3)
    }

    func testUserUpdate() throws {
        let expectation = XCTestExpectation(description: "Wait for the update of the user")
        let testUser = User(name: "UserUpdate", points: 0)
        var updatedUser = User(name: "UpdatedUserName", points: 0)

        DatabaseManager.shared.createUser(user: testUser) { (creationResult) in
            switch creationResult {
            case .failure(let err):
                XCTFail(err.localizedDescription)
            case .success(let createdUser):
                updatedUser.id = createdUser.id
                DatabaseManager.shared.updateUser(user: updatedUser) { (updateResult) in
                    switch updateResult {
                    case .failure(let err):
                        XCTFail(err.localizedDescription)
                    case .success:
                        XCTAssertEqual(createdUser.id, updatedUser.id)
                        DatabaseManager.shared.deleteUser(userId: updatedUser.id!) { (deletionResult) in
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

    func testUserDeletion() throws {
        let expectation = XCTestExpectation(description: "Wait for the deletion of the user")
        let testUser = User(name: "UserDeletion", points: 0)

        DatabaseManager.shared.createUser(user: testUser) { (creationResult) in
            switch creationResult {
            case .failure(let err):
                XCTFail(err.localizedDescription)
            case .success(let createdUser):
                DatabaseManager.shared.deleteUser(userId: createdUser.id!) { (result) in
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

    func testAllUsersDeletion() throws {
        let expectation = XCTestExpectation(description: "Wait for the deletion of all users")
        let testUser1 = User(name: "AllUsersDeletion1", points: 0)
        let testUser2 = User(name: "AllUsersDeletion2", points: 0)

        DatabaseManager.shared.retrieveGroup(groupId: DatabaseManager.shared.groupId!) { (retrievalResult) in
            switch retrievalResult {
            case .failure(let err):
                XCTFail(err.localizedDescription)
            case .success(let group):
                DatabaseManager.shared.joinGroup(user: testUser1, group: group) { (joinResult1) in
                    switch joinResult1 {
                    case .failure(let err):
                        XCTFail(err.localizedDescription)
                    case .success:
                        DatabaseManager.shared.joinGroup(user: testUser2, group: group) { (joinResult2) in
                            switch joinResult2 {
                            case .failure(let err):
                                XCTFail(err.localizedDescription)
                            case .success:
                                DatabaseManager.shared
                                    .deleteAllUsers { (deletionResult) in
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
            }
        }
        wait(for: [expectation], timeout: 2)
    }

    func testGroupJoining() throws {
        let expectation = XCTestExpectation(description: "Wait for the user to join the group")
        let testUser = User(name: "UserJoin", points: 0)

        DatabaseManager.shared.retrieveGroup(groupId: DatabaseManager.shared.groupId!) { (retrievalResult) in
            switch retrievalResult {
            case .failure(let err):
                XCTFail(err.localizedDescription)
            case .success(let group):
                DatabaseManager.shared.joinGroup(user: testUser, group: group) { (joinResult) in
                    switch joinResult {
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

    func testUserNameAvilabilityCheck() throws {
        let expectation = XCTestExpectation(description: "Wait for the availability check of the user")
        let testUser = User(name: "NewUserName", points: 0)

        DatabaseManager.shared.checkUserNameAvilability(userName: testUser.name) { (result) in
            switch result {
            case .failure(let err):
                XCTFail(err.localizedDescription)
            case .success:
                expectation.fulfill()
            }
        }
        wait(for: [expectation], timeout: 2)
    }
}
