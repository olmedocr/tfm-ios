//
//  SettingsTableViewController.swift
//  Kelo
//
//  Created by Raul Olmedo on 27/4/21.
//

import UIKit
import FittedSheets

class SettingsTableViewController: UITableViewController {

    // MARK: Properties
    let sectionTitles = ["Your points", "Roommates", "Rewards", "Currency", "Miscellaneous", "Danger zone"]
    var dataSources: SectionedTableViewDataSource?
    var users: [User]?
    var group: Group?
    var currentUser: User?

    // MARK: @IBActions
    @IBAction func didTapShareButton(_ sender: Any) {
        if let tabBarController = tabBarController as? MainTabViewController {
            tabBarController.presentShareGroupCodeViewController(context: self)
        }
    }

    // MARK: View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        refreshControl = UIRefreshControl()
        refreshControl?.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl?.addTarget(self, action: #selector(fetchData), for: .valueChanged)

        fetchData()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        fetchData()
    }

    // MARK: - TableView delegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 2 {
            self.presentRewardViewController()
        } else if indexPath.section == 3 {
            if let user = currentUser, user.isAdmin {
                self.presentCurrencyTableViewController()
            } else {
                log.info("Tried to edit the currency without being the group admin")

                tableView.deselectRow(at: indexPath, animated: true)

                let alert = self.setAlert(title: "Error!",
                                          message: """
                                        Only the group admin is able to edit the currency
                                        """,
                                          actionTitle: "OK")

                self.present(alert, animated: true)
            }
        }

        tableView.deselectRow(at: indexPath, animated: true)
    }

    override func tableView(_ tableView: UITableView,
                            trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath)
    -> UISwipeActionsConfiguration? {

        let index = users?.firstIndex { $0.id == currentUser?.id }

        if indexPath.row == index {
            return nil
        } else {
            let deleteAction = UIContextualAction(style: .destructive,
                                                  title: "Delete") { [weak self] (_, _, completionHandler) in

                self?.handleMarkAsDelete(user: (self?.users?[indexPath.row])!,
                                         index: indexPath.row,
                                         onComplete: completionHandler)

            }
            deleteAction.backgroundColor = UIColor.systemRed
            deleteAction.image = UIImage(systemName: "trash.fill")

            let configuration = UISwipeActionsConfiguration(actions: [deleteAction])
            return configuration
        }
    }

    // MARK: - Internal
    @objc private func fetchData() {
        // TODO: update each section asynchronously
        DatabaseManager.shared.retrieveGroup(groupId: DatabaseManager.shared.groupId!) { (fetchedGroup) in
            switch fetchedGroup {
            case .failure(let err):
                log.error(err.localizedDescription)
            case .success(let group):
                self.group = group

                self.tabBarController?.children.forEach { navController in
                    navController.children.first?.navigationItem.prompt = group.name
                }

                DatabaseManager.shared.retrieveCurrencies { (currencyResult) in
                    switch currencyResult {
                    case .failure(let err):
                        log.error(err.localizedDescription)
                    case .success(let currencies):
                        let currency = currencies.filter { $0.code == group.currency }.first
                        let reward = Reward()
                        // TODO: fetch reward
                        DatabaseManager.shared.retrieveAllUsers { (fetchedUsers) in
                            switch fetchedUsers {
                            case .failure(let err):
                                log.error(err.localizedDescription)
                            case .success(let users):
                                self.users = users
                                self.currentUser = users.filter { $0.id == DatabaseManager.shared.userId }.first

                                self.updateDataSource(withUser: self.currentUser!,
                                                      withUsers: users,
                                                      withCurrency: currency!,
                                                      withReward: reward)
                            }
                        }
                    }
                }
            }
        }
    }

    private func updateDataSource(withUser user: User,
                                  withUsers users: [User],
                                  withCurrency currency: Currency,
                                  withReward reward: Reward) {

        self.dataSources = SectionedTableViewDataSource(
            dataSources: [
                TableViewDataSource(
                    models: [user],
                    reuseIdentifier: "pointsTableViewCell"
                ) { user, cell in
                    if let cell = cell as? PointsTableViewCell {
                        cell.pointsLabel.text = String(user.points)
                    }
                },
                TableViewDataSource.make(for: users),
                TableViewDataSource.make(for: reward),
                TableViewDataSource(
                    models: [currency],
                    reuseIdentifier: "currencyTableViewCell"
                ) { currency, cell in
                    if let cell = cell as? CurrencyTableViewCell {
                        cell.currencyName.text = currency.name
                        cell.flagImage.image = currency.flag
                    }
                },
                TableViewDataSource(
                    models: [(user)],
                    reuseIdentifier: "editSettingsTableViewCell"
                ) { _, cell in
                    if let cell = cell as? EditSettingsTableViewCell {
                        cell.delegate = self
                    }
                },
                TableViewDataSource(
                    models: [(user)],
                    reuseIdentifier: "dangerSettingsTableViewCell"
                ) { _, cell in
                    if let cell = cell as? DangerSettingsTableViewCell {
                        cell.delegate = self
                    }
                }],
            sectionTitles: self.sectionTitles,
            allowEditInSections: [1])

        self.tableView.dataSource = self.dataSources
        self.tableView.reloadData()
        self.refreshControl?.endRefreshing()
    }

    private func handleMarkAsDelete(user: User, index: Int, onComplete completion: @escaping (Bool) -> Void) {
        switch Validations.userPermission(user, currrentUser: currentUser!, operation: .remove) {
        case .failure(let err):
            log.error(err.localizedDescription)
            log.info("Tried to remove a user without being the admin")

            let alert = self.setAlert(title: "Error!",
                                      message: """
                                        Only the group admin is able to
                                        remove this element
                                        """,
                                      actionTitle: "OK")

            self.present(alert, animated: true)

        case .success:
            DatabaseManager.shared.deleteUser(userId: user.id!) { (result) in
                switch result {
                case .failure(let err):
                    log.error(err.localizedDescription)

                    let alert = self.setAlert(title: "Error!",
                                              message: err.localizedDescription,
                                              actionTitle: "OK")

                    self.present(alert, animated: true)
                case .success:
                    log.info("Deleted user from group")
                    self.fetchData()
                    completion(true)
                }
            }
        }
    }

    // MARK: - Navigation
    private func presentCurrencyTableViewController() {
        guard let controller = UIStoryboard(name: "Main", bundle: nil)
                .instantiateViewController(withIdentifier: "CurrencyTableViewController")
                as? CurrencyTableViewController
        else {
            log.error("Could not instantiate CurrencyTableViewController")
            return
        }

        controller.delegate = self

        let options = SheetOptions(shrinkPresentingViewController: false)
        let sheetController = SheetViewController(
            controller: controller,
            sizes: [.percent(0.35), .fullscreen],
            options: options)

        navigationController?.present(sheetController, animated: true, completion: nil)
    }

    private func presentRewardViewController() {
        guard let controller = UIStoryboard(name: "Main", bundle: nil)
                .instantiateViewController(withIdentifier: "RewardViewController")
                as? RewardViewController
        else {
            log.error("Could not instantiate RewardViewController")
            return
        }

        navigationController?.pushViewController(controller, animated: true)
    }

}

