//
//  AssignChoreViewController.swift
//  Kelo
//
//  Created by Raul Olmedo on 11/5/21.
//

import UIKit

class AssignChoreViewController: UIViewController {

    // MARK: Properties
    weak var delegate: UsersTableViewDelegate?
    weak var embeddedTableView: UsersTableViewController?

    // MARK: IBActions
    @IBAction func didTapRandomButton(_ sender: Any) {
        DatabaseManager.shared.getRandomUser { (result) in
            switch result {
            case .failure(let err):
                log.error(err.localizedDescription)
            case .success(let user):
                let index = self.embeddedTableView?.dataSource?.models.firstIndex(where: { $0.id == user.id })
                let indexPath = IndexPath(row: index!, section: 0)
                self.embeddedTableView?.tableView.delegate?.tableView?((self.embeddedTableView?.tableView)!,
                                                                       didSelectRowAt: indexPath)
            }
        }
    }

    @IBAction func didTapMostLazyButton(_ sender: Any) {
        DatabaseManager.shared.getMostLazyUser { (result) in
            switch result {
            case .failure(let err):
                log.error(err.localizedDescription)
            case .success(let user):
                let index = self.embeddedTableView?.dataSource?.models.firstIndex(where: { $0.id == user.id })
                let indexPath = IndexPath(row: index!, section: 0)
                self.embeddedTableView?.tableView.delegate?.tableView?((self.embeddedTableView?.tableView)!,
                                                                       didSelectRowAt: indexPath)
            }
        }
    }

    // MARK: View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let embeddedViewController = segue.destination as? UsersTableViewController {
            embeddedTableView = embeddedViewController
            embeddedViewController.delegate = delegate
        }
    }

}
