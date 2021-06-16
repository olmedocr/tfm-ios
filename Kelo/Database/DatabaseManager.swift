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
        case rewardNotFound
        case unknown

        var errorDescription: String? {
            switch self {
            case .groupNotFound:
                return NSLocalizedString("Group not found", comment: "")
            case .userNotFound:
                return NSLocalizedString("User not found", comment: "")
            case .userNameAlreadyTaken:
                return NSLocalizedString("Username already taken", comment: "")
            case .groupIsFull:
                return NSLocalizedString("Group is full", comment: "")
            case .bundleError:
                return NSLocalizedString("No CurrencyList Bundle Access", comment: "")
            case .rewardNotFound:
                return NSLocalizedString("No Reward could be retrieved", comment: "")
            case .unknown:
                return NSLocalizedString("Uknown error", comment: "")
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
