//
//  DailyAnnouncementsDetailVC.swift
//  Falcon
//
//  Created by Shomil Jain on 6/22/18.
//  Copyright © 2018 Avina Labs. All rights reserved.
//

import UIKit

class DailyAnnouncementsDetailVC: UIViewController {

    var announcement: DAAnnouncement!
    
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var publisherLabel: UILabel!
    @IBOutlet weak var pubDateLabel: UILabel!
    
    @IBOutlet weak var contentTextView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dateLabel.text = announcement.date.uppercased()
        publisherLabel.text = School.SchoolName.long.rawValue.uppercased()
        contentTextView.text = announcement.content
    }

}
