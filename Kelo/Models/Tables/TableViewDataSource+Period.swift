//
//  TableViewDataSource+Period.swift
//  Kelo
//
//  Created by Raul Olmedo on 9/6/21.
//

extension TableViewDataSource where Model == Period {

    static func make(for periods: [Period],
                     reuseIdentifier: String = "periodTableViewCell") -> TableViewDataSource {
        return TableViewDataSource(
            models: periods,
            reuseIdentifier: reuseIdentifier
        ) { (period, cell) in
            if let cell = cell as? PeriodTableViewCell {
                cell.periodName.text = period.description
            }
        }
    }

}
