//
//  UserTests.swift
//  KeloIntegrationTests
//
//  Created by Raul Olmedo on 22/4/21.
//

import XCTest
@testable import Kelo

// swiftlint:disable type_body_length file_length
class UserTests: XCTestCase {

    static var group: Group!
    var isDeleteListenerTriggered: Bool!

    override func setUp() {
        let expectation = XCTestExpectation(description: "Wait for the creation of the group")
        let testGroup = Group(name: "GroupName", currency: "USD")

        DatabaseManager.shared.createGroup(group: testGroup) { (result) in
            switch result {
            case .failure(let err):
                XCTFail("Failed to do one time setup with error: \(err)")
            case .success(let group):
                UserTests.group = group
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

    func testUserCreation() throws {
        let expectation = XCTestExpectation(description: "Wait for the creation of the user")
        let testUser = User(name: "UserCreation")

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
        let testUser = User(name: "UserRetrieval")

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

    func testMostLazyUserRetrieval() throws {
        let expectation = XCTestExpectation(description: "Wait for the retrieval of the most lazy user")
        let normalUser = User(name: "LazyUserRetrieval1", points: 30)
        let lazyUser = User(name: "LazyUserRetrieval2", points: 10)

        DatabaseManager.shared.createUser(user: normalUser) { (creationResult1) in
            switch creationResult1 {
            case .failure(let err):
                XCTFail(err.localizedDescription)
            case .success(let createdUser1):
                DatabaseManager.shared
                    .createUser(user: lazyUser) { (creationResult2) in
                        switch creationResult2 {
                        case .failure(let err):
                            XCTFail(err.localizedDescription)
                        case .success(let createdUser2):
                            DatabaseManager.shared.getMostLazyUser { (result) in
                                switch result {
                                case .failure(let err):
                                    XCTFail(err.localizedDescription)
                                case .success(let user):
                                    XCTAssertTrue(user.id == createdUser2.id)
                                    DatabaseManager.shared.deleteUser(userId: createdUser1.id!) { (deletionResult1) in
                                        switch deletionResult1 {
                                        case .failure(let err):
                                            XCTFail("Failed to do cleanup with error: \(err)")
                                        case .success:
                                            DatabaseManager.shared
                                                .deleteUser(userId: createdUser2.id!) { (deletionResult2) in
                                                    switch deletionResult2 {
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
                        }
                    }
            }
        }
        wait(for: [expectation], timeout: 3)
    }

    func testRandomUserRetrieval() throws {
        let expectation = XCTestExpectation(description: "Wait for the retrieval of a random user")
        let testUser1 = User(name: "RandomUserRetrieval1", points: 30)
        let testUser2 = User(name: "RandomUserRetrieval2", points: 10)

        DatabaseManager.shared.createUser(user: testUser1) { (creationResult1) in
            switch creationResult1 {
            case .failure(let err):
                XCTFail(err.localizedDescription)
            case .success(let createdUser1):
                DatabaseManager.shared
                    .createUser(user: testUser2) { (creationResult2) in
                        switch creationResult2 {
                        case .failure(let err):
                            XCTFail(err.localizedDescription)
                        case .success(let createdUser2):
                            DatabaseManager.shared.getRandomUser { (result) in
                                switch result {
                                case .failure(let err):
                                    XCTFail(err.localizedDescription)
                                case .success(let user):
                                    XCTAssertTrue(user.id == createdUser2.id || user.id == createdUser1.id)
                                    DatabaseManager.shared.deleteUser(userId: createdUser1.id!) { (deletionResult1) in
                                        switch deletionResult1 {
                                        case .failure(let err):
                                            XCTFail("Failed to do cleanup with error: \(err)")
                                        case .success:
                                            DatabaseManager.shared
                                                .deleteUser(userId: createdUser2.id!) { (deletionResult2) in
                                                    switch deletionResult2 {
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
                        }
                    }
            }
        }
        wait(for: [expectation], timeout: 3)
    }

    func testAllUsersRetrieval() throws {
        let expectation = XCTestExpectation(description: "Wait for the retrieval of all users")
        let testUser1 = User(name: "AllUsersRetrieval1")
        let testUser2 = User(name: "AllUsersRetrieval2")

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
        let testUser = User(name: "UserUpdate")
        var updatedUser = User(name: "UpdatedUserName")

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
        let testUser = User(name: "UserDeletion")

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
        let testUser1 = User(name: "AllUsersDeletion1")
        let testUser2 = User(name: "AllUsersDeletion2")

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
                                        .deleteAllUsers(groupId: DatabaseManager.shared.groupId!) { (deletionResult) in
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
        let testUser = User(name: "UserJoin")

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

    func testUserNameIsAvailableCheck() throws {
        let expectation = XCTestExpectation(description: "Wait for the availability check of the user")
        let testUser = User(name: "NewUserName")

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

    func testUserNameIsNotAvailableCheck() throws {
        let expectation = XCTestExpectation(description: "Wait for the availability check of the user")
        let testUser = User(name: "ExistingUserName")

        DatabaseManager.shared.createUser(user: testUser) { result in
            switch result {
            case .failure(let err):
                log.error(err.localizedDescription)
                XCTFail(err.localizedDescription)
            case .success(let user):
                DatabaseManager.shared.checkUserNameAvilability(userName: testUser.name) { (result) in
                    switch result {
                    case .failure(_):
                        XCTAssertTrue(testUser.name == user.name)
                        expectation.fulfill()
                    case .success:
                        XCTFail("User should not be available")
                    }
                }
            }
        }
        wait(for: [expectation], timeout: 2)
    }

    func testAdminAssignmentIfCreator() throws {
        let expectation = XCTestExpectation(description: "Wait for the admin check")

        DatabaseManager.shared.checkIfNewUserIsAdmin { (result) in
            switch result {
            case .failure(let err):
                log.error(err.localizedDescription)
            case .success(let isAdmin):
                XCTAssertTrue(isAdmin)
                expectation.fulfill()
            }
        }

        wait(for: [expectation], timeout: 2)
    }

    // swiftlint:disable cyclomatic_complexity
    func testAdminChangeOnGroupLeave() throws {
        let expectation = XCTestExpectation(description: "Wait for the availability check of the user")
        let testUser1 = User(name: "OldAdmin", isAdmin: true)
        let testUser2 = User(name: "NewAdmin?")
        let testUser3 = User(name: "NewAdmin?")

        DatabaseManager.shared.createUser(user: testUser1) { (creationResult1) in
            switch creationResult1 {
            case .failure(let err):
                log.error(err.localizedDescription)
            case .success(let createdUser1):
                DatabaseManager.shared.createUser(user: testUser2) { (creationResult2) in
                    switch creationResult2 {
                    case .failure(let err):
                        log.error(err.localizedDescription)
                    case .success:
                        XCTAssertTrue(createdUser1.isAdmin)
                        DatabaseManager.shared.createUser(user: testUser3) { (creationResult3) in
                            switch creationResult3 {
                            case .failure(let err):
                                log.error(err.localizedDescription)
                            case .success:
                                DatabaseManager.shared.deleteUser(userId: createdUser1.id!) { (deletionResult) in
                                    switch deletionResult {
                                    case .failure(let err):
                                        log.error(err.localizedDescription)
                                    case .success:
                                        DatabaseManager.shared.setAdminRandomly { (adminResult) in
                                            switch adminResult {
                                            case .failure(let err):
                                                log.error(err.localizedDescription)
                                            case .success:
                                                DatabaseManager.shared.retrieveAllUsers { (retrievalResult) in
                                                    switch retrievalResult {
                                                    case .failure(let err):
                                                        log.error(err.localizedDescription)
                                                    case .success(let users):
                                                        users.forEach { user in
                                                            if user.isAdmin {
                                                                expectation.fulfill()
                                                            }
                                                        }
                                                    }
                                                }
                                            }
                                        }
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

    func testUserDeletionListener() throws {
        let expectation = XCTestExpectation(description: "Wait for the deletion of the user")
        let testUser = User(name: "UserDeletionListener")

        DatabaseManager.shared.delegate = self

        DatabaseManager.shared.subscribeToUserList { (result) in
            switch result {
            case .failure(let err):
                XCTFail(err.localizedDescription)
            case .success:
                DatabaseManager.shared.createUser(user: testUser) { (creationResult) in
                    switch creationResult {
                    case .failure(let err):
                        XCTFail(err.localizedDescription)
                    case .success(let createdUser):
                        DatabaseManager.shared.deleteUser(userId: createdUser.id!) { (deletionResult) in
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

    func testNonExistingAssignee() throws {
        let expectation = XCTestExpectation(description: "Wait for the assignment of the user")

        DatabaseManager.shared.retrieveUser(userId: "NonExistingUserId") { (retrievalResult) in
            switch retrievalResult {
            case .failure(_):
                expectation.fulfill()

            case .success:
                XCTFail("Assignee does exist")
            }
        }
        wait(for: [expectation], timeout: 2)
    }

    func testGroupValidity() throws {
        let expectation = XCTestExpectation(description: "Wait for the validity check")
        let testUser = User(name: "DummyUser")

        DatabaseManager.shared.joinGroup(user: testUser,
                                         group: UserTests.group) { joinResult in
            switch joinResult {
            case .failure(let err):
                XCTFail(err.localizedDescription)
            case .success(let userId):
                Validations.userInGroup(userId,
                                        groupId: DatabaseManager.shared.groupId!) { (validationResult) in

                    switch validationResult {
                    case .failure(let err):
                        XCTFail(err.localizedDescription)
                    case .success:
                        expectation.fulfill()
                    }
                }
            }
        }

        wait(for: [expectation], timeout: 3)
    }

    func testDeletedGroupValidity() throws {
        let expectation = XCTestExpectation(description: "Wait for the validity check")

        Validations.userInGroup("NonExistingId", groupId: "NonExistingId") { (validationResult) in
            switch validationResult {
            case .failure(let err):
                XCTAssert(err is EvaluateError)
                expectation.fulfill()
            case .success:
                XCTFail("Group should be invalid")
            }
        }

        wait(for: [expectation], timeout: 3)
    }

    func testDeletedUserValidity() throws {
        let expectation = XCTestExpectation(description: "Wait for the validity check")

        Validations.userInGroup("NonExistingId", groupId: DatabaseManager.shared.groupId!) { (validationResult) in
            switch validationResult {
            case .failure(let err):
                XCTAssert(err is EvaluateError)
                expectation.fulfill()
            case .success:
                XCTFail("User should be invalid")
            }
        }

        wait(for: [expectation], timeout: 3)
    }

}

extension UserTests: DatabaseManagerDelegate {

    func didDeleteUser(user: User) {
        isDeleteListenerTriggered = true
    }

}
