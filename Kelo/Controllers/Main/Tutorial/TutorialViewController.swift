//
//  TutorialViewController.swift
//  Kelo
//
//  Created by Raul Olmedo on 15/6/21.
//

import UIKit

class TutorialViewController: UIPageViewController {

    // MARK: - Properties
    private var currentIndex = 0

    // MARK: - UI Elements
    private var viewControllerList: [UIViewController] = {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let firstVC = storyboard.instantiateViewController(withIdentifier: "FirstStepViewController")
        let secondVC = storyboard.instantiateViewController(withIdentifier: "SecondStepViewController")
        let thirdVC = storyboard.instantiateViewController(withIdentifier: "ThirdStepViewController")
        let fourthVC = storyboard.instantiateViewController(withIdentifier: "FourthStepViewController")

        return [firstVC, secondVC, thirdVC, fourthVC]
    }()

    // MARK: - View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        self.setViewControllers([viewControllerList[0]], direction: .forward, animated: false, completion: nil)
    }

    // MARK: - Internal
    func pushNext() {
        if currentIndex + 1 < viewControllerList.count {
            self.setViewControllers([self.viewControllerList[self.currentIndex + 1]],
                                    direction: .forward,
                                    animated: true,
                                    completion: nil)

            currentIndex += 1
        }
    }

    func popToPrevious() {
        self.dismiss(animated: true, completion: nil)
    }

}
