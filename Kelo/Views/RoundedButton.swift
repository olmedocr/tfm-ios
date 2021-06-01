//
//  RoundedButtonView.swift
//  Kelo
//
//  Created by Raul Olmedo on 29/3/21.
//

import UIKit

/* @IBDesignable */
class RoundedButton: UIButton {

    /* @IBInspectable */
    var cornerRadius: CGFloat {
            get {
                layer.cornerRadius
            }
            set {
                layer.cornerRadius = newValue
                layer.masksToBounds = false
                layer.cornerCurve = .continuous
            }
        }

    func showError(_ errorLabel: UILabel? = nil) {
        layer.borderColor = UIColor.red.cgColor
        layer.borderWidth = 1.0

        errorLabel?.isHidden = false
    }

    func hideError(_ errorLabel: UILabel? = nil) {
        layer.borderColor = UIColor.lightGray.cgColor
        layer.borderWidth = 0

        errorLabel?.isHidden = true
    }
}
