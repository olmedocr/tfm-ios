//
//  DangerSettingsTableViewCell.swift
//  Kelo
//
//  Created by Raul Olmedo on 26/5/21.
//

import UIKit

protocol DangerSettingsCellDelegate: AnyObject {
    func didTapOnDeleteGroup()
    func didTapOnLeaveGroup()
}

class DangerSettingsTableViewCell: UITableViewCell {

    // MARK: - Properties
    weak var delegate: DangerSettingsCellDelegate?

    // MARK: - IBActions
    @IBAction func didTapDeleteButton(_ sender: Any) {
        delegate?.didTapOnDeleteGroup()
    }

    @IBAction func didTapLeaveButton(_ sender: Any) {
        delegate?.didTapOnLeaveGroup()
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
