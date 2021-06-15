//
//  ShareGroupCodeViewController.swift
//  Kelo
//
//  Created by Raul Olmedo on 10/5/21.
//

import UIKit

class ShareGroupCodeViewController: UIViewController {

    // MARK: - Properties
    var groupId: String?

    // MARK: - IBOutlets
    @IBOutlet weak var groupCodeLabel: UILabel!

    // MARK: - IBActions
    @IBAction func didTapOnShare(_ sender: Any) {
        if let groupId = groupId {
            log.info("Sharing group code")
            let textToShare = [ "Join my Kelo group by following this link! \n" +
                                    "https://kelo-64c5c.web.app/group/" + groupId ]
            let activityViewController = UIActivityViewController(activityItems: textToShare,
                                                                  applicationActivities: nil)

            activityViewController.excludedActivityTypes = [ UIActivity.ActivityType.airDrop,
                                                             UIActivity.ActivityType.postToFacebook ]

            self.present(activityViewController, animated: true, completion: nil)

        } else {
            log.error("Attempting to share a nil group code")
        }

    }

    // MARK: - View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        if let groupId = DatabaseManager.shared.groupId {
            log.info("Showing group id")
            groupCodeLabel.text = groupId
            self.groupId = groupId
        } else {
            log.error("No group code could be shown")
            groupCodeLabel.text = "nil"
        }
    }

}