// MARK: - CurrencyTable delegate
extension SettingsTableViewController: CurrencyTableViewDelegate {

    func didSelectCurrency(currency: Currency) {
        if var updatedGroup = group {
            updatedGroup.currency = currency.code
            DatabaseManager.shared.updateGroup(group: updatedGroup) { (result) in
                switch result {
                case .failure(let err):
                    log.error(err.localizedDescription)
                case .success:
                    log.info("Updated currency in group")
                    self.fetchData()
                }
            }
        }
    }

}

// MARK: - Danger settings delegate
extension SettingsTableViewController: DangerSettingsCellDelegate {

    func didTapOnDeleteGroup() {
        if currentUser!.isAdmin {
            DatabaseManager.shared.removeAllListeners()

            let alert = self.setAlert(title: "Are you sure?",
                                      message: "This action will erase every data in the group",
                                      actionTitle: "Cancel")

            let action = UIAlertAction(title: "Delete",
                                       style: .destructive) { _ in
                DatabaseManager.shared.deleteGroup(groupId: DatabaseManager.shared.groupId!) { (result) in
                    switch result {
                    case .failure(let err):
                        log.error(err.localizedDescription)
                    case .success:
                        log.info("Deleted group from db")
                        self.restartApp(withMessage: "The group has been successfully deleted")
                    }
                }
            }

            alert.addAction(action)

            self.present(alert, animated: true)
        } else {
            let alert = self.setAlert(title: "Attention!",
                                      message: """
                                        Only the admin of the group can delete it
                                        """,
                                      actionTitle: "OK")

            self.present(alert, animated: true)
        }

    }

