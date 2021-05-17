//
//  SettingsTableViewController.swift
//  Kelo
//
//  Created by Raul Olmedo on 27/4/21.
//

import UIKit

class SettingsTableViewController: UITableViewController {

    // MARK: Properties
    let sections = ["Your points", "Roommates", "Rewards", "Currency", "Danger zone"]

    // MARK: View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        // TODO: Allow only edition if admin (?) 
        navigationItem.rightBarButtonItem = self.editButtonItem
    }

    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 0
    }
}
