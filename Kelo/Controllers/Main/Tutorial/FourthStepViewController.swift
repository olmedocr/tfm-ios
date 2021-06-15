//
//  FourthStepViewController.swift
//  Kelo
//
//  Created by Raul Olmedo on 15/6/21.
//

import UIKit

class FourthStepViewController: UIViewController {

    // MARK: - @IBActions
    @IBAction func didTapContinueButton(_ sender: Any) {
        if let pageController = parent as? TutorialViewController {
            pageController.popToPrevious()
        }
    }

    // MARK: - View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

}
