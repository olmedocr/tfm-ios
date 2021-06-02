//
//  CurrencyButton.swift
//  Kelo
//
//  Created by Raul Olmedo on 31/5/21.
//

import UIKit

class CurrencyButton: RoundedButton {

    override func awakeFromNib() {
        super.awakeFromNib()

        if imageView != nil {
            imageView?.translatesAutoresizingMaskIntoConstraints = false
            imageView?.contentMode = .scaleAspectFit

            imageView?.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
            imageView?.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 16).isActive = true
            imageView?.heightAnchor.constraint(equalTo: self.heightAnchor, constant: -32).isActive = true
            imageView?.widthAnchor.constraint(equalTo: imageView!.heightAnchor, multiplier: 2).isActive = true
            imageView?.trailingAnchor.constraint(equalTo: titleLabel!.leadingAnchor, constant: -8).isActive = true
        }
    }

}
