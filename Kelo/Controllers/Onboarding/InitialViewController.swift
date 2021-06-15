//
//  InitialViewController.swift
//  Kelo
//
//  Created by Raul Olmedo on 20/4/21.
//

import UIKit

class InitialViewController: UIViewController {

    // MARK: - IBOutlet Collections
    @IBOutlet var viewsToAnimate: [UIView]!

    // MARK: - IBActions
    @IBAction func didTapCreateGroup(_ sender: Any) {
        log.debug("Create group")
        presentCreateViewController()
    }

    @IBAction func didTapJoinGroup(_ sender: Any) {
        log.debug("Join group")
        presentJoinViewController()
    }

    // MARK: - View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    // MARK: - Navigation
    private func presentJoinViewController() {
        if let viewController = UIStoryboard(name: "Main", bundle: nil)
            .instantiateViewController(withIdentifier: "JoinViewController") as? JoinViewController {

            navigationController?.pushViewController(viewController, animated: true)
        }
    }

    private func presentCreateViewController() {
        if let viewController = UIStoryboard(name: "Main", bundle: nil)
            .instantiateViewController(withIdentifier: "CreateViewController") as? CreateViewController {

            navigationController?.pushViewController(viewController, animated: true)
        }
    }

}

// MARK: - Animatable views
extension InitialViewController: Animatable {

    func getViewsToAnimate() -> [UIView] {
        return viewsToAnimate
    }

}
