//
//  TextField+Extensions.swift
//  Kelo
//
//  Created by Raul Olmedo on 6/4/21.
//

import UIKit

extension UITextField {
    func showError(_ errorLabel: UILabel? = nil) {
        layer.borderColor = UIColor.red.cgColor
        layer.borderWidth = 1.0
        layer.cornerRadius = 5

        errorLabel?.isHidden = false
    }

    func hideError(_ errorLabel: UILabel? = nil) {
        layer.borderColor = UIColor.lightGray.cgColor
        layer.borderWidth = 0
        layer.cornerRadius = 5

        errorLabel?.isHidden = true
    }

    func validate(regex: NSRegularExpression, errorLabel: UILabel) -> Bool {
        if regex.matches(text!) {
            log.info("Validated textField")
            hideError(errorLabel)
            return true
        } else {
            log.error("Invalid textField")
            showError(errorLabel)
            return false
        }
    }

}
