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
    let name: String
    let icon: String
    let assignee: String
    let expiration: Date
    let points: Int

    init(name: String, icon: String, assignee: String, expiration: Date, points: Int) {
        self.name = name
        self.icon = icon
        self.assignee = assignee
        self.expiration = expiration
        self.points = points
    }

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case icon
        case assignee
        case expiration
        case points
    }
}
