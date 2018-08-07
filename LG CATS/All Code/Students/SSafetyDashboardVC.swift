//
//  SafetyDashboardVC.swift
//  Falcon
//
//  Created by Shomil Jain on 7/21/18.
//  Copyright © 2018 Avina Labs. All rights reserved.
//

import UIKit
import Iconic
import PopupDialog

class SSafetyDashboardVC: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tileAView: UIView!
    @IBOutlet weak var tileBView: UIView!
    @IBOutlet weak var tileCView: UIView!
    @IBOutlet weak var tileDView: UIView!
    
    @IBOutlet weak var tileAImageView: UIImageView!
    @IBOutlet weak var tileATitleLabel: UILabel!
    @IBOutlet weak var tileADetailLabel: UILabel!
    
    @IBOutlet weak var tileBImageView: UIImageView!
    @IBOutlet weak var tileBTitleLabel: UILabel!
    @IBOutlet weak var tileBDetailLabel: UILabel!
    
    @IBOutlet weak var tileCImageView: UIImageView!
    @IBOutlet weak var tileCTitleLabel: UILabel!
    @IBOutlet weak var tileCDetailLabel: UILabel!
    
    @IBOutlet weak var tileDImageView: UIImageView!
    @IBOutlet weak var tileDTitleLabel: UILabel!
    @IBOutlet weak var tileDDetailLabel: UILabel!
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "Safety Toolkit"
        
        [tileAView,
         tileBView,
         tileCView,
         tileDView].forEach { (view) in
            view?.backgroundColor = UIColor.groupTableViewBackground
            view?.layer.cornerRadius = 8
            view?.layer.masksToBounds = true
        }
        
        [tileATitleLabel, tileADetailLabel, tileBTitleLabel, tileBDetailLabel, tileCTitleLabel, tileCDetailLabel, tileDTitleLabel, tileDDetailLabel].forEach { (label) in
            label?.textColor = UIColor.primaryDark
        }
        
        tileAImageView.image = FontAwesomeIcon.phoneIcon.image(ofSize: CGSize(width: 50.0, height: 50.0), color: UIColor.primary)
        tileATitleLabel.text = "CALL SAFERIDES"
        tileADetailLabel.text = "Safe and free rides home on Friday nights."
        
        tileBImageView.image = FontAwesomeIcon.editIcon.image(ofSize: CGSize(width: 50.0, height: 50.0), color: UIColor.primary)
        tileBTitleLabel.text = "SUBMIT A TIP"
        tileBDetailLabel.text = "Report concerns safely & anonymously."
        
        tileCImageView.image = FontAwesomeIcon.uniF2C1Icon.image(ofSize: CGSize(width: 50.0, height: 50.0), color: UIColor.primary)
        tileCTitleLabel.text = "LG POLICE DEPT."
        tileCDetailLabel.text = "Reach out to the local police department."
        
        tileDImageView.image = FontAwesomeIcon.exclamationSignIcon.image(ofSize: CGSize(width: 50.0, height: 50.0), color: UIColor.white)
        tileDTitleLabel.text = "CALL 911"
        tileDTitleLabel.textColor = UIColor.white
        tileDView.backgroundColor = UIColor.primary
        tileDDetailLabel.text = "Tap to call 911 in an emergency."
        tileDDetailLabel.textColor = UIColor.white
        
        tileAView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.callSaferidesTapped(_:))))
        tileBView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.submitTipTapped(_:))))
        tileCView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.lgpdTapped(_:))))
        tileDView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.call911Tapped(_:))))
        
        setupTableView()
    }
    
    func setupTableView() {
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.tableView.estimatedRowHeight = 56
        tableData = [
            CellObject(title: "Crisis Text Line",
                       icon: FontAwesomeIcon.certificateIcon,
                       selector: #selector(textLineTapped)),
            
            CellObject(title: "Additional Hotlines",
                       icon: FontAwesomeIcon.exclamationIcon,
                       selector: #selector(additionalHotlinesTapped)),
            
            CellObject(title: "CASSY Referral Form", icon: FontAwesomeIcon.warningSignIcon, selector: #selector(cassyTapped)),
            
        ]
        self.tableView.reloadData()
    }
    
    @objc func callSaferidesTapped(_ sender: UITapGestureRecognizer) {
        Log.logSelection(toScreen: "Safety: Calling SafeRides")

        let title = "CALL SAFERIDES"
        let message = "SafeRides provide free, confidential, non-judgmental, safe rides home to high school students who find themselves in unsafe situations.\n\n**SafeRides operates during the school year on Friday nights and during special events like dances.**"
        
        let popup = PopupDialog(title: title, message: message)
        
        let buttonOne = DestructiveButton(title: "Cancel") {}
        
        // This button will not the dismiss the dialog
        let buttonTwo = DefaultButton(title: "CALL SAFERIDES", dismissOnTap: true) {
            if let url = URL(string: "tel://18885507433"), UIApplication.shared.canOpenURL(url) {
                if #available(iOS 10, *) {
                    UIApplication.shared.open(url)
                } else {
                    UIApplication.shared.openURL(url)
                }
            }
        }

        popup.addButtons([buttonTwo, buttonOne])
        self.present(popup, animated: true, completion: nil)
    }
    
    @objc func submitTipTapped(_ sender: UITapGestureRecognizer) {
        Log.logSelection(toScreen: "Safety: Submitting Tip")
        openLink(withURL: Links.getLink(fromKey: .wetip))
    }
    
    @objc func lgpdTapped(_ sender: UITapGestureRecognizer) {
        Log.logSelection(toScreen: "Safety: Calling LGPD")
        let title = "LOS GATOS POLICE DEPARTMENT"
        let message = "For urgent concerns, please call the 24-hour hotline.\n\nTo file a police report, please visit the website."
        
        let popup = PopupDialog(title: title, message: message)
        
        let cancel = DestructiveButton(title: "Cancel") {}
        
        let website = DefaultButton(title: "Visit the Website") {
            self.openLink(withURL: Links.getLink(fromKey: .lgpdWebsite))
        }
        
        let call = DefaultButton(title: "Call the Hotline") {
            if let url = URL(string: "tel://14083548600"), UIApplication.shared.canOpenURL(url) {
                if #available(iOS 10, *) {
                    UIApplication.shared.open(url)
                } else {
                    UIApplication.shared.openURL(url)
                }
            }
        }
        
        popup.addButtons([call, website, cancel])
        self.present(popup, animated: true, completion: nil)

    }
    
    @objc func cassyTapped() {
        Log.logSelection(toScreen: "Safety: Contacting CASSY")
        openLink(withURL: Links.getLink(fromKey: .cassyForm))
    }


    struct CellObject {
        var title: String!
        var icon: FontAwesomeIcon!
        var selector: Selector?
    }
    
    var tableData: [CellObject]!
    
    @objc func additionalHotlinesTapped() {
        openLink(withURL: Links.getLink(fromKey: .additionalHotlines))
    }
    
    @objc func call911Tapped(_ sender: UITapGestureRecognizer) {
        Log.logSelection(toScreen: "Safety: Calling 911")
        let title = "CALL 911"
        let message = "Are you sure you want to call 911?"
        
        let popup = PopupDialog(title: title, message: message)
        
        let buttonOne = DestructiveButton(title: "Call 911") {
            if let url = URL(string: "tel://911"), UIApplication.shared.canOpenURL(url) {
                if #available(iOS 10, *) {
                    UIApplication.shared.open(url)
                } else {
                    UIApplication.shared.openURL(url)
                }
            }
        }
        
        let buttonTwo = DefaultButton(title: "Cancel") {}
        
        popup.addButtons([buttonOne, buttonTwo])
        self.present(popup, animated: true, completion: nil)
    }
    
    @objc func textLineTapped() {
        Log.logSelection(toScreen: "Safety: Crisis Text Line")
        let title = "CRISIS TEXT LINE"
        let message = """
HOW IT WORKS:

Text BAY to 741741 from anywhere, anytime, about any type of crisis (i.e. stress, relationships, suicide, etc.)

A live, trained Crisis Counselor receives the text and responds, all from our secure online platform.

The volunteer Crisis Counselor will help you move from a hot moment to a cool moment.
"""
        
        let popup = PopupDialog(title: title, message: message)
        
        let buttonOne = DefaultButton(title: "Connect to Crisis Text Line") {
            UIApplication.shared.open(URL(string: "sms:741741")!, options: [:], completionHandler: nil)
        }
        
        let buttonTwo = DestructiveButton(title: "Cancel") {}
        
        popup.addButtons([buttonOne, buttonTwo])
        self.present(popup, animated: true, completion: nil)

    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 52.0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "cell") as? HomeCell
        let obj = tableData[indexPath.row]
        cell?.mainTextLabel.text = obj.title
        cell?.iconImageView.image = obj.icon.image(ofSize: CGSize(width: 50.0, height: 50.0), color: UIColor.primary)
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableView.deselectRow(at: indexPath, animated: true)
        let item = tableData[indexPath.row]
        performSelector(onMainThread: item.selector!, with: nil, waitUntilDone: false)
    }

}
