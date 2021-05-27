//
//  TableViewDataSource.swift
//  Kelo
//
//  Created by Raul Olmedo on 26/5/21.
//

import UIKit
import LetterAvatarKit

class TableViewDataSource<Model>: NSObject, UITableViewDataSource {
    typealias CellConfigurator = (Model, UITableViewCell) -> Void

    var models: [Model]

    private let reuseIdentifier: String
    private let cellConfigurator: CellConfigurator

    init(models: [Model],
         reuseIdentifier: String,
         cellConfigurator: @escaping CellConfigurator) {
        self.models = models
        self.reuseIdentifier = reuseIdentifier
        self.cellConfigurator = cellConfigurator
    }

    // MARK: - UITableView data source
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return models.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = models[indexPath.row]
        let cell = tableView.dequeueReusableCell(
            withIdentifier: reuseIdentifier,
            for: indexPath
        )

        cellConfigurator(model, cell)

        return cell
    }
}

// MARK: - Currency
extension TableViewDataSource where Model == Currency {
    static func make(for currencies: [Currency],
                     reuseIdentifier: String = "currencyTableViewCell") -> TableViewDataSource {
        return TableViewDataSource(
            models: currencies,
            reuseIdentifier: reuseIdentifier
        ) { (currency, cell) in
            if let cell = cell as? CurrencyTableViewCell {
                cell.currencyName.text = currency.name
                cell.flagImage.image = currency.flag
            }
        }
    }
}

// MARK: - User
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
                    .setBorderWidth(1.0)
                    .useSingleLetter(true)
                    .build()

                cell.userImage.image = circleAvatarImage

                if user.id == DatabaseManager.shared.userId {
                    cell.userNameLabel.text = user.name + " (You)"
                } else {
                    cell.userNameLabel.text = user.name
                }
            }
        }
    }
}

// MARK: - Reward
extension TableViewDataSource where Model == Reward {
    static func make(for reward: Reward,
                     reuseIdentifier: String = "rewardTableViewCell") -> TableViewDataSource {
        return TableViewDataSource(
            models: [reward],
            reuseIdentifier: reuseIdentifier
        ) { (reward, cell) in
            if let cell = cell as? RewardTableViewCell {
                cell.rewardName.text = reward.name
            }
        }
    }
}

// MARK: - Chore
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

                setDueDate(cell, withDate: chore.expiration)

                setImportanceIndicator(cell, withPoints: chore.points)
            }
        }
    }

    private static func setMarquee(_ cell: ChoreTableViewCell) {
        cell.choreTitle.type = .continuous
        cell.choreTitle.speed = .duration(8)
        cell.choreTitle.animationCurve = .easeInOut
        cell.choreTitle.fadeLength = 5.0
        cell.choreTitle.trailingBuffer = 14.0
    }

    private static func setImage(_ cell: ChoreTableViewCell, choreName: String) {
        let circleAvatarImage = LetterAvatarMaker()
            .setCircle(true)
            .setUsername(choreName)
            .setBorderWidth(1.0)
            .build()

        cell.imageView?.image = UIImage(cgImage: (circleAvatarImage?.cgImage)!)
        cell.imageView?.frame = CGRect(x: 0, y: 0, width: 100, height: 200)

    }

    private static func fetchAssignee(_ cell: ChoreTableViewCell, withUserId assgineeId: String) {
        DispatchQueue.global(qos: .userInitiated).async {
            DatabaseManager.shared.retrieveUser(userId: assgineeId) { (result) in
                switch result {
                case .failure(let err):
                    log.error(err.localizedDescription)
                case .success(let user):
                    if user.id == DatabaseManager.shared.userId {
                        cell.assigneeName.text = user.name + " (You)"
                        cell.assigneeName.accessibilityIdentifier = user.name + " (You)"
                    } else {
                        cell.assigneeName.text = user.name
                        cell.assigneeName.accessibilityIdentifier = user.name
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

    private static func setImportanceIndicator(_ cell: ChoreTableViewCell, withPoints points: Int) {
        switch points {
        case Chore.Importance.low.rawValue:
            cell.importanceIndicator.image = UIImage(color: .systemGreen)
            cell.importanceIndicator.accessibilityIdentifier = "Green"
        case Chore.Importance.medium.rawValue:
            cell.importanceIndicator.image = UIImage(color: .systemYellow)
            cell.importanceIndicator.accessibilityIdentifier = "Yellow"
        case Chore.Importance.high.rawValue:
            cell.importanceIndicator.image = UIImage(color: .systemRed)
            cell.importanceIndicator.accessibilityIdentifier = "Red"
        default:
            log.warning("Unknown importance value")
        }
    }
}
