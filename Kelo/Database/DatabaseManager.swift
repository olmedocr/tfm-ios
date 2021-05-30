//
//  Database.swift
//  Kelo
//
//  Created by Raul Olmedo on 5/4/21.
//

import Firebase

extension DatabaseManager {
    enum CustomError: LocalizedError {
        case groupNotFound
        case userNotFound
        case userNameAlreadyTaken
        case groupIsFull
        case bundleError
        case unknown

        var errorDescription: String? {
            switch self {
            case .groupNotFound:
                return "Group not found"
            case .userNotFound:
                return "User not found"
            case .userNameAlreadyTaken:
                return "Username already taken"
            case .groupIsFull:
                return "Group is full"
            case .bundleError :
                return "No CurrencyList Bundle Access"
            case .unknown:
                return "Uknown error"
            }
        }
    }
}

protocol DatabaseManagerChoreDelegate: AnyObject {
    func didAddChore(chore: Chore)
    func didModifyChore(chore: Chore)
    func didDeleteChore(chore: Chore)
}

protocol  DatabaseManagerUserDelegate: AnyObject {
    func didDeleteUser(user: User)
}

// Optional delegate methods
extension DatabaseManagerUserDelegate {
    func didAddUser(user: User) {}
    func didModifyUser(user: User) {}
}

class DatabaseManager {
    static let shared = DatabaseManager()
    let database = Firestore.firestore()
    weak var choreDelegate: DatabaseManagerChoreDelegate?
    weak var userDelegate: DatabaseManagerUserDelegate?
    var listeners: [ListenerRegistration] = []
    var groupId: String? {
        didSet {
            log.info("groupId changed, new value is \(groupId ?? "nil")")
        }
    }
    var userId: String? {
        didSet {
            log.info("userId changed, new value is \(userId ?? "nil")")
        }
    }

    private init() {}

    deinit {
        listeners.forEach { listener in
            listener.remove()
        }
    }

}
