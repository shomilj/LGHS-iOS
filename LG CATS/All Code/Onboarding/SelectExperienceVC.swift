//
//  SelectExperienceVC.swift
//  Falcon
//
//  Created by Shomil Jain on 6/18/18.
//  Copyright © 2018 Avina Labs. All rights reserved.
//

import UIKit
import Firebase

class SelectExperienceVC: UIViewController {

    @IBOutlet weak var studentButton: UIButton!
    @IBOutlet weak var teacherButton: UIButton!
    @IBOutlet weak var parentButton: UIButton!
    @IBOutlet weak var visitorButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let buttons = [studentButton, teacherButton, parentButton, visitorButton]
        for button in buttons {
            button?.layer.cornerRadius = 8
            button?.backgroundColor = UIColor.primary
        }
    }
    
    @IBAction func tappedParent(_ sender: Any) {
        LoadingOverlay.shared.showOverlay(self.view)
        PHomeModel.updateShared { (completion) in
            DispatchQueue.main.async {
                if completion == true {
                    let isRegisteredForRemoteNotifications = UIApplication.shared.isRegisteredForRemoteNotifications
                    if isRegisteredForRemoteNotifications {
                        Log.i("This user is already registered for push notifications!")
                        self.moveOn()
                    } else {
                        self.requestNotificationPermission()
                    }
                } else {
                    LoadingOverlay.shared.hideOverlayView()
                    self.showError(message: "A network error occurred. Please try again later or check your network connection.")
                }
            }
        }
    }
    
    func requestNotificationPermission() {
        showAlert(message: "When prompted, please allow notifications in order to receive school-wide alerts regarding events, emergencies, and more.", title: "Notifications", image: nil) {
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            appDelegate.askNotificationsPermissions()
            self.moveOn()
        }
    }
    
    func moveOn() {
        UserUtil.setUserType(type: .parent)
        Auth.auth().signInAnonymously { (result, error) in
            if error == nil {
                self.performSegue(withIdentifier: "toParentHome", sender: self)
            } else {
                LoadingOverlay.shared.hideOverlayView()
                self.showError(message: "An authentication error occurred. Please try again later or contact support [\(error!.localizedDescription)].", title: "Authentication Error", completion: nil)
            }
        }
    }

}
