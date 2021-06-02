//
//  User.swift
//  Kelo
//
//  Created by Raul Olmedo on 26/3/21.
//
// swiftlint:disable identifier_name

import Foundation
import FirebaseFirestoreSwift

struct User: Identifiable, Codable {
    @DocumentID public var id: String?
    var name: String = ""
    var points: Int = 0
    var isAdmin: Bool = false

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case points
        case isAdmin
    }

}
