//
//  Constants.swift
//  Kelo
//
//  Created by Raul Olmedo on 26/3/21.
//

import Foundation

struct Constants {
    static let transitionDefaultDuration = 1.0
    static let animationDefaultDuration = 0.3

    static let userNameRegex = NSRegularExpression("^[A-Za-zñÁÉÍÓÚÜáéíóúüç ]{3,32}$")
    static let groupNameRegex = NSRegularExpression("^[A-Za-z0-9ñÁÉÍÓÚÜáéíóúüç ]{5,32}$")
    static let groupCodeRegex = NSRegularExpression("^[A-Za-z0-9 ]{20}$")
    static let choreNameRegex = groupNameRegex

    static let groupsCollectionKey = "groups"
    static let usersCollectionKey = "users"
    static let choresCollectionKey = "chores"

    enum ChoreImportance: Int {
        case low = 10
        case medium = 20
        case high = 30
    }
}
