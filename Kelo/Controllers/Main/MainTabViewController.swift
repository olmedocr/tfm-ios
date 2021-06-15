//
//  MainTabViewController.swift
//  Kelo
//
//  Created by Raul Olmedo on 9/4/21.
//

import UIKit
import FittedSheets
import FirebaseMessaging

class MainTabViewController: UITabBarController {

    // MARK: - Properties
    let defaults = UserDefaults.standard

    // MARK: - View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        loadData()

        setupNotifications()

    }

    private func setupNotifications() {
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            appDelegate.notificationDelegate = self
        }

        DatabaseManager.shared.retrieveUser(userId: DatabaseManager.shared.userId!) { result in
            switch result {
            case .failure(let err):
                log.error(err.localizedDescription)
            case .success(var user):
                Messaging.messaging().token { token, err in
                    if let err = err {
                        log.error(err.localizedDescription)
                    } else if let token = token {
                        log.info("Obtained FCM token")
                        user.messagingToken = token

                        DatabaseManager.shared.updateUser(user: user) { updateResult in
                            switch updateResult {
                            case .failure(let err):
                                log.error(err.localizedDescription)
                            case .success:
                                log.info("Stored FCM token in database")
                            }
                        }
                    } else {
                        log.error("Unknown error while storing FCM token in database")
                    }
                }

            }
        }

    }

    private func loadData() {
        if let groupId = defaults.string(forKey: UserDefaults.Keys.groupId.rawValue),
           let userId = defaults.string(forKey: UserDefaults.Keys.userId.rawValue) {

            DatabaseManager.shared.groupId = groupId
            DatabaseManager.shared.userId = userId

            Validations.userInGroup(userId, groupId: groupId) { result in
                switch result {
                case .failure(let err):
                    log.error(err.localizedDescription)
                    self.restartApp(withMessage: err.localizedDescription)
                case .success:
                    log.info("The group still exists and the user keeps belonging to it")

                    DatabaseManager.shared.delegate = self
                    DatabaseManager.shared.subscribeToUserList { result in
                        switch result {
                        case .failure(let err):
                            log.error(err.localizedDescription)
                        case .success:
                            log.info("Subscribed to user changes")
                        }
                    }
                }
            }
        } else {
            log.error("No ids found on userDefaults")
        }

    }

    // MARK: - Navigation
    func presentShareGroupCodeViewController(context: UIViewController) {
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

        context.present(sheetController, animated: true, completion: nil)

    }

}

extension MainTabViewController: DatabaseManagerDelegate {

    func didDeleteUser(user: User) {
        if user.id == DatabaseManager.shared.userId {
            log.warning("This user was deleted remotely by the admin")
            self.restartApp(withMessage: "The admin removed you from the group")
        }
    }

}

extension MainTabViewController: NotificationDelegate {
    func didReceivedNotification() {
        if let navController = self.children.first as? UINavigationController,
           let viewController = navController.children.first as? ChoresTableViewController {
            viewController.fetchData()
        }
    }

}
