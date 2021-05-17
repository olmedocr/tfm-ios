//
//  Currency.swift
//  Kelo
//
//  Created by Raul Olmedo on 7/4/21.
//

import Foundation
import UIKit

struct Currency: Codable {
    let code: String
    let name: String
    let symbol: String
    var flag: UIImage? {
        UIImage(named: "Currencies.bundle/Flags/\(code.uppercased())", in: .main, compatibleWith: nil)
    }

    init(code: String, name: String, symbol: String) {
        self.code = code
        self.name = name
        self.symbol = symbol
    }

    enum CodingKeys: String, CodingKey {
        case code
        case name
        case symbol
    }
}
