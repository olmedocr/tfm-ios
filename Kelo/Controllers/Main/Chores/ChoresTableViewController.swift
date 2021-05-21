//
//  ChoresTableViewController.swift
//  Kelo
//
//  Created by Raul Olmedo on 27/4/21.
//

import UIKit
import FittedSheets

class ChoresTableViewController: UITableViewController {

    // MARK: Properties
    var chores: [Chore] = []

    // MARK: View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.tableFooterView = UIView()

        DatabaseManager.shared.subscribeToChoreList { (result) in
            switch result {
            case .failure(let err):
                log.error(err.localizedDescription)
            case .success:
                break
            }
        }

        DatabaseManager.shared.delegate = self
    }

    // MARK: IBActions
    @IBAction func didTapAddButton(_ sender: Any) {
        self.presentDetailChoreViewController()
    }

    @IBAction func didTapShareButton(_ sender: Any) {
        self.presentShareGroupCodeViewController()
    }

    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chores.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "choreTableViewCell", for: indexPath)

        if let cell = cell as? ChoreTableViewCell {
            // For UI testing purposes
            cell.choreTitle.accessibilityIdentifier = chores[indexPath.row].name

            cell.choreTitle.text = chores[indexPath.row].name
            cell.choreTitle.type = .continuous
            cell.choreTitle.speed = .duration(8)
            cell.choreTitle.animationCurve = .easeInOut
            cell.choreTitle.fadeLength = 5.0
            cell.choreTitle.trailingBuffer = 14.0

            DispatchQueue.global(qos: .userInitiated).async {
                DatabaseManager.shared.retrieveUser(userId: self.chores[indexPath.row].assignee) { (result) in
                    switch result {
                    case .failure(let err):
                        log.error(err.localizedDescription)
                    case .success(let user):
                        if user.id == DatabaseManager.shared.userId {
                            cell.assigneeName.text = user.name + " (You)"
                            cell.assigneeName.accessibilityIdentifier = user.name + " (You)"
                        } else {
                            cell.assigneeName.text = user.name
                            cell.assigneeName.accessibilityIdentifier = user.name
                        }
                    }
                }
            }

            let formatter = DateFormatter()
            formatter.timeStyle = .none
            formatter.dateStyle = .short
            formatter.timeZone = TimeZone.current

            cell.dueDate.text = formatter.string(from: chores[indexPath.row].expiration)
            cell.dueDate.accessibilityIdentifier = formatter.string(from: chores[indexPath.row].expiration)

            cell.layoutSubviews()

            switch chores[indexPath.row].points {
            case Chore.Importance.low.rawValue:
                cell.importanceIndicator.image = UIImage(color: .systemGreen)
                cell.importanceIndicator.accessibilityIdentifier = "Green"
            case Chore.Importance.medium.rawValue:
                cell.importanceIndicator.image = UIImage(color: .systemYellow)
                cell.importanceIndicator.accessibilityIdentifier = "Yellow"
            case Chore.Importance.high.rawValue:
                cell.importanceIndicator.image = UIImage(color: .systemRed)
                cell.importanceIndicator.accessibilityIdentifier = "Red"
            default:
                log.warning("Unknown importance value")
            }
        }

        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.presentDetailChoreViewController(chores[indexPath.row])
    }

    // MARK: Table view delegate
    override func tableView(_ tableView: UITableView,
                            leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath)
    -> UISwipeActionsConfiguration? {

        let completeAction = UIContextualAction(style: .normal,
                                                title: "Complete") { [weak self] (_, _, completionHandler) in
            self?.handleMarkAsComplete(chore: (self?.chores[indexPath.row])!, onComplete: completionHandler)
        }
        completeAction.backgroundColor = UIColor.systemBlue
        completeAction.image = UIImage(named: "checkmark.circle.fill")

        let configuration = UISwipeActionsConfiguration(actions: [completeAction])
        return configuration
    }

    override func tableView(_ tableView: UITableView,
                            trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath)
    -> UISwipeActionsConfiguration? {

        let deleteAction = UIContextualAction(style: .destructive,
                                                title: "Delete") { [weak self] (_, _, completionHandler) in
            self?.handleMarkAsDelete(chore: (self?.chores[indexPath.row])!, onComplete: completionHandler)
        }
        deleteAction.backgroundColor = UIColor.systemRed
        deleteAction.image = UIImage(named: "trash.fill")

        let configuration = UISwipeActionsConfiguration(actions: [deleteAction])
        return configuration
    }

    // MARK: - Internal
    private func handleMarkAsComplete(chore: Chore, onComplete completion: @escaping (Bool) -> Void) {
        DatabaseManager.shared.completeChore(chore: chore) { (result) in
            switch result {
            case .failure(let err):
                log.error(err.localizedDescription)
                completion(false)
            case .success:
                log.info("Correctly completed chore with id \(chore.id ?? "null")")
                completion(true)
            }
        }
    }

    private func handleMarkAsDelete(chore: Chore, onComplete completion: @escaping (Bool) -> Void) {
        DatabaseManager.shared.deleteChore(choreId: chore.id!) { (result) in
            switch result {
            case .failure(let err):
                log.error(err.localizedDescription)
                completion(false)
            case .success:
                log.info("Correctly deleted chore with id \(chore.id ?? "null")")
                completion(true)
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
                viewController.title = "Edit Chore"
            } else {
                viewController.title = "New Chore"
            }

            navigationController?.pushViewController(viewController, animated: true)
        }
    }

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
}

// MARK: - Database delegate
extension ChoresTableViewController: DatabaseManagerDelegate {
    func didAddChore(chore: Chore) {
        chores.append(chore)
        log.info("Reloading table view")
        tableView.reloadData()
    }

    /*
     FIXME: Check memory leak in ChoreTableView when these are triggered,
     might be related to deleting and updating rows
     */
    func didModifyChore(chore: Chore) {
        if let index = chores.firstIndex(where: { $0.id == chore.id }) {
            let indexPath = IndexPath(row: index, section: 0)

            chores[index] = chore
            log.info("Reloading rows at \(indexPath)")
            tableView.reloadRows(at: [indexPath], with: .automatic)
        } else {
            log.warning("Unable to modify updated chore in list")
        }
    }

    func didDeleteChore(chore: Chore) {
        if let index = chores.firstIndex(where: { $0.id == chore.id }) {
            let indexPath = IndexPath(row: index, section: 0)

            chores.remove(at: index)
            log.info("Deleting rows at \(indexPath)")
            tableView.deleteRows(at: [indexPath], with: .automatic)
        } else {
            log.warning("Unable to delete removed chore in list")
        }
    }

}
