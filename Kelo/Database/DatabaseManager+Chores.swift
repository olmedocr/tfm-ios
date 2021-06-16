//
//  Database+Chores.swift
//  Kelo
//
//  Created by Raul Olmedo on 5/5/21.
//

import Firebase

extension DatabaseManager {

    // MARK: - Queries
    func createChore(chore: Chore, result: @escaping (Result<Chore, Error>) -> Void) {
        let groupReference: DocumentReference = database.collection(Constants.groupsCollectionKey).document(groupId!)

        do {
            let choreReference = try groupReference.collection(Constants.choresCollectionKey)
                .addDocument(from: chore) { (err) in
                    if let err = err {
                        log.error(err.localizedDescription)
                        result(.failure(err))
                    }
                }
            log.info("Successfully created chore")

            var returnedChore = chore
            returnedChore.id = choreReference.documentID
            result(.success(returnedChore))
        } catch let err {
            log.error(err.localizedDescription)
            result(.failure(err))
        }
    }

    func retrieveChore(choreId: String, result: @escaping (Result<Chore, Error>) -> Void) {
        let groupReference: DocumentReference =
            database.collection(Constants.groupsCollectionKey).document(groupId!)
        let choreReference: DocumentReference =
            groupReference.collection(Constants.choresCollectionKey).document(choreId)

        choreReference.getDocument { (choreSnapshot, err) in
            if let err = err {
                log.error(err.localizedDescription)
                result(.failure(err))
            }

            do {
                if let user = try choreSnapshot?.data(as: Chore.self) {
                    log.info("Successfully retrieved chore")
                    result(.success(user))
                }
            } catch let err {
                log.error(err.localizedDescription)
                result(.failure(err))
            }
        }
    }

    func retrieveAllChores(isCompleted: Bool, isAssigned: Bool, result: @escaping (Result<[Chore], Error>) -> Void) {
        let groupReference: DocumentReference = database.collection(Constants.groupsCollectionKey).document(groupId!)
        let choresReference: CollectionReference = groupReference.collection(Constants.choresCollectionKey)
        var chores: [Chore] = []

        if isAssigned {
            choresReference
                .order(by: Chore.CodingKeys.expiration.rawValue)
                .whereField(Chore.CodingKeys.isCompleted.rawValue, isEqualTo: isCompleted)
                .whereField(Chore.CodingKeys.assignee.rawValue, isEqualTo: DatabaseManager.shared.userId!)
                .getDocuments { (choresSnapshot, err) in
                    if let err = err {
                        log.error(err.localizedDescription)
                        result(.failure(err))
                    }

                    let group = DispatchGroup()

                    choresSnapshot?.documents.forEach { (choreSnapshot) in
                        group.enter()
                        do {
                            if let chore = try choreSnapshot.data(as: Chore.self) {
                                chores.append(chore)
                                group.leave()
                            }
                        } catch let err {
                            log.error(err.localizedDescription)
                            result(.failure(err))
                            group.leave()
                        }
                    }

                    group.notify(queue: .main) {
                        log.info("Successfully retrieved all chores")
                        result(.success(chores))
                    }
                }
        } else {
            choresReference
                .order(by: Chore.CodingKeys.expiration.rawValue)
                .whereField(Chore.CodingKeys.isCompleted.rawValue, isEqualTo: isCompleted)
                .getDocuments { (choresSnapshot, err) in
                    if let err = err {
                        log.error(err.localizedDescription)
                        result(.failure(err))
                    }

                    let group = DispatchGroup()

                    choresSnapshot?.documents.forEach { (choreSnapshot) in
                        group.enter()
                        do {
                            if let chore = try choreSnapshot.data(as: Chore.self) {
                                chores.append(chore)
                                group.leave()
                            }
                        } catch let err {
                            log.error(err.localizedDescription)
                            result(.failure(err))
                            group.leave()
                        }
                    }

                    group.notify(queue: .main) {
                        log.info("Successfully retrieved all chores")
                        result(.success(chores))
                    }
                }
        }
    }

    func updateChore(chore: Chore, result: @escaping (Result<Void, Error>) -> Void) {
        let groupReference: DocumentReference = database.collection(Constants.groupsCollectionKey).document(groupId!)
        let choreReference: DocumentReference =
            groupReference.collection(Constants.choresCollectionKey).document(chore.id!)

        do {
            let encodedChore = try Firestore.Encoder().encode(chore)
            choreReference.updateData(encodedChore) { (err) in
                if let err = err {
                    log.error(err.localizedDescription)
                    result(.failure(err))
                }

                log.info("Successfully updated chore")
                result(.success(()))
            }
        } catch let err {
            log.error(err.localizedDescription)
            result(.failure(err))
        }

    }

    func deleteChore(choreId: String, result: @escaping (Result<Void, Error>) -> Void) {
        let groupReference: DocumentReference = database.collection(Constants.groupsCollectionKey).document(groupId!)
        let choresReference: CollectionReference = groupReference.collection(Constants.choresCollectionKey)

        choresReference.document(choreId).delete { (err) in
            if let err = err {
                log.error(err.localizedDescription)
                result(.failure(err))
            }

            log.info("Successfully deleted chore")
            result(.success(()))
        }
    }

    func deleteAllChores(groupId: String, result: @escaping (Result<Void, Error>) -> Void) {
        let groupsReference: CollectionReference = database.collection(Constants.groupsCollectionKey)

        groupsReference.document(groupId).collection(Constants.choresCollectionKey)
            .getDocuments { (choresSnapshot, err) in
                if let err = err {
                    log.error(err.localizedDescription)
                    result(.failure(err))
                }

                let group = DispatchGroup()

                choresSnapshot?.documents.forEach { (choreSnapshot) in
                    group.enter()
                    do {
                        if let chore = try choreSnapshot.data(as: Chore.self) {
                            self.deleteChore(choreId: chore.id!) { (deleteResult) in
                                switch deleteResult {
                                case .failure(let err):
                                    log.error(err.localizedDescription)
                                    group.leave()
                                case .success:
                                    log.info("Deleted chore on cascade")
                                    group.leave()
                                }
                            }
                        }
                    } catch let err {
                        log.error(err.localizedDescription)
                        result(.failure(err))
                    }
                }

                group.notify(queue: .main) {
                    log.info("Successfully deleted nested chores")
                    result(.success(()))
                }
            }
    }

    func completeChore(chore: Chore, result: @escaping (Result<Void, Error>) -> Void) {
        DatabaseManager.shared.retrieveUser(userId: chore.assignee) { (retrievalResult) in
            switch retrievalResult {
            case .failure(let err):
                log.error(err.localizedDescription)
                result(.failure(err))
            case .success(let user):

                var updatedChore = chore
                updatedChore.isCompleted = true

                DatabaseManager.shared.updateChore(chore: updatedChore) { updateResult in
                    switch updateResult {
                    case .failure(let err):
                        log.error(err.localizedDescription)
                        result(.failure(err))
                    case .success:

                        var updatedUser = user
                        updatedUser.points = user.points + chore.points.rawValue

                        DatabaseManager.shared.updateUser(user: updatedUser) { (updateResult) in
                            switch updateResult {
                            case .failure(let err):
                                log.error(err.localizedDescription)
                                result(.failure(err))
                            case .success:
                                log.info("Correctly completed chore")
                                result(.success(()))
                            }
                        }
                    }
                }
            }
        }
    }

}
