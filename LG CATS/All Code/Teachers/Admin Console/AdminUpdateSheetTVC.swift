//
//  AdminUpdateSheetTVC.swift
//  Falcon
//
//  Created by Shomil Jain on 7/24/18.
//  Copyright © 2018 Avina Labs. All rights reserved.
//

import UIKit
import Iconic
import PopupDialog

class AdminUpdateSheetTVC: UITableViewController {

    @IBOutlet weak var openTemplateImageView: UIImageView!
    @IBOutlet weak var viewCurrentDataImageView: UIImageView!
    @IBOutlet weak var uploadNewDataImageView: UIImageView!
    
    @IBOutlet weak var openTemplateCell: UITableViewCell!
    @IBOutlet weak var viewCurrentCell: UITableViewCell!
    @IBOutlet weak var uploadNewCell: UITableViewCell!
    
    var resourceType: AdminConsoleTVC.ResourceType!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if resourceType == .clubList {
            self.navigationItem.title = "Club List"
        } else if resourceType == .dayCalendar {
            self.navigationItem.title = "Day Calendar"
        } else if resourceType == .studentRoster {
            self.navigationItem.title = "Student Roster"
        } else if resourceType == .teacherRoster {
            self.navigationItem.title = "Teacher Roster"
        }
        openTemplateImageView.image = FontAwesomeIcon.externalLinkIcon.image(ofSize: CGSize(width: 50, height: 50), color: UIColor.primary)
        viewCurrentDataImageView.image = FontAwesomeIcon.fileTextAltIcon.image(ofSize: CGSize(width: 50, height: 50), color: UIColor.primary)
        uploadNewDataImageView.image = FontAwesomeIcon.cloudUploadIcon.image(ofSize: CGSize(width: 50, height: 50), color: UIColor.primary)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let cell = self.tableView.cellForRow(at: indexPath)
        if cell == openTemplateCell {
            openTemplate()
        } else if cell == viewCurrentCell {
            goToCurrentData()
        } else if cell == uploadNewCell {
            self.performSegue(withIdentifier: "upload", sender: self)
        }
    }
    
    func openTemplate() {
        var link: URL?
        var message: String?
        if resourceType == .clubList {
            link = Links.getLink(fromKey: .adminClubListTemplate)
            message =
            """
            This spreadsheet is formatted as follows:
            
            Column 1 = Club Name
            Column 2 = Club President Name
            Column 3 = Club Vice President Name
            Column 4 = Club Advisor
            Column 5 = Club or President Email
            Column 6 = Meeting Day/Time
            Column 7 = Meeting Location
            Column 8 = 2-3 Sentence Club Description/Overview
            """
        } else if resourceType == .dayCalendar {
            link = Links.getLink(fromKey: .adminDayCalendarTemplate)
            message =
            """
            This spreadsheet is formatted as follows:
            
            Column 1 = Type of Day
            Column 2 = "Today" Description
            Column 3 = "Tomorrow" Description
            Column 4 = Comma-Separated Dates (MM/DD/YYYY)
            """
        } else if resourceType == .studentRoster {
            link = Links.getLink(fromKey: .adminStudentRosterTemplate)
            message =
            """
            This spreadsheet is formatted as follows:
            
            Column 1 = Student ID
            Column 2 = First Name
            Column 3 = Last Name
            Column 4 = Email (ending in \(School.DOMAIN_STUDENT))
            Column 5 = Graduation Year/Class
            """
        } else if resourceType == .teacherRoster {
            link = Links.getLink(fromKey: .adminTeacherRosterTemplate)
            message =
            """
            This spreadsheet is formatted as follows:
            
            Column 1 = First Name
            Column 2 = Last Name
            Column 3 = Email (ending in \(School.DOMAIN_TEACHER))
            Column 4 = Admin Privileges ("YES" or "NO")
            """
        }
        
        let popup = PopupDialog(title: "Template Information", message: message)
        let buttonOne = CancelButton(title: "Dismiss") {}
        let buttonTwo = DefaultButton(title: "Share Template Link") {
            self.shareLink(link: link)
        }
        let buttonThree = DefaultButton(title: "Make a Copy of the Template") {
            self.openLink(withURL: Links.getLink(fromKey: .adminTeacherRosterTemplate))
        }
        popup.addButtons([buttonThree, buttonTwo, buttonOne])
        self.present(popup, animated: true, completion: nil)
    }
        
    func goToCurrentData() {
        if resourceType == .studentRoster {
            self.performSegue(withIdentifier: "toStudentList", sender: self)
        } else {
            showAlert(message: "This feature is not currently available. In order to update specific data, you will need to upload a new spreadsheet and overwrite all existing data.")
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let id = segue.identifier, id == "upload", let dest = segue.destination as? AdminEnterLinkVC {
            dest.selectedResource = self.resourceType
        }
    }

}
