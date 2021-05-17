//
//  CreateViewController.swift
//  Kelo
//
//  Created by Raul Olmedo on 29/3/21.
//

import UIKit
import FittedSheets

class CreateViewController: UIViewController {

    // MARK: Properties

    // MARK: IBOutlets
    @IBOutlet weak var groupNameTextField: UITextField!
    @IBOutlet weak var currencyFlagImageView: UIImageView!
    @IBOutlet weak var currencyLabel: UILabel!
    @IBOutlet weak var groupErrorLabel: UILabel!
    @IBOutlet weak var currencyErrorLabel: UILabel!

    // MARK: IBOutlet Collections
    @IBOutlet var viewsToAnimate: [UIView]!

    // MARK: IBActions
    @IBAction func didTapBack(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }

    @IBAction func didTapCurrencyButton(_ sender: Any) {
        self.presentCurrencyTableViewController()
    }

    @IBAction func didTapContinue(_ sender: Any) {
        if groupNameTextField.validate(regex: Constants.groupNameRegex, errorLabel: groupErrorLabel) {
            let group = Group(name: groupNameTextField.text!, currency: currencyLabel.text!)

            if !currencyLabel.isHidden {
                DatabaseManager.shared.createGroup(group: group) { (result) in
                    switch result {
                    case .success(let group):
                        self.presentFinalViewController(withGroup: group)
                    case .failure(let err):
                        log.error(err)
                    }
                }
            } else {
                currencyErrorLabel.isHidden = false
                log.error("Invalid currency")
            }
        }
    }

    // MARK: View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        groupNameTextField.delegate = self
        hideKeyboardWhenTappedAround()

        configureDismissGesture()
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

    private func presentCurrencyTableViewController() {
        guard let controller = UIStoryboard(name: "Main", bundle: nil)
                .instantiateViewController(withIdentifier: "CurrencyTableViewController")
                as? CurrencyTableViewController
        else {
            log.error("Could not instantiate CurrencyViewController")
            return
        }

        controller.delegate = self

        currencyErrorLabel.isHidden = true

        let options = SheetOptions(shrinkPresentingViewController: false)
        let sheetController = SheetViewController(
            controller: controller,
            sizes: [.percent(0.35), .fullscreen],
            options: options)

        navigationController?.present(sheetController, animated: true, completion: nil)
    }
}

// MARK: - TextField delegate
extension CreateViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.hideError(groupErrorLabel)
    }
}

// MARK: - CurrencyTable delegate
extension CreateViewController: CurrencyTableViewDelegate {
    func didSelectCurrency(currency: Currency) {
        currencyLabel.text = currency.code
        currencyFlagImageView.image = currency.flag
    }
}

// MARK: - Animatable views
extension CreateViewController: Animatable {
    func getViewsToAnimate() -> [UIView] {
        return viewsToAnimate
    }
}
