//
//  TableViewDataSource+Currency.swift
//  Kelo
//
//  Created by Raul Olmedo on 29/5/21.
//

extension TableViewDataSource where Model == Currency {
    static func make(for currencies: [Currency],
                     reuseIdentifier: String = "currencyTableViewCell") -> TableViewDataSource {
        return TableViewDataSource(
            models: currencies,
            reuseIdentifier: reuseIdentifier
        ) { (currency, cell) in
            if let cell = cell as? CurrencyTableViewCell {
                cell.currencyName.text = currency.name
                cell.flagImage.image = currency.flag
            }
        }
    }
}
