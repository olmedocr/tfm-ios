//
//  JoinViewController.swift
//  Kelo
//
//  Created by Raul Olmedo on 29/3/21.
//

import UIKit

class JoinViewController: UIViewController {

    // MARK: Properties
    var groupCode: String?

    // MARK: IBOutlets
    @IBOutlet weak var groupCodeTextField: UITextField!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var backButton: UIButton!

    // MARK: IBOutlet Collections
    @IBOutlet var viewsToAnimate: [UIView]!

    // MARK: IBActions
    @IBAction func didTapBack(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }

    @IBAction func didTapContinue(_ sender: Any) {
        if groupCodeTextField.validate(regex: Constants.groupCodeRegex, errorLabel: errorLabel) {
            let groupId = groupCodeTextField.text!

            DatabaseManager.shared.checkGroupAvailability(groupId: groupId) { (result) in
                switch result {
                case .success(let group):
                    log.info("Group available")
                    self.presentFinalViewController(withGroup: group)
                case .failure(let err):
                    log.error(err)
                    let alert = self.setAlert(title: "Error!",
                                              message: err.localizedDescription,
                                              actionTitle: "OK")

                    self.present(alert, animated: true)
                }
            }
        }
    }

    // MARK: View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        groupCodeTextField.delegate = self
        hideKeyboardWhenTappedAround()

        configureDismissGesture()

        if let groupCode = groupCode {
            groupCodeTextField.text = groupCode
            backButton.isHidden = true
        }
    }

    // MARK: - Internal
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
    private func presentFinalViewController(withGroup group: Group) {
        if let viewController = UIStoryboard(name: "Main", bundle: nil)
            .instantiateViewController(withIdentifier: "FinalViewController") as? FinalViewController {
            viewController.group = group
            navigationController?.pushViewController(viewController, animated: true)
        }
    }
}

// MARK: - TextField delegate
extension JoinViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.hideError(errorLabel)
    }
}

// MARK: - Animatable views
extension JoinViewController: Animatable {
    func getViewsToAnimate() -> [UIView] {
        return viewsToAnimate
    }
}
