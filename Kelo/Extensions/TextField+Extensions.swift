//
//  TextField+Extensions.swift
//  Kelo
//
//  Created by Raul Olmedo on 6/4/21.
//

import UIKit

extension UITextField {
    func showError(_ message: String, in label: UILabel) {
        layer.borderColor = UIColor.red.cgColor
        layer.borderWidth = 1.0
        layer.cornerRadius = 5

        label.isHidden = false
        label.text = message
    }

    func hideError(_ label: UILabel) {
        layer.borderColor = UIColor.lightGray.cgColor
        layer.borderWidth = 0
        layer.cornerRadius = 5

        label.isHidden = true
    }

}
