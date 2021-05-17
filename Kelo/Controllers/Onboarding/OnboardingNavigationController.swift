//
//  OnboardingNavigationController.swift
//  Kelo
//
//  Created by Raul Olmedo on 15/4/21.
//

import UIKit

class OnboardingNavigationController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationBar.isHidden = true

        self.delegate = self
    }

}

extension OnboardingNavigationController: UINavigationControllerDelegate {
    public func navigationController(_ navigationController: UINavigationController,
                                     animationControllerFor operation: UINavigationController.Operation,
                                     from fromVC: UIViewController,
                                     to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {

        return SetupTransition(withOperation: operation)
    }

}
