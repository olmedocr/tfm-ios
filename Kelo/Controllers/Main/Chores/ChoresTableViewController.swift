//
//  ChoresTableViewController.swift
//  Kelo
//
//  Created by Raul Olmedo on 27/4/21.
//

import UIKit
import FittedSheets

class ChoresTableViewController: UITableViewController {

    // MARK: - Properties
    var currentUser: User!
    var dataSource: TableViewDataSource<Chore>?
    var isShowingCompletedChores: Bool = false {
        didSet {
            tableView.allowsSelection = !isShowingCompletedChores
        }
    }
    var isShowingAssignedChores: Bool = false
    var group: Group?

    // MARK: - IBOutlets
    @IBOutlet weak var checkButton: UIBarButtonItem!
    @IBOutlet weak var pinButton: UIBarButtonItem!

    // MARK: - IBActions
    @IBAction func didTapAddButton(_ sender: Any) {
        self.presentDetailChoreViewController()
    }

    @IBAction func didTapCheckButton(_ sender: Any) {
        if isShowingCompletedChores {
            isShowingCompletedChores = false
            checkButton.image = UIImage(systemName: "checkmark.circle")
            navigationItem.title = NSLocalizedString("Chores", comment: "")
        } else {
            isShowingCompletedChores = true
            checkButton.image = UIImage(systemName: "checkmark.circle.fill")
            navigationItem.title = NSLocalizedString("Completed", comment: "")
        }

        fetchData()
    }

    @IBAction func didTapPinButton(_ sender: Any) {
        if isShowingAssignedChores {
            isShowingAssignedChores = false
            pinButton.image = UIImage(systemName: "pin.circle")
        } else {
            isShowingAssignedChores = true
            pinButton.image = UIImage(systemName: "pin.circle.fill")
        }

        fetchData()
    }

    // MARK: - View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.tableFooterView = UIView()

        refreshControl = UIRefreshControl()
        refreshControl?.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl?.addTarget(self, action: #selector(fetchData), for: .valueChanged)

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(fetchData),
                                               name: UIApplication.willEnterForegroundNotification,
                                               object: nil)

