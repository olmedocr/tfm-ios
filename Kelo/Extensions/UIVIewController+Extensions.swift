//
//  UIVIewController+dismissKeyboard.swift
//  Kelo
//
//  Created by Raul Olmedo on 29/3/21.
//

import UIKit

// Set the views that are to be animated during the transition
protocol Animatable {
    func getViewsToAnimate() -> [UIView]
}

extension UIViewController {

    // Hide keyboard when tapped outside of it
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self,
                                                                 action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }

    @objc func dismissKeyboard() {
        view.endEditing(true)
    }

    @objc func keyboardWillShow(notification: NSNotification) {
        guard let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?
                .cgRectValue else {
            return
        }

        view.frame.origin.y = 0 - keyboardSize.height
    }

    @objc func keyboardWillHide(notification: NSNotification) {
        view.frame.origin.y = 0
    }
}
