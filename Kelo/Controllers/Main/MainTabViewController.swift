//
//  MainTabViewController.swift
//  Kelo
//
//  Created by Raul Olmedo on 9/4/21.
//

import UIKit

class MainTabViewController: UITabBarController {

    // MARK: Properties
    let defaults = UserDefaults.standard

    // MARK: View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        if let groupId = defaults.string(forKey: UserDefaults.Keys.groupId.rawValue) {
            DatabaseManager.shared.groupId = groupId
        } else {
            log.error("No groupId found")
        }

        if let userId = defaults.string(forKey: UserDefaults.Keys.userId.rawValue) {
            DatabaseManager.shared.userId = userId
        } else {
            log.error("No userId found")
        }
    }
}
