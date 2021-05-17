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
    let name: String
    let points: Int

    init(name: String, points: Int = 0) {
        self.name = name
        self.points = points
    }

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case points
    }
}
