//
//  SceneDelegate.swift
//  Kelo
//
//  Created by Raul Olmedo on 23/3/21.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    let defaults = UserDefaults.standard
    var window: UIWindow?

    func scene(_ scene: UIScene,
               willConnectTo session: UISceneSession,
               options connectionOptions: UIScene.ConnectionOptions) {

        if let userActivity = connectionOptions.userActivities.first, let url = userActivity.webpageURL {
            handleUniversalLinks(url: url, scene: scene)
        }

        guard let windowScene = (scene as? UIWindowScene) else { return }

        if !defaults.bool(forKey: UserDefaults.Keys.hasBeenLaunchedBefore.rawValue) {
            let window = UIWindow(windowScene: windowScene)

            if let viewController = UIStoryboard(name: "Main", bundle: nil)
                .instantiateViewController(withIdentifier: "InitialViewController") as? InitialViewController {

                let navigationController = OnboardingNavigationController(rootViewController: viewController)

                window.rootViewController = navigationController

                self.window = window
                window.makeKeyAndVisible()
            }
        }
    }

    func scene(_ scene: UIScene, continue userActivity: NSUserActivity) {

        if let url = userActivity.webpageURL {
            handleUniversalLinks(url: url, scene: scene)
        }
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        /* The scene may re-connect later, as its session was not necessarily discarded
            (see `application:didDiscardSceneSessions` instead). */
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }

    // MARK: - Internal
    private func handleUniversalLinks(url: URL, scene: UIScene) {
        let groupId = url.deletingPathExtension().lastPathComponent

        if !groupId.isEmpty {
            log.info("(App was open) Universal link followed to group \(groupId)")
            appCleanup()
            joinGroup(withGroupId: groupId, scene: scene)
        }
    }

    private func appCleanup() {
        if defaults.bool(forKey: UserDefaults.Keys.hasBeenLaunchedBefore.rawValue) {
            if let groupId = defaults.string(forKey: UserDefaults.Keys.groupId.rawValue),
               let userId = defaults.string(forKey: UserDefaults.Keys.userId.rawValue) {
                DatabaseManager.shared.groupId = groupId
                DatabaseManager.shared.userId = userId

                DatabaseManager.shared.deleteUser(userId: userId) { (result) in
                    switch result {
                    case .failure(let err):
                        log.error("Failed to delete the user while joining other group")
                        log.error(err.localizedDescription)
                    case .success:
                        log.info("Correctly deleted user from existing group while joining another one")
                        log.info("Deleting now current user defaults")
                        self.defaults.reset()

                        log.info("Removing references to old groupId and userId in DatabaseManager singleton")
                        DatabaseManager.shared.groupId = nil
                        DatabaseManager.shared.userId = nil
                    }
                }
            }
        }
    }

    private func joinGroup(withGroupId groupId: String, scene: UIScene) {
        // Rememeber to rite groupId in userDefaults (?)
        // Show FinalViewController

        log.info("Setting new groupId in DatabaseManager")
        DatabaseManager.shared.groupId = groupId

        guard let windowScene = (scene as? UIWindowScene) else {
            log.error("Failed to join new group: scene could not be casted")
            return
        }

        let window = UIWindow(windowScene: windowScene)

        if let viewController = UIStoryboard(name: "Main", bundle: nil)
            .instantiateViewController(withIdentifier: "JoinViewController") as? JoinViewController {

            let navigationController = OnboardingNavigationController(rootViewController: viewController)

            window.rootViewController = navigationController

            viewController.groupCode = groupId

            self.window = window
            window.makeKeyAndVisible()
        }
    }

}
