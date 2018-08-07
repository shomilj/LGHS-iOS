//
//  ClubDetailVC.swift
//  Falcon
//
//  Created by Shomil Jain on 7/22/18.
//  Copyright © 2018 Avina Labs. All rights reserved.
//

import UIKit
import MessageUI

class ClubDetailVC: UIViewController, MFMailComposeViewControllerDelegate {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var presidentLabel: UILabel!
    @IBOutlet weak var vicePresidentLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var meetingTimeLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var contactLabel: UILabel!
    
    var club: Club!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        titleLabel.text = club.name
        presidentLabel.text = club.president
        vicePresidentLabel.text = club.vicePresident
        descriptionLabel.text = club.description
        meetingTimeLabel.text = club.time
        locationLabel.text = club.location
        contactLabel.text = club.contactInfo
    }
    
    @IBAction func contactTapped(_ sender: Any) {
        sendEmail()
    }
    
    func sendEmail() {
        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            mail.setToRecipients([club.contactInfo])
            present(mail, animated: true)
        } else {
            showError(message: "This device is not able to send email.")
        }
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true)
    }

}
