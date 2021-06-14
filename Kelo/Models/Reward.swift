//
//  Reward.swift
//  Kelo
//
//  Created by Raul Olmedo on 26/3/21.
//
// swiftlint:disable identifier_name

import Foundation
import FirebaseFirestoreSwift

enum Period: Int, Codable, CaseIterable {
    case none
    case weekly
    case biWeekly
    case monthly
    case biMonthly
    case yearly

    var description: String {
        switch self {
        case .none:
            return "No frequency"
        case .weekly:
            return "Every week"
        case .biWeekly:
            return "Every 2 weeks"
        case .monthly:
            return "Every month"
        case .biMonthly:
            return "Every 2 months"
        case .yearly:
            return "Every year"
        }
    }

    var component: DateComponents? {
        var dateComponent = DateComponents()

        switch self {
        case .none:
            dateComponent.day = 0
        case .weekly:
            dateComponent.day = 7
        case .biWeekly:
            dateComponent.day = 14
        case .monthly:
            dateComponent.month = 1
        case .biMonthly:
            dateComponent.month = 2
        case .yearly:
            dateComponent.year = 1
        }
        return dateComponent
    }
}

struct Reward: Identifiable, Codable {
    @DocumentID public var id: String?
    var name: String = ""
    var icon: String = ""
    @ExplicitNull var expiration: Date?
    var creation: Date = Date()
    var frequency: Period = .none

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case icon
        case expiration
        case creation
        case frequency
    }

}
