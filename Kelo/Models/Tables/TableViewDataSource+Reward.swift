//
//  TableViewDataSource+Reward.swift
//  Kelo
//
//  Created by Raul Olmedo on 29/5/21.
//

import UIKit
import LetterAvatarKit

extension TableViewDataSource where Model == Reward {

    static func make(for reward: Reward,
                     reuseIdentifier: String = "rewardTableViewCell") -> TableViewDataSource {
        return TableViewDataSource(
            models: [reward],
            reuseIdentifier: reuseIdentifier
        ) { (reward, cell) in
            if let cell = cell as? RewardTableViewCell {

                let circleAvatarImage = LetterAvatarMaker()
                    .setCircle(true)
                    .setUsername(reward.name)
                    .useSingleLetter(true)
                    .build()

                cell.rewardImage.image = circleAvatarImage

                cell.rewardName.text = reward.name
                cell.rewardFrequency.text = reward.frequency?.description

                setMarquee(cell)

            }
        }
    }

    private static func setMarquee(_ cell: RewardTableViewCell) {
        cell.rewardName.type = .continuous
        cell.rewardName.speed = .duration(8)
        cell.rewardName.animationCurve = .easeInOut
        cell.rewardName.fadeLength = 5.0
        cell.rewardName.trailingBuffer = 14.0
    }

}