    func didTapOnLeaveGroup() {
        let alert = self.setAlert(title: "Are you sure?",
                                  message: "You will loose all access to this group",
                                  actionTitle: "Cancel")

        let action = UIAlertAction(title: "Leave",
                                   style: .destructive) { _ in
            DatabaseManager.shared.removeAllListeners()
            DatabaseManager.shared.deleteUser(userId: DatabaseManager.shared.userId!) { (result) in
                switch result {
                case .failure(let err):
                    log.error(err.localizedDescription)
                case .success:
                    log.info("Leaving group")
                    DatabaseManager.shared.setAdminRandomly { adminResult in
                        switch adminResult {
                        case .failure(let err):
                            log.error(err.localizedDescription)
                        case .success:
                            log.info("Assigned random admin correctly")
                            self.restartApp(withMessage: "You left the group successfully")
                        }
                    }
                }
            }
        }

        alert.addAction(action)

        self.present(alert, animated: true)
    }

}

// MARK: - Misc settings delegate
extension SettingsTableViewController: EditSettingsCellDelegate {

    func didTapOnEditUser() {
        let alert = UIAlertController(title: "User name",
                                      message: "Change your username in the group",
                                      preferredStyle: .alert)

        alert.addTextField { (textField) in
            textField.placeholder = self.currentUser?.name
        }

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Save", style: .default, handler: { (_) in
            let newUsername = alert.textFields![0].text
            var updatedUser = self.currentUser

            switch Validations.userName(newUsername!) {
            case .failure(let err):
                log.error(err.localizedDescription)
                let alert = self.setAlert(title: "Error!",
                                          message: err.localizedDescription,
                                          actionTitle: "OK")

                self.present(alert, animated: true)
            case .success():
                updatedUser?.name = newUsername!

                DatabaseManager.shared.updateUser(user: updatedUser!) { result in
                    switch result {
                    case .failure(let err):
                        log.error(err.localizedDescription)
                        let alert = self.setAlert(title: "Error!",
                                                  message: err.localizedDescription,
                                                  actionTitle: "OK")

                        self.present(alert, animated: true)
                    case .success:
                        log.info("Successfully updated user name")

                        let alert = self.setAlert(title: "Done!",
                                                  message: """
                                                    Successfully updated user name
                                                    """,
                                                  actionTitle: "OK")

                        self.present(alert, animated: true)

                        self.fetchData()
                    }
                }
            }
        }))

        self.present(alert, animated: true)
    }

    func didTapOnEditGroup() {
        let alert = UIAlertController(title: "Group name",
                                      message: "Change the name of the group",
                                      preferredStyle: .alert)

        alert.addTextField { (textField) in
            textField.placeholder = self.group?.name
        }

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Save", style: .default, handler: { (_) in
            let newGroupname = alert.textFields![0].text
            var updatedGroup = self.group

            switch Validations.groupName(newGroupname!) {
            case .failure(let err):
                log.error(err.localizedDescription)
                let alert = self.setAlert(title: "Error!",
                                          message: err.localizedDescription,
                                          actionTitle: "OK")

                self.present(alert, animated: true)
            case .success():
                updatedGroup?.name = newGroupname!

                DatabaseManager.shared.updateGroup(group: updatedGroup!) { result in
                    switch result {
                    case .failure(let err):
                        log.error(err.localizedDescription)
                        let alert = self.setAlert(title: "Error!",
                                                  message: err.localizedDescription,
                                                  actionTitle: "OK")

                        self.present(alert, animated: true)
                    case .success:
                        log.info("Successfully updated group name")

                        let alert = self.setAlert(title: "Done!",
                                                  message: """
                                                    Successfully updated group name
                                                    """,
                                                  actionTitle: "OK")

                        self.present(alert, animated: true)

                        self.fetchData()
                    }
                }
            }
        }))

        self.present(alert, animated: true)
    }

}
