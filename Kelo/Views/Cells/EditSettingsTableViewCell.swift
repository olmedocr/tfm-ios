//
//  EditSettingsTableViewCell.swift
//  Kelo
//
//  Created by Raul Olmedo on 7/6/21.
//

import UIKit

protocol EditSettingsCellDelegate: AnyObject {
    func didTapOnEditUser()
    func didTapOnEditGroup()
}

class EditSettingsTableViewCell: UITableViewCell {

    // MARK: - Properties
    weak var delegate: EditSettingsCellDelegate?

    // MARK: - IBActions
    @IBAction func didTapEditGroupButton(_ sender: Any) {
        delegate?.didTapOnEditGroup()
    }

    @IBAction func didTapEditUserButton(_ sender: Any) {
        delegate?.didTapOnEditUser()
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
