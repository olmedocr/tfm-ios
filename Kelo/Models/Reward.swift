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
    var name: String = ""
    var frequency: Date = Date()
    var icon: String = ""

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case frequency
        case icon
    }

}
