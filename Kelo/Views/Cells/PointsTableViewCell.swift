//
//  PointsTableViewCell.swift
//  Kelo
//
//  Created by Raul Olmedo on 26/5/21.
//

import UIKit

class PointsTableViewCell: UITableViewCell {

    // MARK: - IBOutlets
    @IBOutlet weak var pointsLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
