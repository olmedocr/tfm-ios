//
//  CurrencyTableViewController.swift
//  Kelo
//
//  Created by Raul Olmedo on 7/4/21.
//

import UIKit

protocol CurrencyTableViewDelegate: AnyObject {
    func didSelectCurrency(currency: Currency)
}

class CurrencyTableViewController: UITableViewController {

    // MARK: Properties
    weak var delegate: CurrencyTableViewDelegate?
    var dataSource: TableViewDataSource<Currency>?

    // MARK: View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        DatabaseManager.shared.retrieveCurrencies { (result) in
            switch result {
            case .failure(let err):
                log.error(err)
            case .success(let currencies):
                log.info("Correctly fetched currencies")
                self.dataSource = .make(for: currencies)
                self.tableView.dataSource = self.dataSource
            }
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        sheetViewController?.handleScrollView(tableView)
    }

    // MARK: Table view delegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let selectedCurrency = dataSource?.models[indexPath.row] {
            delegate?.didSelectCurrency(currency: selectedCurrency)
            dismiss(animated: true, completion: nil)
        } else {
            log.error("Could not return selected currency to parent controller")
        }
    }
}