        fetchData()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        fetchData()
    }

    // MARK: - Table view delegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        switch Validations.chorePermission((dataSource?.models[indexPath.row])!,
                                           user: currentUser,
                                           operation: .update) {

        case .failure(let err):
            log.error(err.localizedDescription)
            log.info("Tried to edit a chore without being the creator")

            let alert = self.setAlert(title: NSLocalizedString("Error!", comment: ""),
                                      message:
                                        NSLocalizedString("""
                                        Only the creator of the chore and the group admin are able to
                                        edit this element
                                        """, comment: ""),
                                      actionTitle: "OK")

            self.present(alert, animated: true)

        case .success:
            self.presentDetailChoreViewController(dataSource?.models[indexPath.row])
        }

        tableView.deselectRow(at: indexPath, animated: true)
    }

    override func tableView(_ tableView: UITableView,
                            leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath)
    -> UISwipeActionsConfiguration? {

        let configuration: UISwipeActionsConfiguration!
        let completeAction = UIContextualAction(style: .normal,
                                                title: "Complete") { [weak self] (_, _, completionHandler) in
            self?.handleMarkAsComplete(chore: (self?.dataSource?.models[indexPath.row])!,
                                       index: indexPath.row,
                                       onComplete: completionHandler)
        }
        completeAction.backgroundColor = UIColor(named: "AccentColor")
        completeAction.image = UIImage(systemName: "checkmark.circle.fill")

        if isShowingCompletedChores {
            configuration = UISwipeActionsConfiguration(actions: [])
        } else {
            configuration = UISwipeActionsConfiguration(actions: [completeAction])
        }

        return configuration
    }

    override func tableView(_ tableView: UITableView,
                            trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath)
    -> UISwipeActionsConfiguration? {

        let configuration: UISwipeActionsConfiguration!
        let deleteAction = UIContextualAction(style: .destructive,
                                                title: "Delete") { [weak self] (_, _, completionHandler) in
            self?.handleMarkAsDelete(chore: (self?.dataSource?.models[indexPath.row])!,
                                     index: indexPath.row,
                                     onComplete: completionHandler)
        }
        deleteAction.backgroundColor = UIColor.systemRed
        deleteAction.image = UIImage(systemName: "trash.circle.fill")

        if isShowingCompletedChores {
            configuration = UISwipeActionsConfiguration(actions: [])
        } else {
            configuration = UISwipeActionsConfiguration(actions: [deleteAction])
        }

        return configuration
    }

    // MARK: - Internal
    @objc func fetchData() {
        DatabaseManager.shared.retrieveAllChores(isCompleted: isShowingCompletedChores,
                                                 isAssigned: isShowingAssignedChores) { choresResult in
            switch choresResult {
            case .failure(let err):
                log.error(err.localizedDescription)
            case .success(let chores):
                self.dataSource = TableViewDataSource.make(for: chores)
                self.tableView.dataSource = self.dataSource
                self.tableView.reloadData()
                self.refreshControl?.endRefreshing()

                DatabaseManager.shared.retrieveUser(userId: DatabaseManager.shared.userId!) { (userResult) in
                    switch userResult {
                    case .failure(let err):
                        log.error(err.localizedDescription)
                    case .success(let user):
                        self.currentUser = user

                        DatabaseManager.shared
                            .retrieveGroup(groupId: DatabaseManager.shared.groupId!) { (groupResult) in
                                switch groupResult {
                                case .failure(let err):
                                    log.error(err.localizedDescription)
                                case .success(let group):
                                    self.group = group
                                    self.navigationItem.addSubtitle(group.name)
                                }
                            }
                    }
                }
            }
        }
    }

    private func handleMarkAsComplete(chore: Chore, index: Int, onComplete completion: @escaping (Bool) -> Void) {

        switch Validations.chorePermission(chore, user: currentUser, operation: .complete) {
        case .failure(let err):
            log.error(err.localizedDescription)
            log.info("Tried to complete the chore without being the assigned user or the creator")

            let alert = self.setAlert(title: NSLocalizedString("Error!", comment: ""),
                                      message: NSLocalizedString("""
                                            Only the group admin, the creator of the chore or the user assigned to it
                                            can complete this element
                                            """, comment: ""),
                                      actionTitle: "OK")

            self.present(alert, animated: true)

        case .success:
            DatabaseManager.shared.completeChore(chore: chore) { (result) in
                switch result {
                case .failure(let err):
                    log.error(err.localizedDescription)
                    completion(false)
                case .success:
                    log.info("Correctly completed chore with id \(chore.id ?? "null")")
                    self.dataSource?.models.remove(at: index)
                    self.tableView.reloadData()
                    completion(true)
                }
            }
        }
    }

    private func handleMarkAsDelete(chore: Chore, index: Int, onComplete completion: @escaping (Bool) -> Void) {
        switch Validations.chorePermission(chore, user: currentUser, operation: .remove) {
        case .failure(let err):
            log.error(err.localizedDescription)
            log.info("Tried to remove the chore without being the creator")

            let alert = self.setAlert(title: NSLocalizedString("Error!", comment: ""),
                                      message: NSLocalizedString("""
                                            Only the creator of the chore or the group admin are able to
                                            remove this element
                                            """, comment: ""),
                                      actionTitle: "OK")

            self.present(alert, animated: true)

        case .success:
            DatabaseManager.shared.deleteChore(choreId: chore.id!) { (result) in
                switch result {
                case .failure(let err):
                    log.error(err.localizedDescription)
                    completion(false)
                case .success:
                    log.info("Correctly deleted chore with id \(chore.id ?? "null")")
                    self.dataSource?.models.remove(at: index)
                    self.tableView.reloadData()
                    completion(true)
                }
            }
        }
    }

    // MARK: - Navigation
    private func presentDetailChoreViewController(_ chore: Chore? = nil) {
        if let viewController = UIStoryboard(name: "Main", bundle: nil)
            .instantiateViewController(withIdentifier: "DetailChoreViewController") as? DetailChoreViewController {

            viewController.chore = chore
            viewController.modalPresentationStyle = .fullScreen
            viewController.hidesBottomBarWhenPushed = true

            if chore != nil {
                viewController.title = NSLocalizedString("Edit Chore", comment: "")
            } else {
                viewController.title = NSLocalizedString("New Chore", comment: "")
            }

            navigationController?.pushViewController(viewController, animated: true)
        }
    }

}
