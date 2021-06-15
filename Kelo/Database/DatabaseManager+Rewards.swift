//
//  DatabaseManager+Rewards.swift
//  Kelo
//
//  Created by Raul Olmedo on 9/6/21.
//

import Foundation
import Firebase

extension DatabaseManager {

    func createReward(reward: Reward, result: @escaping (Result<Reward, Error>) -> Void) {
        let groupReference: DocumentReference = database.collection(Constants.groupsCollectionKey).document(groupId!)

        do {
            let rewardReference = try groupReference.collection(Constants.rewardsCollectionKey)
                .addDocument(from: reward) { (err) in
                    if let err = err {
                        log.error(err.localizedDescription)
                        result(.failure(err))
                    }
                }
            log.info("Successfully created reward")

            var returnedReward = reward
            returnedReward.id = rewardReference.documentID
            result(.success(returnedReward))
        } catch let err {
            log.error(err.localizedDescription)
            result(.failure(err))
        }
    }

    func retrieveReward(result: @escaping (Result<Reward?, Error>) -> Void) {
        let groupReference: DocumentReference =
            database.collection(Constants.groupsCollectionKey).document(groupId!)
        let rewardReference: CollectionReference =
            groupReference.collection(Constants.rewardsCollectionKey)

        rewardReference
            .getDocuments { (rewardsSnapshot, err) in
                if let err = err {
                    log.error(err.localizedDescription)
                    result(.failure(err))
                }

                if let rewardsSnapshot = rewardsSnapshot, rewardsSnapshot.isEmpty {
                    log.warning(CustomError.rewardNotFound)
                    result(.success(nil))
                }

                do {
                    if let reward = try rewardsSnapshot?.documents.first?.data(as: Reward.self) {
                        log.info("Successfully retrieved reward")
                        result(.success(reward))
                    }
                } catch let err {
                    log.error(err.localizedDescription)
                    result(.failure(err))
                }
            }
    }

    func updateReward(reward: Reward, result: @escaping (Result<Void, Error>) -> Void) {
        let groupReference: DocumentReference = database.collection(Constants.groupsCollectionKey).document(groupId!)
        let rewardReference: DocumentReference =
            groupReference.collection(Constants.rewardsCollectionKey).document(reward.id!)

        do {
            let encodedReward = try Firestore.Encoder().encode(reward)
            rewardReference.updateData(encodedReward) { (err) in
                if let err = err {
                    log.error(err.localizedDescription)
                    result(.failure(err))
                }

                log.info("Successfully updated reward")
                result(.success(()))
            }
        } catch let err {
            log.error(err.localizedDescription)
            result(.failure(err))
        }
    }

    func deleteReward(rewardId: String, result: @escaping (Result<Void, Error>) -> Void) {
        let groupReference: DocumentReference = database.collection(Constants.groupsCollectionKey).document(groupId!)
        let rewardsReference: CollectionReference = groupReference.collection(Constants.rewardsCollectionKey)

        rewardsReference.document(rewardId).delete { (err) in
            if let err = err {
                log.error(err.localizedDescription)
                result(.failure(err))
            }

            log.info("Successfully deleted reward")
            result(.success(()))
        }
    }

}
