//
//  Group.swift
//  Kelo
//
//  Created by Raul Olmedo on 26/3/21.
//
// swiftlint:disable identifier_name

import Foundation
import FirebaseFirestoreSwift

struct Group: Identifiable, Codable {
    @DocumentID public var id: String?
    let name: String
    let currency: String

    init(name: String, currency: String) {
        self.name = name
        self.currency = currency
    }

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case currency
    }

}
