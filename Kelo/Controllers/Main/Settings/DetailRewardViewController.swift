//
//  DetailRewardViewController.swift
//  Kelo
//
//  Created by Raul Olmedo on 9/6/21.
//

import UIKit
import FittedSheets
import LetterAvatarKit

class DetailRewardViewController: UIViewController {

    // MARK: - Properties
    var reward: Reward?
    var selectedPeriod: Period? {
        didSet {
            if let period = selectedPeriod {
                self.periodButton.setTitle(period.description, for: .normal)
                if period != .none {
                    self.computedExpiration = Calendar.current.date(byAdding: period.component!,
                                                                    to: reward?.creation ?? Date())
                }

            }
        }
    }
    var computedExpiration: Date?

    // MARK: - IBOutlets
    @IBOutlet weak var rewardImage: UIImageView!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var rewardTitleErrorLabel: UILabel!
    @IBOutlet weak var periodButton: RoundedButton!
    @IBOutlet weak var periodErrorLabel: UILabel!

    // MARK: - IBActions
    @IBAction func didTapPeriodButton(_ sender: Any) {
        periodButton.hideError(periodErrorLabel)

        presentPeriodTableViewController()
    }

    // MARK: - View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        titleTextField.delegate = self
        hideKeyboardWhenTappedAround()

        // Set placeholder image
        let circleAvatarImage = LetterAvatarMaker()
            .setCircle(true)
            .setUsername(" ")
            .setBackgroundColors([UIColor.systemBackground])
            .build()

        rewardImage.image = circleAvatarImage

        fillFormIfEditingReward()

        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save,
                                                            target: self,
                                                            action: #selector(didTapSaveButton(_:)))

    }

    // MARK: - Internal
    private func fillFormIfEditingReward() {
        if let reward = reward {
            titleTextField.text = reward.name

            periodButton.setTitle(reward.frequency?.description, for: .normal)

            selectedPeriod = reward.frequency

            let circleAvatarImage = LetterAvatarMaker()
                .setCircle(true)
                .setUsername(reward.name)
                .useSingleLetter(true)
                .build()

            rewardImage.image = circleAvatarImage
        }
    }

    private func validateAndStoreInDatabase() {
        let title = titleTextField.text ?? ""
        let icon = ""
        let expiration = computedExpiration
        let creation = reward?.creation ?? Date()
        let frequency = selectedPeriod

        var rewardToSave = Reward(name: title,
                                  icon: icon,
                                  expiration: expiration,
                                  creation: creation,
                                  frequency: frequency)

        rewardToSave.id = reward?.id

        switch Validations.reward(rewardToSave) {
        case .failure(let err):
            log.error(err.localizedDescription)
            periodButton.showError(periodErrorLabel)
        case .success:
            log.info("Validated reward")
            if reward != nil {
                updateInDatabase(rewardToSave)
            } else {
                storeInDatabase(rewardToSave)
            }
        }
    }

    private func storeInDatabase(_ reward: Reward) {
        DatabaseManager.shared.createReward(reward: reward) { result in
            switch result {
            case .failure(let err):
                log.error(err.localizedDescription)
            case .success:
                log.info("Dismissing after creating reward")
                self.navigationController?.popViewController(animated: true)
            }
        }
    }

    private func updateInDatabase(_ reward: Reward) {
        DatabaseManager.shared.updateReward(reward: reward) { result in
            switch result {
            case .failure(let err):
                log.error(err.localizedDescription)
            case .success:
                log.info("Dismissing after updating reward")
                self.navigationController?.popViewController(animated: true)
            }
        }
    }

    @objc private func didTapSaveButton(_ sender: Any) {
        switch Validations.rewardName(titleTextField.text!) {
        case .failure(let err):
            log.error(err.localizedDescription)
            titleTextField.showError(err.localizedDescription, in: rewardTitleErrorLabel)
        case .success:
            log.info("Validated reward name")
            titleTextField.hideError(rewardTitleErrorLabel)

            validateAndStoreInDatabase()
        }
    }

    // MARK: - Navigation
    private func presentPeriodTableViewController() {
        guard let controller = UIStoryboard(name: "Main", bundle: nil)
                .instantiateViewController(withIdentifier: "PeriodTableViewController")
                as? PeriodTableViewController
        else {
            log.error("Could not instantiate PeriodTableViewController")
            return
        }

        controller.delegate = self

        periodErrorLabel.isHidden = true

        let options = SheetOptions(shrinkPresentingViewController: false)
        let sheetController = SheetViewController(
            controller: controller,
            sizes: [.percent(0.5)],
            options: options)

        navigationController?.present(sheetController, animated: true, completion: nil)
    }
}

// MARK: - TextField delegate
extension DetailRewardViewController: UITextFieldDelegate {

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    func textFieldDidBeginEditing(_ textField: UITextField) {
        titleTextField.hideError(rewardTitleErrorLabel)
    }

}

extension DetailRewardViewController: PeriodTableViewDelegate {

    func didSelectPeriod(period: Period) {
        selectedPeriod = period
    }
}
