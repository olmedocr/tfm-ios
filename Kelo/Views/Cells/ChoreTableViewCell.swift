//
//  ChoreTableViewCell.swift
//  Kelo
//
//  Created by Raul Olmedo on 27/4/21.
//

import UIKit
import MarqueeLabel

class ChoreTableViewCell: UITableViewCell {

    // MARK: IBOutlets
    @IBOutlet weak var choreTitle: MarqueeLabel!
    @IBOutlet weak var assigneeName: UILabel!
    @IBOutlet weak var dueDate: UILabel!
    @IBOutlet weak var importanceIndicator: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
