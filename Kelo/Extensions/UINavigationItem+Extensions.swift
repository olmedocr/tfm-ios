//
//  UINavigationViewController+Extensions.swift
//  Kelo
//
//  Created by Raul Olmedo on 15/6/21.
//

import UIKit

extension UINavigationItem {

    func addSubtitle(_ subtitle: String) {
        let label = UILabel(frame: CGRect(x: 10.0, y: 0.0, width: 50.0, height: 40.0))
        label.font = UIFont.boldSystemFont(ofSize: 14.0)
        label.numberOfLines = 2
        label.text = subtitle
        label.textColor = UIColor.label
        label.sizeToFit()
        label.textAlignment = NSTextAlignment.center

        self.titleView = label

    }
}
