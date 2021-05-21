//
//  Database+Groups.swift
//  Kelo
//
//  Created by Raul Olmedo on 5/5/21.
//

import Firebase

extension DatabaseManager {

    // MARK: - Queries
    func createGroup(group: Group, result: @escaping (Result<Group, Error>) -> Void) {
        let groupsReference: CollectionReference = database.collection(Constants.groupsCollectionKey)
        do {
            let groupReference = try groupsReference.addDocument(from: group) { (err) in
                if let err = err {
                    log.error(err.localizedDescription)
                    result(.failure(err))
                }
            }
            /*
             FIXME: Check that these operations are not executed when there is an error,
             does the try always return non-nil groupReferences?
             */
            log.info("Successfully created group")

            var returnedGroup = group
            returnedGroup.id = groupReference.documentID
            result(.success(returnedGroup))
        } catch let err {
            log.error(err.localizedDescription)
            result(.failure(err))
        }
    }

    func retrieveGroup(groupId: String, result: @escaping (Result<Group, Error>) -> Void) {
        let groupReference: DocumentReference = database.collection(Constants.groupsCollectionKey).document(groupId)
        groupReference.getDocument { (groupSnapshot, err) in
            if let err = err {
                log.error(err.localizedDescription)
                result(.failure(err))
            }

            do {
                if let group = try groupSnapshot?.data(as: Group.self) {
                    log.info("Successfully retrieved group")
                    result(.success(group))
                }
            } catch let err {
                log.error(err.localizedDescription)
                result(.failure(err))
            }
        }
    }

    func updateGroup(group: Group, result: @escaping (Result<Void, Error>) -> Void) {
        let groupReference: DocumentReference = database.collection(Constants.groupsCollectionKey).document(group.id!)
        do {
            let encodedGroup = try Firestore.Encoder().encode(group)
            groupReference.updateData(encodedGroup) { (err) in
                if let err = err {
                    log.error(err.localizedDescription)
                    result(.failure(err))
                }

                log.info("Successfully updated group")
                result(.success(()))
            }
        } catch let err {
            log.error(err.localizedDescription)
            result(.failure(err))
        }
    }

    func deleteGroup(groupId: String, result: @escaping (Result<Void, Error>) -> Void) {
        let group = DispatchGroup()
        let groupsReference: CollectionReference = database.collection(Constants.groupsCollectionKey)

        group.enter()
        deleteAllUsers { (deleteResult) in
            switch deleteResult {
            case .failure(let err):
                log.error(err.localizedDescription)
                result(.failure(err))
            case .success:
                log.info("Correctly deleted all users from group")
                groupsReference.document(groupId).delete { (err) in
                    if let err = err {
                        log.error(err.localizedDescription)
                        result(.failure(err))
                        group.leave()
                    }

                    group.leave()
                }
            }
        }

        group.enter()
        deleteAllChores { (deleteResult) in
            switch deleteResult {
            case .failure(let err):
                log.error(err.localizedDescription)
                result(.failure(err))
            case .success:
                log.info("Correctly deleted all chores from group")
                groupsReference.document(groupId).delete { (err) in
                    if let err = err {
                        log.error(err.localizedDescription)
                        result(.failure(err))
                        group.leave()
                    }

                    group.leave()
                }
            }
        }

        group.notify(queue: .main) {
            log.info("Successfully deleted group")
            result(.success(()))
        }

    }

    func checkGroupAvailability(groupId: String, result: @escaping (Result<Group, Error>) -> Void) {
        let groupReference: DocumentReference = database.collection(Constants.groupsCollectionKey).document(groupId)

        groupReference.getDocument { (groupSnapshot, err) in
            if let err = err {
                log.error(err.localizedDescription)
                result(.failure(err))
            }

            if let groupSnapshot = groupSnapshot, groupSnapshot.exists {
                groupSnapshot
                    .reference
                    .collection(Constants.usersCollectionKey)
                    .getDocuments { (usersSnapshot, err) in
                        if let err = err {
                            log.error(err.localizedDescription)
                            result(.failure(err))
                        }

                        if let usersSnapshot = usersSnapshot {
                            if usersSnapshot.documents.count == 16 {
                                log.warning("Group is full")
                                result(.failure(CustomError.groupIsFull))
                            } else {
                                do {
                                    if let group = try groupSnapshot.data(as: Group.self) {
                                        log.info("Group is available")
                                        result(.success(group))
                                    }
                                } catch let err {
                                    log.error(err.localizedDescription)
                                    result(.failure(err))
                                }
                            }
                        }
                    }
            } else {
                log.error("Group does not exist")
                result(.failure(CustomError.groupNotFound))
            }
        }
    }

    func checkUserNameAvilability(userName: String,
                                  result: @escaping (Result<Void, Error>) -> Void) {

        let groupReference: DocumentReference = database.collection(Constants.groupsCollectionKey).document(groupId!)

        groupReference.collection(Constants.usersCollectionKey)
            .whereField(User.CodingKeys.name.stringValue, isEqualTo: userName)
            .getDocuments { (querySnapshot, err) in
                if let err = err {
                    log.error(err.localizedDescription)
                    result(.failure(err))
                }

                if let querySnapshot = querySnapshot, querySnapshot.documents.isEmpty {
                    log.info("User is not in the group")
                    result(.success(()))
                } else {
                    log.error("User is already in the group")
                    result(.failure(CustomError.userNameAlreadyTaken))
                }
            }
    }
}
