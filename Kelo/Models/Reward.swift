//
//  Reward.swift
//  Kelo
//
//  Created by Raul Olmedo on 26/3/21.
//
// swiftlint:disable identifier_name

import Foundation
import FirebaseFirestoreSwift

struct Reward: Identifiable, Codable {
    @DocumentID public var id: String?
    let name: String
    let frequency: Date
    let icon: String

    init(name: String, frequency: Date, icon: String) {
        self.name = name
        self.frequency = frequency
        self.icon = icon
    }

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case frequency
        case icon
    }

}
