//
//  SectionedTableViewDataSource.swift
//  Kelo
//
//  Created by Raul Olmedo on 26/5/21.
//

import UIKit

class SectionedTableViewDataSource: NSObject {
    private let dataSources: [UITableViewDataSource]
    private let sectionTitles: [String]

    init(dataSources: [UITableViewDataSource], sectionTitles: [String]) {
        self.dataSources = dataSources
        self.sectionTitles = sectionTitles
    }
}

extension SectionedTableViewDataSource: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return dataSources.count
    }

    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        let dataSource = dataSources[section]
        return dataSource.tableView(tableView, numberOfRowsInSection: 0)
    }

    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let dataSource = dataSources[indexPath.section]
        let indexPath = IndexPath(row: indexPath.row, section: 0)
        return dataSource.tableView(tableView, cellForRowAt: indexPath)
    }

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if indexPath.section == 1 {
            return true
        } else {
            return false
        }
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sectionTitles[section]
    }

}
