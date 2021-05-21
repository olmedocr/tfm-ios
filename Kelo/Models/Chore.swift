//
//  File.swift
//  Kelo
//
//  Created by Raul Olmedo on 26/3/21.
//
// swiftlint:disable identifier_name

import Foundation
import FirebaseFirestoreSwift

struct Chore: Identifiable, Codable {
    @DocumentID public var id: String?
    var name: String = ""
    var icon: String = ""
    var assignee: String = ""
    var expiration: Date = Date()
    var points: Int = Importance.low.rawValue

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case icon
        case assignee
        case expiration
        case points
    }

    enum Importance: Int {
        case low = 10
        case medium = 20
        case high = 30
    }
}
