//
//  SMenuBarMainVC.swift
//  Falcon
//
//  Created by Shomil Jain on 7/20/18.
//  Copyright © 2018 Avina Labs. All rights reserved.
//

import UIKit

class MenuBarMainVC: UIViewController {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var classLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if UserUtil.userType == .student {
            if let student = UserUtil.getCurrentStudent() {
                self.nameLabel.text = student.fullName
                self.classLabel.text = "Class of \(student.year!)"
                self.emailLabel.text = student.email
            } else {
                Log.e("Student user, but no profile!")
                forceLogoutWithError()
            }
        } else if UserUtil.userType == .parent {
            self.nameLabel.text = "LG CATS"
            self.classLabel.text = "Parent"
            self.emailLabel.text = DayType.getCurrentSchoolYear()
        } else if UserUtil.userType == .teacher {
            if let teacher = UserUtil.getCurrentTeacher() {
                self.nameLabel.text = teacher.fullName
                self.classLabel.text = "Teacher"
                self.emailLabel.text = teacher.email
            } else {
                forceLogoutWithError()
            }
        } else {
            forceLogoutWithError()
        }
        
        // Hide the navigation bar on the this view controller
        self.view.backgroundColor = UIColor.primary
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }

}
