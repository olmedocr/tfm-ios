//
//  NewChoreViewController.swift
//  Kelo
//
//  Created by Raul Olmedo on 5/5/21.
//

import UIKit
import FittedSheets
import LetterAvatarKit

class DetailChoreViewController: UIViewController {

    // MARK: Properties
    var chore: Chore?
    var selectedAssignee: User? {
        didSet {
            if let assignee = selectedAssignee {
                if DatabaseManager.shared.userId == assignee.id {
                    self.assigneeButton.setTitle(assignee.name + " (You)", for: .normal)
                } else {
                    self.assigneeButton.setTitle(assignee.name, for: .normal)
                }
            }
        }
    }

    // MARK: IBOutlets
    @IBOutlet weak var choreTextField: UITextField!
    @IBOutlet weak var assigneeButton: RoundedButton!
    @IBOutlet weak var importanceLevel: UISegmentedControl!
    @IBOutlet weak var expirationDate: UIDatePicker!
    @IBOutlet weak var choreTitleErrorLabel: UILabel!
    @IBOutlet weak var choreImage: UIImageView!
    @IBOutlet weak var assigneeErrorLabel: UILabel!

    // MARK: IBActions
    @IBAction func didTapAssigneeButton(_ sender: Any) {
        assigneeButton.hideError(assigneeErrorLabel)

        presentUsersTableViewController()
    }

    // MARK: View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        choreTextField.delegate = self
        hideKeyboardWhenTappedAround()

        // Set placeholder image
        let circleAvatarImage = LetterAvatarMaker()
            .setCircle(true)
            .setUsername(" ")
            .setBackgroundColors([UIColor.white])
            .setBorderWidth(1.0)
            .build()

        choreImage.image = circleAvatarImage

        fillFormIfEditingChore()

        setupDatePickerMinAndMaxDates()

        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save,
                                                            target: self,
                                                            action: #selector(didTapSaveButton(_:)))

        // Change expiration date color
        expirationDate.tintColor = UIColor(named: "AccentColor")
        expirationDate.backgroundColor = UIColor(named: "AccentColor")

        // Change segmented control tint color
        let titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        importanceLevel.setTitleTextAttributes(titleTextAttributes, for: .selected)
        importanceLevel.selectedSegmentTintColor = UIColor(named: "AccentColor")

    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()

        // Force the date picker to have the same background as the other items
        if let viewPicker = expirationDate.subviews.first?.subviews.first {
            viewPicker.subviews.last?.tintColor = UIColor.white
            if let bgViewPicker = viewPicker.subviews.first {
                bgViewPicker.backgroundColor = .clear
            }

            viewPicker.center.x = expirationDate.subviews.first!.center.x
        }
    }

    // MARK: - Internal
    private func fillFormIfEditingChore() {
        if let chore = chore {
            choreTextField.text = chore.name

            DispatchQueue.global(qos: .userInitiated).async {
                DatabaseManager.shared.retrieveUser(userId: chore.assignee) { (result) in
                    switch result {
                    case .failure(let err):
                        log.error(err.localizedDescription)
                    case .success(let user):
                        self.selectedAssignee = user
                    }
                }
            }

            if chore.points == Chore.Importance.low.rawValue {
                importanceLevel.selectedSegmentIndex = 0
            } else if chore.points == Chore.Importance.medium.rawValue {
                importanceLevel.selectedSegmentIndex = 1
            } else if chore.points == Chore.Importance.high.rawValue {
                importanceLevel.selectedSegmentIndex = 2
            } else {
                log.warning("Unknown chore importance value")
            }

            let circleAvatarImage = LetterAvatarMaker()
                .setCircle(true)
                .setUsername(chore.name)
                .setBorderWidth(1.0)
                .build()

            choreImage.image = circleAvatarImage

            expirationDate.date = chore.expiration
        }
    }

    private func setupDatePickerMinAndMaxDates() {
        expirationDate.minimumDate = Date()
        expirationDate.maximumDate = Date().addingTimeInterval(63072000) // 2 years
    }

    private func validateAndStoreInDatabase() {
        let title = choreTextField.text!
        let icon = ""
        let assigneeId = selectedAssignee!.id!
        let expiration = expirationDate.date
        var points: Int {
            var returnValue: Int?

            switch self.importanceLevel.selectedSegmentIndex {
            case 0:
                returnValue = Chore.Importance.low.rawValue
            case 1:
                returnValue = Chore.Importance.medium.rawValue
            case 2:
                returnValue = Chore.Importance.high.rawValue
            default:
                assertionFailure("Unknown value for the importance")
            }

            return returnValue!
        }

        var choreToSave = Chore(name: title,
                                icon: icon,
                                assignee: assigneeId,
                                expiration: expiration,
                                points: points)

        choreToSave.id = chore?.id

        switch Validations.chore(choreToSave) {
        case .failure(let err):
            log.error(err.localizedDescription)
            assigneeButton.showError(assigneeErrorLabel)
        case .success:
            log.info("Validated chore")
            if chore != nil {
                updateInDatabase(choreToSave)
            } else {
                storeInDatabase(choreToSave)
            }
        }
    }

    private func storeInDatabase(_ chore: Chore) {
        DatabaseManager.shared.createChore(chore: chore) { result in
            switch result {
            case .failure(let err):
                log.error(err.localizedDescription)
            case .success:
                log.info("Dismissing after creating chore")
                self.navigationController?.popViewController(animated: true)
            }
        }
    }

    private func updateInDatabase(_ chore: Chore) {
        DatabaseManager.shared.updateChore(chore: chore) { result in
            switch result {
            case .failure(let err):
                log.error(err.localizedDescription)
            case .success:
                log.info("Dismissing after updating chore")
                self.navigationController?.popViewController(animated: true)
            }
        }
    }

    @objc private func didTapSaveButton(_ sender: Any) {
        switch Validations.choreName(choreTextField.text!) {
        case .failure(let err):
            log.error(err.localizedDescription)
            choreTextField.showError(err.localizedDescription, in: choreTitleErrorLabel)
        case .success:
            log.info("Validated chore name")
            choreTextField.hideError(choreTitleErrorLabel)

            validateAndStoreInDatabase()
        }
    }

    // MARK: - Navigation
    private func presentUsersTableViewController() {
        guard let controller = UIStoryboard(name: "Main", bundle: nil)
                .instantiateViewController(withIdentifier: "AssignChoreViewController")
                as? AssignChoreViewController
        else {
            log.error("Could not instantiate AssignChoreViewController")
            return
        }

        controller.delegate = self

        assigneeErrorLabel.isHidden = true

        let options = SheetOptions(shrinkPresentingViewController: false)
        let sheetController = SheetViewController(
            controller: controller,
            sizes: [.percent(0.35), .percent(0.5), .fullscreen],
            options: options)

        navigationController?.present(sheetController, animated: true, completion: nil)
    }
}

// MARK: - TextField delegate
extension DetailChoreViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    func textFieldDidBeginEditing(_ textField: UITextField) {
        choreTextField.hideError(choreTitleErrorLabel)
    }
}

extension DetailChoreViewController: UsersTableViewDelegate {
    func didSelectUser(user: User) {
        selectedAssignee = user
    }
}
