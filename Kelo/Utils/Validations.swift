//
//  Validations.swift
//  Kelo
//
//  Created by Raul Olmedo on 20/5/21.
//

import Foundation
import UIKit

enum EvaluateError: LocalizedError {
    case isNotValidGroupName
    case isNotValidGroupCode

    case isNotValidUserName

    case isNotValidChore
    case isNotValidChoreName

    case noPermissions

    case groupNoLongerExists
    case userNoLongerExists

    var errorDescription: String? {
        switch self {
        case .isNotValidGroupName:
            return "Invalid name"
        case .isNotValidGroupCode:
            return "Invalid code"
        case .isNotValidUserName:
            return "Invalid name"
        case .isNotValidChore:
            return "Invalid chore"
        case .isNotValidChoreName:
            return "Invalid name"
        case .noPermissions:
            return "Not enough permission"
        case .groupNoLongerExists:
            return "It appears that this group no longer exists"
        case .userNoLongerExists:
            return "You no longer have access to the group"
        }
    }
}

enum ChoreOperation {
    case update
    case complete
    case remove
}

enum UserOperation {
//    case update
//    case complete
    case remove
}

struct Validations {
    private static let userNameRegex = NSRegularExpression("^[A-Za-zñÁÉÍÓÚÜáéíóúüç ]{3,32}$")
    private static let groupNameRegex = NSRegularExpression("^[A-Za-z0-9ñÁÉÍÓÚÜáéíóúüç ]{5,32}$")
    private static let groupCodeRegex = NSRegularExpression("^[A-Za-z0-9 ]{20}$")
    private static let choreNameRegex = groupNameRegex

    static func userInGroup(_ userId: String, groupId: String, result: @escaping (Result<Void, Error>) -> Void) {
        isValid(groupId: groupId) { isValidGroup in
            switch isValidGroup {
            case .failure(_):
                result(.failure(EvaluateError.groupNoLongerExists))
            case .success:
                isValid(userId: userId) { isValidUser in
                    switch isValidUser {
                    case .failure(_):
                        result(.failure(EvaluateError.userNoLongerExists))
                    case .success:
                        result(.success(()))
                    }
                }
            }
        }
    }

    static func groupName(_ name: String) -> Result<Void, Error> {
        if !isValid(input: name, regEx: groupNameRegex) {
            return .failure(EvaluateError.isNotValidGroupName)
        } else {
            return .success(())
        }
    }

    static func groupCode(_ code: String) -> Result<Void, Error> {
        if !isValid(input: code, regEx: groupNameRegex) {
            return .failure(EvaluateError.isNotValidGroupCode)
        } else {
            return .success(())
        }
    }

    static func userName(_ name: String) -> Result<Void, Error> {
        if !isValid(input: name, regEx: userNameRegex) {
            return .failure(EvaluateError.isNotValidUserName)
        } else {
            return .success(())
        }
    }

    static func userPermission(_ user: User, currrentUser: User, operation: UserOperation) -> Result<Void, Error> {
        if !isValid(input: user, currentUser: currrentUser, operation: operation) {
            return .failure(EvaluateError.noPermissions)
        } else {
            return .success(())
        }
    }

    static func choreName(_ name: String) -> Result<Void, Error> {
        if !isValid(input: name, regEx: choreNameRegex) {
            return .failure(EvaluateError.isNotValidChoreName)
        } else {
            return .success(())
        }
    }

    static func chore(_ chore: Chore) -> Result<Void, Error> {
        if !isValid(input: chore) {
            return .failure(EvaluateError.isNotValidChore)
        } else {
            return .success(())
        }
    }

    static func chorePermission(_ chore: Chore, user: User, operation: ChoreOperation) -> Result<Void, Error> {
        if !isValid(input: chore, user: user, operation: operation) {
            return .failure(EvaluateError.noPermissions)
        } else {
            return .success(())
        }
    }

    // MARK: - Private
    private static func isValid(groupId: String, result: @escaping (Result<Void, Error>) -> Void) {

        DatabaseManager.shared.retrieveGroup(groupId: groupId) { (retrieveResult) in
            switch retrieveResult {
            case .failure(let err):
                log.error(err.localizedDescription)
                result(.failure(err))

            case .success:
                result(.success(()))
            }
        }
    }

    private static func isValid(userId: String, result: @escaping (Result<Void, Error>) -> Void) {

        DatabaseManager.shared.retrieveUser(userId: userId) { (retrieveResult) in
            switch retrieveResult {
            case .failure(let err):
                log.error(err.localizedDescription)
                result(.failure(err))

            case .success:
                result(.success(()))
            }
        }
    }

    private static func isValid(input: String, regEx: NSRegularExpression) -> Bool {
        return regEx.matches(input)
    }

    private static func isValid(input: Chore) -> Bool {
        return input.assignee != "" && input.name != ""
    }

    private static func isValid(input: Chore, user: User, operation: ChoreOperation) -> Bool {
        switch operation {
        case .complete:
            return input.assignee == user.id || input.creator == user.id || user.isAdmin
        case .remove:
            return input.creator == user.id || user.isAdmin
        case .update:
            return input.creator == user.id || user.isAdmin
        }
    }

    private static func isValid(input: User, currentUser: User, operation: UserOperation) -> Bool {
        switch operation {
        case .remove:
            return currentUser.isAdmin
        }
    }

}
