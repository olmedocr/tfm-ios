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

    func deleteAllChores(result: @escaping (Result<Void, Error>) -> Void) {
        let groupsReference: CollectionReference = database.collection(Constants.groupsCollectionKey)

        groupsReference.document(groupId!).collection(Constants.choresCollectionKey)
            .getDocuments { (choresSnapshot, err) in
                if let err = err {
                    log.error(err.localizedDescription)
                    result(.failure(err))
                }

                let group = DispatchGroup()

                choresSnapshot?.documents.forEach({ (choreSnapshot) in
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
                })

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
                var updatedUser = User(name: user.name, points: user.points + chore.points)
                updatedUser.id = user.id
                DatabaseManager.shared.updateUser(user: updatedUser) { (updateResult) in
                    switch updateResult {
                    case .failure(let err):
                        log.error(err.localizedDescription)
                        result(.failure(err))
                    case .success:
                        DatabaseManager.shared.deleteChore(choreId: chore.id!) { (deletionResult) in
                            switch deletionResult {
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

    // MARK: - Listeners
    func subscribeToChoreList(result: @escaping (Result<Void, Error>) -> Void) {

        let groupReference: DocumentReference = database.collection(Constants.groupsCollectionKey).document(groupId!)
        let choresReference: CollectionReference = groupReference.collection(Constants.choresCollectionKey)

        let listener = choresReference.addSnapshotListener { (choresSnapshot, err) in
            guard let choresSnapshot = choresSnapshot else {
                if let err = err {
                    log.error(err.localizedDescription)
                    result(.failure(err))
                } else {
                    log.error("Unknown error")
                    result(.failure(CustomError.unknown))
                }

                return
            }

            choresSnapshot.documentChanges.forEach { diff in
                do {
                    let chore = try diff.document.data(as: Chore.self)

                    if diff.type == .added {
                        log.info("New chore: \(chore?.id ?? "nil")")
                        self.choreDelegate?.didAddChore(chore: chore!)
                    }
                    if diff.type == .modified {
                        log.info("Modified chore: \(chore?.id ?? "nil")")
                        self.choreDelegate?.didModifyChore(chore: chore!)
                    }
                    if diff.type == .removed {
                        log.info("Removed chore: \(chore?.id ?? "nil")")
                        self.choreDelegate?.didDeleteChore(chore: chore!)
                    }

                } catch let err {
                    log.error(err.localizedDescription)
                    result(.failure(err))
                }
            }
        }

        log.info("Correctly subscribed to chore list")
        listeners.append(listener)
        result(.success(()))
    }
}
