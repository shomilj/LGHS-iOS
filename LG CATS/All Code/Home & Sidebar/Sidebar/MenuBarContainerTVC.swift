//
//  SMenuBarContainerTVC.swift
//  Falcon
//
//  Created by Shomil Jain on 7/20/18.
//  Copyright © 2018 Avina Labs. All rights reserved.
//

import UIKit
import Iconic

class MenuBarContainerTVC: UITableViewController {

    @IBOutlet weak var homeCell: UITableViewCell!
    @IBOutlet weak var resourcesCell: UITableViewCell!
    @IBOutlet weak var toolsCell: UITableViewCell!
    
    @IBOutlet weak var inboxCell: UITableViewCell!
    @IBOutlet weak var newsCell: UITableViewCell!
    @IBOutlet weak var socialMediaCell: UITableViewCell!
    
    @IBOutlet weak var supportCell: UITableViewCell!
    @IBOutlet weak var termsCell: UITableViewCell!
    @IBOutlet weak var submitFeedbackCell: UITableViewCell!
    @IBOutlet weak var logoutCell: UITableViewCell!
    
    @IBOutlet weak var homeImageView: UIImageView!
    @IBOutlet weak var resourcesImageView: UIImageView!
    @IBOutlet weak var toolsImageView: UIImageView!
    @IBOutlet weak var inboxImageView: UIImageView!
    @IBOutlet weak var newsImageView: UIImageView!
    @IBOutlet weak var twitterImageView: UIImageView!
    @IBOutlet weak var supportImageView: UIImageView!
    @IBOutlet weak var termsImageView: UIImageView!
    @IBOutlet weak var logoutImageView: UIImageView!
    @IBOutlet weak var submitFeedbackImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let color = UIColor.darkGray
        let size = CGSize(width: 50, height: 50)
        
        homeImageView.image = FontAwesomeIcon.homeIcon.image(ofSize: size, color: color)
        resourcesImageView.image = FontAwesomeIcon.globeIcon.image(ofSize: size, color: color)
        toolsImageView.image = FontAwesomeIcon.wrenchIcon.image(ofSize: size, color: color)
        inboxImageView.image = FontAwesomeIcon.envelopeIcon.image(ofSize: size, color: color)
        newsImageView.image = FontAwesomeIcon.paperClipIcon.image(ofSize: size, color: color)
        twitterImageView.image = FontAwesomeIcon.twitterIcon.image(ofSize: size, color: color)
        supportImageView.image = FontAwesomeIcon.questionIcon.image(ofSize: size, color: color)
        termsImageView.image = FontAwesomeIcon.legalIcon.image(ofSize: size, color: color)
        submitFeedbackImageView.image = FontAwesomeIcon.editIcon.image(ofSize: size, color: color)
        logoutImageView.image = FontAwesomeIcon.keyIcon.image(ofSize: size, color: color)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) {
            if cell == homeCell {
                if UserUtil.userType == .student {
                    self.performSegue(withIdentifier: "toStudentHome", sender: self)
                } else if UserUtil.userType == .parent {
                    self.performSegue(withIdentifier: "toParentHome", sender: self)
                } else if UserUtil.userType == .teacher {
                    self.performSegue(withIdentifier: "toTeacherHome", sender: self)
                } else {
                    Log.e("Failed to determine user type!")
                }
            } else if cell == newsCell {
                Log.logSelection(toScreen: "School News")
                openLink(withURL: Links.getLink(fromKey: .newsFeed))
            } else if cell == socialMediaCell {
                Log.logSelection(toScreen: "Twitter Feed")
                openLink(withURL: Links.getLink(fromKey: .twitterFeed))
            } else if cell == termsCell {
                Log.logSelection(toScreen: "Terms and Conditions")
                openLink(withURL: Links.getLink(fromKey: .termsAndConditions))
            } else if cell == supportCell {
                Log.logSelection(toScreen: "Support")
                if let url = URL(string: "mailto:\(School.SUPPORT_EMAIL)") {
                    if #available(iOS 10.0, *) {
                        UIApplication.shared.open(url)
                    } else {
                        UIApplication.shared.openURL(url)
                    }
                } else {
                    showAlert(message: "Please send an email to \(School.SUPPORT_EMAIL) with your concerns.")
                }
            } else if cell == submitFeedbackCell {
                Log.logSelection(toScreen: "Feedback Form")
                openLink(withURL: Links.getLink(fromKey: .feedbackForm))
            } else if cell == logoutCell {
                if UserUtil.userType == .student || UserUtil.userType == .teacher {
                    UserUtil.logout()
                    dismiss(animated: true) {
                        if let vc = UIApplication.topViewController() as? STHomeVC {
                            vc.performSegue(withIdentifier: "logout", sender: vc.self)
                        }
                    }
                } else {
                    UserUtil.logout()
                    dismiss(animated: true) {
                        if let vc = UIApplication.topViewController() as? ParentHomeVC {
                            vc.performSegue(withIdentifier: "logout", sender: vc.self)
                        }
                    }
                }
                
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 2.0))
        view.backgroundColor = UIColor.groupTableViewBackground
        return view
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 1.0
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 1.0
    }

}
