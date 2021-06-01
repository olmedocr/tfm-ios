//
//  TableViewDataSource+User.swift
//  Kelo
//
//  Created by Raul Olmedo on 29/5/21.
//

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

                cell.pointsLabel.text = String(user.points)

                if user.id == DatabaseManager.shared.userId {
                    cell.userNameLabel.text = user.name + " (You)"
                } else {
                    cell.userNameLabel.text = user.name
                }
            }
        }
    }
}
