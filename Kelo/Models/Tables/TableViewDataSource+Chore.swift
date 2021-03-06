//
//  OrderedTableViewDataSource+Chore.swift
//  Kelo
//
//  Created by Raul Olmedo on 29/5/21.
//

import UIKit
import LetterAvatarKit

extension TableViewDataSource where Model == Chore {

    static func make(for chores: [Chore],
                     reuseIdentifier: String = "choreTableViewCell") -> TableViewDataSource {
        return TableViewDataSource(
            models: chores,
            reuseIdentifier: reuseIdentifier
        ) { (chore, cell) in
            if let cell = cell as? ChoreTableViewCell {
                cell.choreTitle.accessibilityIdentifier = chore.name

                cell.choreTitle.text = chore.name

                setImage(cell, choreName: chore.name)

                setMarquee(cell)

                fetchAssignee(cell, withUserId: chore.assignee)

                fetchAssigner(cell, withUserId: chore.creator)

                setDueDate(cell, withDate: chore.expiration)

                setImportanceIndicator(cell, withImportance: chore.points)
            }
        }
    }

    private static func setMarquee(_ cell: ChoreTableViewCell) {
        cell.choreTitle.type = .continuous
        cell.choreTitle.speed = .duration(8)
        cell.choreTitle.animationCurve = .easeInOut
        cell.choreTitle.fadeLength = 5.0
        cell.choreTitle.trailingBuffer = 14.0

        cell.assigneeName.type = .continuous
        cell.assigneeName.speed = .duration(8)
        cell.assigneeName.animationCurve = .easeInOut
        cell.assigneeName.fadeLength = 5.0
        cell.assigneeName.trailingBuffer = 14.0

        cell.assignerName.type = .continuous
        cell.assignerName.speed = .duration(8)
        cell.assignerName.animationCurve = .easeInOut
        cell.assignerName.fadeLength = 5.0
        cell.assignerName.trailingBuffer = 14.0
    }

    private static func setImage(_ cell: ChoreTableViewCell, choreName: String) {
        let circleAvatarImage = LetterAvatarMaker()
            .setCircle(true)
            .setUsername(choreName)
            .useSingleLetter(true)
            .build()

        cell.coreImage.image = circleAvatarImage
    }

    private static func fetchAssignee(_ cell: ChoreTableViewCell, withUserId assgineeId: String) {
        DispatchQueue.global(qos: .userInitiated).async {
            DatabaseManager.shared.retrieveUser(userId: assgineeId) { (result) in
                switch result {
                case .failure(let err):
                    log.error(err.localizedDescription)
                case .success(let user):
                    if user.id == DatabaseManager.shared.userId {
                        cell.assigneeName.text = user.name + " " + NSLocalizedString("(You)", comment: "")
                        cell.assigneeName.accessibilityIdentifier = user.name + " " + NSLocalizedString("(You)",
                                                                                                        comment: "")
                    } else {
                        cell.assigneeName.text = user.name
                        cell.assigneeName.accessibilityIdentifier = user.name
                    }
                }
            }
        }
    }

    private static func fetchAssigner(_ cell: ChoreTableViewCell, withUserId assignerId: String) {
        DispatchQueue.global(qos: .userInitiated).async {
            DatabaseManager.shared.retrieveUser(userId: assignerId) { (result) in
                switch result {
                case .failure(let err):
                    log.error(err.localizedDescription)
                case .success(let user):
                    if user.id == DatabaseManager.shared.userId {
                        cell.assignerName.text = user.name + " " + NSLocalizedString("(You)", comment: "")
                        cell.assignerName.accessibilityIdentifier = user.name + " " + NSLocalizedString("(You)",
                                                                                                        comment: "")
                    } else {
                        cell.assignerName.text = user.name
                        cell.assignerName.accessibilityIdentifier = user.name
                    }
                }
            }
        }
    }

    private static func setDueDate(_ cell: ChoreTableViewCell, withDate date: Date) {
        let formatter = DateFormatter()
        formatter.timeStyle = .none
        formatter.dateStyle = .short
        formatter.timeZone = TimeZone.current

        cell.dueDate.text = formatter.string(from: date)
        cell.dueDate.accessibilityIdentifier = formatter.string(from: date)
    }

    private static func setImportanceIndicator(_ cell: ChoreTableViewCell, withImportance importance: Importance) {
        switch importance {
        case .low:
            cell.importanceIndicator.image = UIImage(color: .systemGreen)
            cell.importanceIndicator.accessibilityIdentifier = "Green"
        case .medium:
            cell.importanceIndicator.image = UIImage(color: .systemYellow)
            cell.importanceIndicator.accessibilityIdentifier = "Yellow"
        case .high:
            cell.importanceIndicator.image = UIImage(color: .systemRed)
            cell.importanceIndicator.accessibilityIdentifier = "Red"
        }
    }

}
