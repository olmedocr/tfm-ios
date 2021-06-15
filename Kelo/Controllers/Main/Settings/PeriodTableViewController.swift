//
//  PeriodTableViewController.swift
//  Kelo
//
//  Created by Raul Olmedo on 9/6/21.
//

import UIKit

protocol PeriodTableViewDelegate: AnyObject {
    func didSelectPeriod(period: Period)
}

class PeriodTableViewController: UITableViewController {

    // MARK: - Properties
    weak var delegate: PeriodTableViewDelegate?
    var dataSource: TableViewDataSource<Period>?

    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        dataSource = .make(for: Period.allCases)
        tableView.dataSource = dataSource
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        sheetViewController?.handleScrollView(tableView)
    }

    // MARK: - Table view delegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let selectedPeriod = dataSource?.models[indexPath.row] {
            delegate?.didSelectPeriod(period: selectedPeriod)
            dismiss(animated: true, completion: nil)
        } else {
            log.error("Could not return selected period to parent controller")
        }
    }

}
