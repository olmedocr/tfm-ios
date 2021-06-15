//
//  FirstStepViewController.swift
//  Kelo
//
//  Created by Raul Olmedo on 15/6/21.
//

import UIKit

class FirstStepViewController: UIViewController {

    @IBOutlet var labels: [UILabel]!

    // MARK: - @IBActions
    @IBAction func didTapContinueButton(_ sender: Any) {
        if let pageController = parent as? TutorialViewController {
            pageController.pushNext()
        }
    }

    // MARK: - View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        labels.forEach { label in
            label.preferredMaxLayoutWidth = label.bounds.size.width
        }
        // Do any additional setup after loading the view.
    }

}
