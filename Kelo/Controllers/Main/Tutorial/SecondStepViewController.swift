//
//  SecondStepViewController.swift
//  Kelo
//
//  Created by Raul Olmedo on 15/6/21.
//

import UIKit

class SecondStepViewController: UIViewController {

    // MARK: - @IBActions
    @IBAction func didTapContinueButton(_ sender: Any) {
        if let pageController = parent as? TutorialViewController {
            pageController.pushNext()
        }
    }

    // MARK: - View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

}
