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
    var currencies: [Currency]?

    // MARK: View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        fetchCurrencies()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        sheetViewController?.handleScrollView(tableView)
    }

    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        currencies?.count ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "currencyTableViewCell", for: indexPath)
                as? CurrencyTableViewCell else {
            fatalError("The registered type for the cell does not match the casting")
        }

        let info = currencies?[indexPath.row]

        cell.currencyName?.text = info?.name
        cell.flagImage?.image = info?.flag

        return cell
    }

    // MARK: Table view delegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let selectedCurrency = currencies?[indexPath.row] {
            delegate?.didSelectCurrency(currency: selectedCurrency)
            dismiss(animated: true, completion: nil)
        } else {
            log.error("Could not return selected currency to parent controller")
        }

    }

    // MARK: - Internal
    private func fetchCurrencies() {
        let path = "Currencies.bundle/Data/CurrencyList"

        guard let jsonPath = Bundle.main.path(forResource: path, ofType: "json"),
              let jsonData = try? Data(contentsOf: URL(fileURLWithPath: jsonPath)) else {

            log.error("No CurrencyList Bundle Access")
            return
        }

        do {
            currencies = try JSONDecoder().decode([Currency].self, from: jsonData)
            log.info("Correctly decoded json with currencies")
        } catch let err {
            log.error(err.localizedDescription)
        }
    }
}
