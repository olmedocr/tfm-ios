//
//  UserTableViewCell.swift
//  Kelo
//
//  Created by Raul Olmedo on 6/5/21.
//

import UIKit
import MarqueeLabel

class UserTableViewCell: UITableViewCell {

    // MARK: - IBOutlets
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var userNameLabel: MarqueeLabel!
    @IBOutlet weak var adminLabel: UILabel!
    @IBOutlet weak var pointsLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
