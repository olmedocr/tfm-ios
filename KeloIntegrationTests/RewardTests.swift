//
//  RewardTests.swift
//  KeloIntegrationTests
//
//  Created by Raul Olmedo on 14/6/21.
//

import XCTest
@testable import Kelo

class RewardTests: XCTestCase {

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
        let expectation = XCTestExpectation(description: "Wait for the deletion of the group")

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

    func testRewardCreation() {
        let expectation = XCTestExpectation(description: "Wait for the creation of the reward")
        let testReward = Reward(name: "RewardCreation")

        DatabaseManager.shared.createReward(reward: testReward) { (creationResult) in
            switch creationResult {
            case .failure(let err):
                XCTFail(err.localizedDescription)
            case .success(let createdReward):
                DatabaseManager.shared.deleteReward(rewardId: createdReward.id!) { (deletionResult) in
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

    func testRewardRetrieval() {
        let expectation = XCTestExpectation(description: "Wait for the retrieval of the reward")
        let testReward = Reward(name: "RewardRetrieval")

        DatabaseManager.shared.createReward(reward: testReward) { (creationResult) in
            switch creationResult {
            case .failure(let err):
                XCTFail(err.localizedDescription)
            case .success(let createdReward):
                DatabaseManager.shared.retrieveReward { (retrievalResult) in
                    switch retrievalResult {
                    case .failure(let err):
                        XCTFail(err.localizedDescription)
                    case .success(let retrievedReward):
                        XCTAssertEqual(createdReward.id, retrievedReward?.id)
                        DatabaseManager.shared.deleteReward(rewardId: createdReward.id!) { (deletionResult) in
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

    func testRewardUpdate() {
        let expectation = XCTestExpectation(description: "Wait for the update of the reward")
        let testReward = Reward(name: "RewardUpdate")
        var updatedReward = Reward(name: "RewardChore")

        DatabaseManager.shared.createReward(reward: testReward) { (creationResult) in
            switch creationResult {
            case .failure(let err):
                XCTFail(err.localizedDescription)
            case .success(let createdReward):
                updatedReward.id = createdReward.id
                DatabaseManager.shared.updateReward(reward: updatedReward) { (updateResult) in
                    switch updateResult {
                    case .failure(let err):
                        XCTFail(err.localizedDescription)
                    case .success:
                        XCTAssertEqual(createdReward.id, updatedReward.id)
                        DatabaseManager.shared.deleteReward(rewardId: updatedReward.id!) { (deletionResult) in
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

    func testRewardDeletion() {
        let expectation = XCTestExpectation(description: "Wait for the deletion of the reward")
        let testReward = Reward(name: "RewardDeletion")

        DatabaseManager.shared.createReward(reward: testReward) { (creationResult) in
            switch creationResult {
            case .failure(let err):
                XCTFail(err.localizedDescription)
            case .success(let createdReward):
                DatabaseManager.shared.deleteReward(rewardId: createdReward.id!) { (deletionResult) in
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

}
