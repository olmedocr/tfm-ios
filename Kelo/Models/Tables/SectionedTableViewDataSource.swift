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
    private let allowEditInSections: [Int]

    init(dataSources: [UITableViewDataSource], sectionTitles: [String], allowEditInSections: [Int]) {
        self.dataSources = dataSources
        self.sectionTitles = sectionTitles
        self.allowEditInSections = allowEditInSections
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
        if allowEditInSections.firstIndex(of: indexPath.section) != nil {
            return true
        } else {
            return false
        }
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sectionTitles[section]
    }
}
