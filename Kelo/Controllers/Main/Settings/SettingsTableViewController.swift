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
    let sectionTitles = ["Your points", "Roommates", "Rewards", "Currency", "Danger zone"]
    var dataSources: SectionedTableViewDataSource?
    var group: Group?
    var user: User?
    var users: [User]?

    // MARK: @IBActions
    @IBAction func didTapShareButton(_ sender: Any) {
        self.presentShareGroupCodeViewController()
    }

    // MARK: View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        // TODO: Allow only edition if admin (?) 
        navigationItem.rightBarButtonItem = self.editButtonItem

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
            self.presentCurrencyTableViewController()
        }

        tableView.deselectRow(at: indexPath, animated: true)
    }

    override func tableView(_ tableView: UITableView,
                            editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {

        if users?[indexPath.row].id == user?.id {
            return .none
        } else {
            return .delete
        }
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        let index = users?.firstIndex { $0.id == user?.id }

        if indexPath.row == index {
            return true
        } else {
            return false
        }
    }

    // MARK: - Internal
    @objc private func fetchData() {
        DatabaseManager.shared.retrieveGroup(groupId: DatabaseManager.shared.groupId!) { (fetchedGroup) in
            switch fetchedGroup {
            case .failure(let err):
                log.error(err.localizedDescription)
            case .success(let group):
                self.group = group
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
                                self.user = users.filter { $0.id == DatabaseManager.shared.userId }.first

                                self.updateDataSource(withUser: self.user!,
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
                    reuseIdentifier: "settingsTableViewCell"
                ) { _, cell in
                    if let cell = cell as? SettingsTableViewCell {
                        cell.delegate = self
                    }
                }],
            sectionTitles: self.sectionTitles)

        self.tableView.dataSource = self.dataSources
        self.tableView.reloadData()
        self.refreshControl?.endRefreshing()
    }

    // MARK: - Navigation
    private func presentShareGroupCodeViewController() {
        guard let controller = UIStoryboard(name: "Main", bundle: nil)
                .instantiateViewController(withIdentifier: "ShareGroupCodeViewController")
                as? ShareGroupCodeViewController
        else {
            log.error("Could not instantiate ShareGroupCodeViewController")
            return
        }

        let options = SheetOptions(shrinkPresentingViewController: false)
        let sheetController = SheetViewController(
            controller: controller,
            sizes: [.percent(0.25)],
            options: options)

        navigationController?.present(sheetController, animated: true, completion: nil)
    }

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

extension SettingsTableViewController: SettingsCellDelegate {
    func didTapOnDeleteGroup() {
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
                    self.restartApp()
                }
            }
        }

        alert.addAction(action)

        self.present(alert, animated: true)
    }

    func didTapOnLeaveGroup() {
        let alert = self.setAlert(title: "Are you sure?",
                                  message: "You will loose all access to this group",
                                  actionTitle: "Cancel")

        let action = UIAlertAction(title: "Leave",
                                   style: .destructive) { _ in
            DatabaseManager.shared.deleteUser(userId: DatabaseManager.shared.userId!) { (result) in
                switch result {
                case .failure(let err):
                    log.error(err.localizedDescription)
                case .success:
                    log.info("Leaving group")
                    self.restartApp()
                }
            }
        }

        alert.addAction(action)

        self.present(alert, animated: true)
    }
}
