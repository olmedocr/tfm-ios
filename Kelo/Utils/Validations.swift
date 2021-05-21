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
        }
    }
}

struct Validations {
    private static let userNameRegex = NSRegularExpression("^[A-Za-zñÁÉÍÓÚÜáéíóúüç ]{3,32}$")
    private static let groupNameRegex = NSRegularExpression("^[A-Za-z0-9ñÁÉÍÓÚÜáéíóúüç ]{5,32}$")
    private static let groupCodeRegex = NSRegularExpression("^[A-Za-z0-9 ]{20}$")
    private static let choreNameRegex = groupNameRegex

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

    // MARK: - Private
    private static func isValid(input: String, regEx: NSRegularExpression) -> Bool {
        return regEx.matches(input)
    }

    private static func isValid(input: Chore) -> Bool {
        return input.assignee != "" && input.name != ""
    }
}
