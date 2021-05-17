//
//  UsersTableViewController.swift
//  Kelo
//
//  Created by Raul Olmedo on 6/5/21.
//

import UIKit
import LetterAvatarKit

protocol UsersTableViewDelegate: AnyObject {
    func didSelectUser(user: User)
}

class UsersTableViewController: UITableViewController {

    // MARK: Properties
    weak var delegate: UsersTableViewDelegate?
    var users: [User]?

    // MARK: View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        DispatchQueue.global(qos: .userInitiated).async {
            DatabaseManager.shared.retrieveAllUsers { (result) in
                switch result {
                case .failure(let err):
                    log.error(err)
                case .success(let users):
                    self.users = users
                    self.tableView.reloadData()
                }
            }
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        sheetViewController?.handleScrollView(tableView)
    }

    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let users = users else {
            log.warning("Cannot get number of rows, users list is nil")
            return 0
        }
        return users.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "userTableViewCell", for: indexPath)

        if let cell = cell as? UserTableViewCell {
            let circleAvatarImage = LetterAvatarMaker()
                .setCircle(true)
                .setUsername(users![indexPath.row].name)
                .setBorderWidth(1.0)
                .useSingleLetter(true)
                .build()

            cell.userImage.image = circleAvatarImage

            let user = users![indexPath.row]

            if user.id == DatabaseManager.shared.userId {
                cell.userNameLabel.text = user.name + " (You)"
            } else {
                cell.userNameLabel.text = user.name
            }

        }

        return cell
    }

    // MARK: Table view delegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let selectedUser = users?[indexPath.row] {
            delegate?.didSelectUser(user: selectedUser)
            dismiss(animated: true, completion: nil)
        } else {
            log.error("Could not return selected user to parent controller")
        }
    }
}
