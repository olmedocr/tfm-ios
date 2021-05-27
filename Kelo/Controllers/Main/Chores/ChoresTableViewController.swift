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
    var dataSource: TableViewDataSource<Chore>?

    // MARK: View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.tableFooterView = UIView()

        DatabaseManager.shared.subscribeToChoreList { (result) in
            switch result {
            case .failure(let err):
                log.error(err.localizedDescription)
            case .success:
                DatabaseManager.shared.delegate = self

                self.dataSource = .make(for: [Chore].init())
                self.tableView.dataSource = self.dataSource
            }
        }
    }

    // MARK: IBActions
    @IBAction func didTapAddButton(_ sender: Any) {
        self.presentDetailChoreViewController()
    }

    @IBAction func didTapShareButton(_ sender: Any) {
        self.presentShareGroupCodeViewController()
    }

    // MARK: Table view delegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.presentDetailChoreViewController(dataSource?.models[indexPath.row])
    }

    override func tableView(_ tableView: UITableView,
                            leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath)
    -> UISwipeActionsConfiguration? {

        let completeAction = UIContextualAction(style: .normal,
                                                title: "Complete") { [weak self] (_, _, completionHandler) in
            self?.handleMarkAsComplete(chore: (self?.dataSource?.models[indexPath.row])!, onComplete: completionHandler)
        }
        completeAction.backgroundColor = UIColor.systemBlue
        completeAction.image = UIImage(systemName: "checkmark.circle.fill")

        let configuration = UISwipeActionsConfiguration(actions: [completeAction])
        return configuration
    }

    override func tableView(_ tableView: UITableView,
                            trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath)
    -> UISwipeActionsConfiguration? {

        let deleteAction = UIContextualAction(style: .destructive,
                                                title: "Delete") { [weak self] (_, _, completionHandler) in
            self?.handleMarkAsDelete(chore: (self?.dataSource?.models[indexPath.row])!, onComplete: completionHandler)
        }
        deleteAction.backgroundColor = UIColor.systemRed
        deleteAction.image = UIImage(systemName: "trash.fill")

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
}

// MARK: - Database delegate
extension ChoresTableViewController: DatabaseManagerDelegate {
    func didAddChore(chore: Chore) {
        dataSource?.models.append(chore)
        log.info("Reloading table view")
        tableView.reloadData()
    }

    func didModifyChore(chore: Chore) {
        if let index = dataSource?.models.firstIndex(where: { $0.id == chore.id }) {
            let indexPath = IndexPath(row: index, section: 0)

            dataSource?.models[index] = chore
            log.info("Reloading rows at \(indexPath)")
            tableView.reloadRows(at: [indexPath], with: .automatic)
        } else {
            log.warning("Unable to modify updated chore in list")
        }
    }

    func didDeleteChore(chore: Chore) {
        if let index = dataSource?.models.firstIndex(where: { $0.id == chore.id }) {
            let indexPath = IndexPath(row: index, section: 0)

            dataSource?.models.remove(at: index)
            log.info("Deleting rows at \(indexPath)")
            tableView.deleteRows(at: [indexPath], with: .automatic)
        } else {
            log.warning("Unable to delete removed chore in list")
        }
    }

}
