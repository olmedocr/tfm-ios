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
            case .bundleError:
                return "No CurrencyList Bundle Access"
            case .unknown:
                return "Uknown error"
            }
        }
    }
}

protocol  DatabaseManagerDelegate: AnyObject {
    func didDeleteUser(user: User)

}

// Optional delegate methods
extension DatabaseManagerDelegate {

    func didAddUser(user: User) {}

    func didModifyUser(user: User) {}

}

class DatabaseManager {
    static let shared = DatabaseManager()
    let database = Firestore.firestore()
    weak var delegate: DatabaseManagerDelegate?
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
        removeAllListeners()
    }

    func removeAllListeners() {
        listeners.forEach { listener in
            listener.remove()
        }
    }

}
