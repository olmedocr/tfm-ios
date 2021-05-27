//
//  MainTabViewController.swift
//  Kelo
//
//  Created by Raul Olmedo on 9/4/21.
//

import UIKit
import SwipeableTabBarController

class MainTabViewController: SwipeableTabBarController {

    // MARK: Properties
    let defaults = UserDefaults.standard

    // MARK: View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        if let groupId = defaults.string(forKey: UserDefaults.Keys.groupId.rawValue) {
            DatabaseManager.shared.groupId = groupId
            DatabaseManager.shared.retrieveGroup(groupId: groupId) { (result) in
                switch result {
                case .failure(let err):
                    log.error(err.localizedDescription)
                    self.restartApp()
                case .success(let group):
                    self.children.forEach({ navigationController in
                        navigationController.children.first?.navigationItem.prompt = group.name
                    })
                }
            }
        } else {
            log.error("No groupId found")
        }

        if let userId = defaults.string(forKey: UserDefaults.Keys.userId.rawValue) {
            DatabaseManager.shared.userId = userId
            DatabaseManager.shared.retrieveUser(userId: userId) { (result) in
                switch result {
                case .failure(let err):
                    log.error(err.localizedDescription)
                    self.restartApp()
                case .success:
                    break
                }
            }
        } else {
            log.error("No userId found")
        }

    }
}
