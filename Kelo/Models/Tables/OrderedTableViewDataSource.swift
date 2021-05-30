//
//  OrderedTableViewDataSource.swift
//  Kelo
//
//  Created by Raul Olmedo on 29/5/21.
//

import UIKit
import SortedArray

class OrderedTableViewDataSource<Model: Comparable>: NSObject, UITableViewDataSource {
    typealias CellConfigurator = (Model, UITableViewCell) -> Void

    var models: SortedArray<Model>

    private let reuseIdentifier: String
    private let cellConfigurator: CellConfigurator

    init(models: [Model],
         reuseIdentifier: String,
         cellConfigurator: @escaping CellConfigurator) {
        let sortedModels = SortedArray(unsorted: models)
        self.models = sortedModels
        self.reuseIdentifier = reuseIdentifier
        self.cellConfigurator = cellConfigurator
    }

    // MARK: - UITableView data source
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return models.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = models[indexPath.row]
        let cell = tableView.dequeueReusableCell(
            withIdentifier: reuseIdentifier,
            for: indexPath
        )

        cellConfigurator(model, cell)

        return cell
    }
}
