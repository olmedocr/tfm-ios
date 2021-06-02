//
//  TableViewDataSource+Reward.swift
//  Kelo
//
//  Created by Raul Olmedo on 29/5/21.
//

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
