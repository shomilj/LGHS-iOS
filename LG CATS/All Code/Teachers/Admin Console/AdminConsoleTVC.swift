//
//  AdminConsoleTVC.swift
//  Falcon
//
//  Created by Shomil Jain on 7/24/18.
//  Copyright © 2018 Avina Labs. All rights reserved.
//

import UIKit
import Iconic

class AdminConsoleTVC: UITableViewController {

    @IBOutlet weak var surveysImageView: UIImageView!
    @IBOutlet weak var dayTypeImageView: UIImageView!
    @IBOutlet weak var studentRosterImageView: UIImageView!
    @IBOutlet weak var teacherRosterImageView: UIImageView!
    @IBOutlet weak var clubsImageView: UIImageView!
    
    @IBOutlet weak var dayCalCell: UITableViewCell!
    @IBOutlet weak var studentRosterCell: UITableViewCell!
    @IBOutlet weak var teacherRosterCell: UITableViewCell!
    @IBOutlet weak var clubsCell: UITableViewCell!

    enum ResourceType: String {
        case dayCalendar
        case studentRoster
        case teacherRoster
        case clubList
    }
    
    var selectedResource: ResourceType!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        surveysImageView.image = FontAwesomeIcon._481Icon.image(ofSize: CGSize(width: 50, height: 50), color: UIColor.primary)
        dayTypeImageView.image = FontAwesomeIcon.calendarIcon.image(ofSize: CGSize(width: 50, height: 50), color: UIColor.primary)
        studentRosterImageView.image = FontAwesomeIcon.sortByAlphabetIcon.image(ofSize: CGSize(width: 50, height: 50), color: UIColor.primary)
        teacherRosterImageView.image = FontAwesomeIcon.uniF2BAIcon.image(ofSize: CGSize(width: 50, height: 50), color: UIColor.primary)
        clubsImageView.image = FontAwesomeIcon._592Icon.image(ofSize: CGSize(width: 50, height: 50), color: UIColor.primary)
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = self.tableView.cellForRow(at: indexPath)
        if cell == dayCalCell {
            selectedResource = .dayCalendar
            self.performSegue(withIdentifier: "updateSheet", sender: self)
        } else if cell == studentRosterCell {
            selectedResource = .studentRoster
            self.performSegue(withIdentifier: "updateSheet", sender: self)
        } else if cell == teacherRosterCell {
            selectedResource = .teacherRoster
            self.performSegue(withIdentifier: "updateSheet", sender: self)
        } else if cell == clubsCell {
            selectedResource = .clubList
            self.performSegue(withIdentifier: "updateSheet", sender: self)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let id = segue.identifier, id == "updateSheet", let next = segue.destination as? AdminUpdateSheetTVC {
            next.resourceType = selectedResource
        }
    }
}
