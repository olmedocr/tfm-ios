//
//  Database+Users.swift
//  Kelo
//
//  Created by Raul Olmedo on 5/5/21.
//

import Firebase

extension DatabaseManager {

    // MARK: - Queries
    func createUser(user: User, result: @escaping (Result<User, Error>) -> Void) {
        let groupReference: DocumentReference = database.collection(Constants.groupsCollectionKey).document(groupId!)

        do {
            let userReference = try groupReference.collection(Constants.usersCollectionKey)
                .addDocument(from: user) { (err) in
                    if let err = err {
                        log.error(err.localizedDescription)
                        result(.failure(err))
                    }
                }
            log.info("Successfully created user")

            var returnedUser = user
            returnedUser.id = userReference.documentID
            result(.success(returnedUser))
        } catch let err {
            log.error(err.localizedDescription)
            result(.failure(err))
        }
    }

    func retrieveUser(userId: String, result: @escaping (Result<User, Error>) -> Void) {
        let groupReference: DocumentReference = database.collection(Constants.groupsCollectionKey).document(groupId!)
        let userReference: DocumentReference = groupReference.collection(Constants.usersCollectionKey).document(userId)

        userReference.getDocument { (userSnapshot, err) in
            if let err = err {
                log.error(err.localizedDescription)
                result(.failure(err))
            }

            if let exists = userSnapshot?.exists, !exists {
                log.error(CustomError.userNotFound)
                result(.failure(CustomError.userNotFound))
            }

            do {
                if let user = try userSnapshot?.data(as: User.self) {
                    log.info("Successfully retrieved user")
                    result(.success(user))
                }
            } catch let err {
                log.error(err.localizedDescription)
                result(.failure(err))
            }
        }
    }

    func retrieveAllUsers(result: @escaping (Result<[User], Error>) -> Void) {
        let groupsReference: CollectionReference = database.collection(Constants.groupsCollectionKey)
        var users: [User] = []

        groupsReference.document(groupId!)
            .collection(Constants.usersCollectionKey)
            .order(by: User.CodingKeys.name.rawValue)
            .getDocuments { (usersSnapshot, err) in
                if let err = err {
                    log.error(err.localizedDescription)
                    result(.failure(err))
                }

                let group = DispatchGroup()

                usersSnapshot?.documents.forEach { (userSnapshot) in
                    group.enter()
                    do {
                        if let user = try userSnapshot.data(as: User.self) {
                            users.append(user)
                            group.leave()
                        }
                    } catch let err {
                        log.error(err.localizedDescription)
                        result(.failure(err))
                        group.leave()
                    }
                }

                group.notify(queue: .main) {
                    log.info("Successfully retrieved all users")
                    result(.success(users))
                }
            }
    }

    func updateUser(user: User, result: @escaping (Result<Void, Error>) -> Void) {
        let groupReference: DocumentReference = database.collection(Constants.groupsCollectionKey).document(groupId!)
        let userReference: DocumentReference =
            groupReference.collection(Constants.usersCollectionKey).document(user.id!)

        do {
            let encodedUser = try Firestore.Encoder().encode(user)
            userReference.updateData(encodedUser) { (err) in
                if let err = err {
                    log.error(err.localizedDescription)
                    result(.failure(err))
                }

                log.info("Successfully updated user")
                result(.success(()))
            }
        } catch let err {
            log.error(err.localizedDescription)
            result(.failure(err))
        }
    }

    func deleteUser(userId: String, result: @escaping (Result<Void, Error>) -> Void) {
        let groupReference: DocumentReference = database.collection(Constants.groupsCollectionKey).document(groupId!)
        let usersReference: CollectionReference = groupReference.collection(Constants.usersCollectionKey)

        usersReference.document(userId).delete { (err) in
            if let err = err {
                log.error(err.localizedDescription)
                result(.failure(err))
            }

            log.info("Successfully deleted user")
            result(.success(()))
        }
    }

