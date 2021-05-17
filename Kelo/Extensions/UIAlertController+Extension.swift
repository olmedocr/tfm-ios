//
//  UIAlertController+setAlert.swift
//  Kelo
//
//  Created by Raul Olmedo on 29/3/21.
//

import UIKit

extension UIViewController {
    func setAlert(title: String,
                  message: String,
                  actionTitle: String,
                  onCompletion: ((UIAlertAction) -> Void)? = nil) -> UIAlertController {

        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)

        let action = UIAlertAction(title: actionTitle, style: .default, handler: onCompletion)

        alert.addAction(action)

        return alert
    }
}
