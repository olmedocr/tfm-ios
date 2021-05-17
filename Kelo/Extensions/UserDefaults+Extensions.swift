//
//  UserDefaults+Extensions.swift
//  Kelo
//
//  Created by Raul Olmedo on 12/5/21.
//

import Foundation

extension UserDefaults {

    enum Keys: String, CaseIterable {

        case hasBeenLaunchedBefore
        case groupId
        case userId

    }

    func reset() {
        Keys.allCases.forEach { removeObject(forKey: $0.rawValue) }
    }

}
