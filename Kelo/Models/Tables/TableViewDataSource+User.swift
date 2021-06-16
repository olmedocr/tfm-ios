//
//  TableViewDataSource+User.swift
//  Kelo
//
//  Created by Raul Olmedo on 29/5/21.
//

import Foundation
import LetterAvatarKit

extension TableViewDataSource where Model == User {

    static func make(for users: [User],
                     reuseIdentifier: String = "userTableViewCell") -> TableViewDataSource {
        return TableViewDataSource(
            models: users,
            reuseIdentifier: reuseIdentifier
        ) { (user, cell) in
            if let cell = cell as? UserTableViewCell {

                let circleAvatarImage = LetterAvatarMaker()
                    .setCircle(true)
                    .setUsername(user.name)
                    .useSingleLetter(true)
                    .build()

                cell.userImage.image = circleAvatarImage

                if let adminLabel = cell.adminLabel {
                    adminLabel.isHidden = !user.isAdmin
                }

                setMarquee(cell)

                cell.pointsLabel.text = String(user.points)

                if user.id == DatabaseManager.shared.userId {
                    cell.userNameLabel.text = user.name + " " + NSLocalizedString("(You)", comment: "")
                } else {
                    cell.userNameLabel.text = user.name
                }
            }
        }
    }

    private static func setMarquee(_ cell: UserTableViewCell) {
        cell.userNameLabel.type = .continuous
        cell.userNameLabel.speed = .duration(8)
        cell.userNameLabel.animationCurve = .easeInOut
        cell.userNameLabel.fadeLength = 5.0
        cell.userNameLabel.trailingBuffer = 14.0
    }

}
