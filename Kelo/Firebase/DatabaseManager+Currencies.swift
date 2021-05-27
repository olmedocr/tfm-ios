//
//  DatabaseManager+Currencies.swift
//  Kelo
//
//  Created by Raul Olmedo on 27/5/21.
//

import Foundation

extension DatabaseManager {
    func retrieveCurrencies(result: @escaping (Result<[Currency], Error>) -> Void) {
        let path = "Currencies.bundle/Data/CurrencyList"

        guard let jsonPath = Bundle.main.path(forResource: path, ofType: "json"),
              let jsonData = try? Data(contentsOf: URL(fileURLWithPath: jsonPath)) else {

            log.error(CustomError.bundleError.localizedDescription)
            result(.failure(CustomError.bundleError))
            return
        }

        do {
            let currencies = try JSONDecoder().decode([Currency].self, from: jsonData)
            log.info("Correctly decoded json with currencies")
            result(.success(currencies))
        } catch let err {
            log.error(err.localizedDescription)
            result(.failure(err))
        }
    }
}
