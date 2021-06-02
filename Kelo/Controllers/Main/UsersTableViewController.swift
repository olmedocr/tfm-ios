//
//  UsersTableViewController.swift
//  Kelo
//
//  Created by Raul Olmedo on 6/5/21.
//

import UIKit

protocol UsersTableViewDelegate: AnyObject {
    func didSelectUser(user: User)
}

class UsersTableViewController: UITableViewController {

    // MARK: Properties
    weak var delegate: UsersTableViewDelegate?
    var dataSource: TableViewDataSource<User>?

    // MARK: View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        DispatchQueue.global(qos: .userInitiated).async {
            DatabaseManager.shared.retrieveAllUsers { (result) in
                switch result {
                case .failure(let err):
                    log.error(err.localizedDescription)
                case .success(let users):
                    self.dataSource = .make(for: users)
                    self.tableView.dataSource = self.dataSource
                    self.tableView.reloadData()
                }
            }
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        sheetViewController?.handleScrollView(tableView)
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let selectedUser = dataSource?.models[indexPath.row] {
            delegate?.didSelectUser(user: selectedUser)
            dismiss(animated: true, completion: nil)
        } else {
            log.error("Could not return selected user to parent controller")
        }
    }

}
