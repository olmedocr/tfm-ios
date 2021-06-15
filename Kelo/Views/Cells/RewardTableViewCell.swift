//
//  RewardTableViewCell.swift
//  Kelo
//
//  Created by Raul Olmedo on 26/5/21.
//

import UIKit
import MarqueeLabel

class RewardTableViewCell: UITableViewCell {

    // MARK: @IBOutlets
    @IBOutlet weak var rewardName: MarqueeLabel!
    @IBOutlet weak var rewardFrequency: UILabel!
    @IBOutlet weak var rewardImage: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