    func deleteAllUsers(groupId: String, result: @escaping (Result<Void, Error>) -> Void) {
        let groupsReference: CollectionReference = database.collection(Constants.groupsCollectionKey)

        groupsReference.document(groupId).collection(Constants.usersCollectionKey)
            .getDocuments { (usersSnapshot, err) in
                if let err = err {
                    log.error(err.localizedDescription)
                    result(.failure(err))
                }

                let group = DispatchGroup()

                usersSnapshot?.documents.forEach { (userSnapshot) in
                    group.enter()
                    do {
                        if let user = try userSnapshot.data(as: User.self) {
                            self.deleteUser(userId: user.id!) { (deleteResult) in
                                switch deleteResult {
                                case .failure(let err):
                                    log.error(err.localizedDescription)
                                    group.leave()
                                case .success:
                                    log.info("Deleted user on cascade")
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
                    log.info("Successfully deleted nested users")
                    result(.success(()))
                }
            }
    }

    func joinGroup(user: User, group: Group, result: @escaping (Result<String, Error>) -> Void) {
        let groupReference: DocumentReference = database.collection(Constants.groupsCollectionKey).document(group.id!)

        groupReference.getDocument { (groupDocument, err) in
            if let err = err {
                log.error(err.localizedDescription)
                result(.failure(err))
            }

            if let groupDocument = groupDocument, groupDocument.exists {
                self.checkUserNameAvilability(userName: user.name) { (isAvailable) in
                    switch isAvailable {
                    case let .failure(err):
                        log.error(err.localizedDescription)
                        result(.failure(err))
                    case .success:
                        self.createUser(user: user) { (joiningResult) in
                            switch joiningResult {
                            case .failure(let err):
                                log.error(err.localizedDescription)
                                result(.failure(err))
                            case .success(let createdUser):
                                log.info("Successfully joined user")
                                result(.success(createdUser.id!))
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

    func getMostLazyUser(result: @escaping (Result<User, Error>) -> Void) {
        let groupReference: DocumentReference = database.collection(Constants.groupsCollectionKey).document(groupId!)
        let usersReference: CollectionReference = groupReference.collection(Constants.usersCollectionKey)

        usersReference.order(by: User.CodingKeys.points.stringValue, descending: false).limit(to: 1)
            .getDocuments { (usersSnapshot, err) in
                if let err = err {
                    log.error(err.localizedDescription)
                    result(.failure(err))
                }

                do {
                    if let user = try usersSnapshot?.documents.first?.data(as: User.self) {
                        log.info("Retrieved most lazy user")
                        result(.success(user))
                    }
                } catch let err {
                    log.error(err.localizedDescription)
                    result(.failure(err))
                }
            }
    }

    func getRandomUser(result: @escaping (Result<User, Error>) -> Void) {
        let groupReference: DocumentReference = database.collection(Constants.groupsCollectionKey).document(groupId!)
        let usersReference: CollectionReference = groupReference.collection(Constants.usersCollectionKey)

        usersReference.getDocuments { (usersSnapshot, err) in
            if let err = err {
                log.error(err.localizedDescription)
                result(.failure(err))
            }
            let numberOfUsers = usersSnapshot?.documents.count
            let randomIndex = Int.random(in: 0...numberOfUsers! - 1)

            do {
                if let user = try usersSnapshot?.documents[randomIndex].data(as: User.self) {
                    log.info("Retrieved random user")
                    result(.success(user))
                }
            } catch let err {
                log.error(err.localizedDescription)
                result(.failure(err))
            }
        }
    }

    func setAdminRandomly(result: @escaping (Result<Void, Error>) -> Void) {
        let groupReference: DocumentReference = database.collection(Constants.groupsCollectionKey).document(groupId!)
        let usersReference: CollectionReference = groupReference.collection(Constants.usersCollectionKey)

        usersReference.getDocuments { (usersSnapshot, err) in
            if let err = err {
                log.error(err.localizedDescription)
                result(.failure(err))
            }
            let numberOfUsers = usersSnapshot?.documents.count

            if numberOfUsers! > 1 {
                let randomIndex = Int.random(in: 0...numberOfUsers! - 1)

                do {
                    let userDocument = usersSnapshot?.documents[randomIndex]
                    if var user = try userDocument?.data(as: User.self) {
                        log.info("Retrieved random user")
                        user.isAdmin = true

                        self.updateUser(user: user) { updateResult in
                            switch updateResult {
                            case .failure(let err):
                                log.error(err.localizedDescription)
                                result(.failure(err))
                            case .success(let user):
                                result(.success(user))
                            }
                        }
                    }
                } catch let err {
                    log.error(err.localizedDescription)
                    result(.failure(err))
                }
            } else {
                log.info("Last user in the group, skipped admin selection")
                result(.success(()))
            }
        }
    }

    func checkIfNewUserIsAdmin(result: @escaping (Result<Bool, Error>) -> Void) {
        let groupReference: DocumentReference = database.collection(Constants.groupsCollectionKey).document(groupId!)
        let usersReference: CollectionReference = groupReference.collection(Constants.usersCollectionKey)

        usersReference.getDocuments { (usersSnapshot, err) in
            if let err = err {
                log.error(err.localizedDescription)
                result(.failure(err))
            }
            let numberOfUsers = usersSnapshot?.documents.count

            result(.success(numberOfUsers == 0))
        }
    }

    // MARK: - Listeners
    func subscribeToUserList(result: @escaping (Result<ListenerRegistration, Error>) -> Void) {

        let groupReference: DocumentReference = database.collection(Constants.groupsCollectionKey).document(groupId!)
        let usersReference: CollectionReference = groupReference.collection(Constants.usersCollectionKey)

        let listener = usersReference.addSnapshotListener { (usersSnapshot, err) in
            guard let usersSnapshot = usersSnapshot else {
                if let err = err {
                    log.error(err.localizedDescription)
                    result(.failure(err))
                } else {
                    log.error("Unknown error")
                    result(.failure(CustomError.unknown))
                }

                return
            }

            usersSnapshot.documentChanges.forEach { diff in
                do {
                    let user = try diff.document.data(as: User.self)

                    if diff.type == .added {
                        log.info("New user: \(user?.id ?? "nil")")
                        self.delegate?.didAddUser(user: user!)
                    }
                    if diff.type == .modified {
                        log.info("Modified user: \(user?.id ?? "nil")")
                        self.delegate?.didModifyUser(user: user!)
                    }
                    if diff.type == .removed {
                        log.info("Removed user: \(user?.id ?? "nil")")
                        self.delegate?.didDeleteUser(user: user!)
                    }

                } catch let err {
                    log.error(err.localizedDescription)
                    result(.failure(err))
                }
            }
        }

        log.info("Correctly subscribed to user list")
        listeners.append(listener)
        result(.success(listener))
    }

}
