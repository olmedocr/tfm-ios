//
//  FinalViewController.swift
//  Kelo
//
//  Created by Raul Olmedo on 23/3/21.
//

import UIKit

class FinalViewController: UIViewController {

    // MARK: Properties
    let defaults = UserDefaults.standard
    var group: Group?

    // MARK: IBOutlets
    @IBOutlet weak var userNameTextField: UITextField!
    @IBOutlet weak var errorLabel: UILabel!

    // MARK: IBOutlet Collections
    @IBOutlet var viewsToAnimate: [UIView]!

    // MARK: IBActions
    @IBAction func didTapContinue(_ sender: Any) {
        let user = User(name: userNameTextField.text!, points: 0)

        if userNameTextField.validate(regex: Constants.userNameRegex, errorLabel: errorLabel) {
            DatabaseManager.shared.groupId = group!.id
            self.defaults.setValue(group?.id, forKey: UserDefaults.Keys.groupId.rawValue)

            DatabaseManager.shared.joinGroup(user: user, group: group!) { (result) in
                switch result {
                case .failure(let err):
                    log.error(err)
                    if err as! DatabaseManager.CustomError == DatabaseManager.CustomError.userNameAlreadyTaken {
                        self.userNameTextField.showError(self.errorLabel)
                    }
                case .success(let userId):
                    log.info("Correctly joined group")
                    DatabaseManager.shared.userId = userId
                    self.defaults.setValue(userId, forKey: UserDefaults.Keys.userId.rawValue)

                    self.presentMainTableViewController(withGroup: self.group!)
                }
            }
        }
    }

    @IBAction func didTapBack(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }

    // MARK: View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        userNameTextField.delegate = self
        hideKeyboardWhenTappedAround()

        configureDismissGesture()
    }

    // MARK: Internal
    private func configureDismissGesture() {
        let dismissPanGesture = UIScreenEdgePanGestureRecognizer()

        dismissPanGesture.edges = .left
        dismissPanGesture.addTarget(self, action: #selector(dismissPanGestureDidChange(_:)))

        view.addGestureRecognizer(dismissPanGesture)
    }

    @objc private func dismissPanGestureDidChange(_ gesture: UIPanGestureRecognizer) {
        if gesture.state == .began {
            self.navigationController?.popViewController(animated: true)
        }
    }

    // MARK: - Navigation
    private func presentMainTableViewController(withGroup group: Group) {
        if let viewController = UIStoryboard(name: "Main", bundle: nil)
            .instantiateViewController(withIdentifier: "MainTabViewController") as? MainTabViewController {

            defaults.setValue(true, forKey: UserDefaults.Keys.hasBeenLaunchedBefore.rawValue)

            navigationController?.present(viewController, animated: true)
        }
    }
}

// MARK: - TextField delegate
extension FinalViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.hideError(errorLabel)
    }
}

// MARK: - Animatable views
extension FinalViewController: Animatable {
    func getViewsToAnimate() -> [UIView] {
        return viewsToAnimate
    }
}
