//
//  StudentHomeVC.swift
//  Falcon
//
//  Created by Shomil Jain on 6/21/18.
//  Copyright © 2018 Avina Labs. All rights reserved.
//

import UIKit
import SideMenu
import Iconic
import SkeletonView

class STHomeVC: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var weatherButton: UIButton!
    @IBOutlet weak var campusMapButton: UIButton!
    @IBOutlet weak var dayTypeButton: UIButton!
    @IBOutlet weak var greetingLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var topView: UIView!

    var tableData: [HomeCellModel] = []
    
    var teacherTableData = [
        HomeCellModel(main: "Daily Announcements",
                      subtitle: "Access the day's morning announcements.",
                      icon: FontAwesomeIcon.uniF2CEIcon,
                      segue: "toAnnouncements"),
        HomeCellModel(main: "Canvas",
                      subtitle: "Quick access to the Canvas portal.",
                      icon: FontAwesomeIcon.spinnerIcon,
                      link: Links.getLink(fromKey: .canvas)!.absoluteString),
        HomeCellModel(main: "Aeries",
                      subtitle: "Quick access to the Aeries portal.",
                      icon: FontAwesomeIcon.pencilIcon,
                      link: Links.getLink(fromKey: .aeries)!.absoluteString),
        HomeCellModel(main: "Calendar",
                      subtitle: "Athletics, college visits, and events @ LGHS.",
                      icon: FontAwesomeIcon.calendarIcon,
                      segue: "toCalendar"),
        HomeCellModel(main: "Clubs",
                      subtitle: "Discover a passion from 50+ on-campus clubs!",
                      icon: FontAwesomeIcon.searchIcon,
                      segue: "toClubs"),
        HomeCellModel(main: "Event Manager",
                      subtitle: "Check students into events.",
                      icon: FontAwesomeIcon.ticketIcon,
                      segue: "toCheckInTool")]
    
    let studentTableData =
        [HomeCellModel(main: "Student ID",
                       subtitle: "Check out books, check into events, and more.",
                       icon: FontAwesomeIcon.uniF2C1Icon,
                       segue: "toStudentId"),
         HomeCellModel(main: "Daily Announcements",
                       subtitle: "Access the day's morning announcements.",
                       icon: FontAwesomeIcon.uniF2CEIcon,
                       segue: "toAnnouncements"),
         HomeCellModel(main: "Grades",
                       subtitle: "Quick access to the Canvas portal.",
                       icon: FontAwesomeIcon.pencilIcon,
                       link: Links.getLink(fromKey: .canvas)!.absoluteString),
         HomeCellModel(main: "Calendar",
                       subtitle: "Athletics, college visits, and events @ LGHS.",
                       icon: FontAwesomeIcon.calendarIcon,
                       segue: "toCalendar"),
         HomeCellModel(main: "Clubs",
                       subtitle: "Discover a passion from 50+ on-campus clubs!",
                       icon: FontAwesomeIcon.searchIcon,
                       segue: "toClubs"),
         HomeCellModel(main: "Safety Toolkit",
                       subtitle: "Call SafeRides, access hotlines, report tips.",
                       icon: FontAwesomeIcon.warningSignIcon,
                       segue: "toSafety")
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Configure menu bar icon
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: FontAwesomeIcon.listIcon.image(ofSize: CGSize(width: 20, height: 20), color: UIColor.primary), style: .plain, target: self, action: #selector(menuTapped))

        // Configure attributes of home screen...
        self.nameLabel.text = STHomeModel.shared.name
        self.weatherButton.setTitle(STHomeModel.shared.weather, for: .normal)
        self.dayTypeButton.setTitle(STHomeModel.shared.dayType, for: .normal)
        self.greetingLabel.text = STHomeModel.shared.greeting
        self.title = STHomeModel.shared.date
        
        self.dayTypeButton.contentHorizontalAlignment = .left
        self.campusMapButton.contentHorizontalAlignment = .left
        self.weatherButton.contentHorizontalAlignment = .left
        
        self.topView.backgroundColor = UIColor.primary

        HomeModel.setupMenu(storyboard: storyboard!, menuViewId: "MenuNavigationController", width: view.frame.width * (0.80), navigationController: self.navigationController!)
        
        if UserUtil.userType == .student {
            tableData = studentTableData
        } else if UserUtil.userType == .teacher {
            tableData = teacherTableData
        } else {
            forceLogoutWithError()
        }
        
        self.tableView.dataSource = self
        self.tableView.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        tableView.layer.cornerRadius = 8
        if #available(iOS 11.0, *) {
            tableView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        } else {
            // Fallback on earlier versions
        }
        Log.m()
    }
    
    @objc func menuTapped() {
        let controller = SideMenuManager.default.menuLeftNavigationController!
        present(controller, animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let backItem = UIBarButtonItem()
        backItem.title = "Back"
        backItem.setTitleTextAttributes([NSAttributedStringKey.foregroundColor : UIColor.white, NSAttributedStringKey.font: UIFont(name: "Avenir-Medium", size: 17.0)!], for: .normal)
        navigationItem.backBarButtonItem = backItem // This will show in the next view controller being pushed
    }
    
    @IBAction func dayCalendarTapped(_ sender: Any) {
        Log.logSelection(toScreen: "Day Calendar")
        openLink(withURL: Links.getLink(fromKey: .dayCalendar))
    }
    @IBAction func weatherTapped(_ sender: Any) {
        Log.logSelection(toScreen: "Weather")
        openLink(withURL: Links.getLink(fromKey: .weather))
    }
    @IBAction func mapTapped(_ sender: Any) {
        Log.logSelection(toScreen: "Campus Map")
        openLink(withURL: Links.getLink(fromKey: .campusMap))
    }
    
    // Table View Delegate
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! HomeCell
        let model = tableData[indexPath.row]
        cell.mainTextLabel.text = model.mainText
        cell.subtitleTextLabel.text = model.subtitleText
        cell.iconImageView.image = model.icon.image(ofSize: CGSize(width: 100, height: 100), color: UIColor.primary)
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableData.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableView.deselectRow(at: indexPath, animated: true)
        Log.logSelection(toScreen: tableData[indexPath.row].mainText)
        if let segue = tableData[indexPath.row].segue {
            self.performSegue(withIdentifier: segue, sender: self)
        } else if let link = tableData[indexPath.row].link, let url = URL(string: link) {
            openLink(withURL: url)
        } else {
            Log.e("Failed to find a link or segue identifier for this SHRCellModel!")
            showAlert(message: "This feature is not currently available. Please try again later.")
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70.0
    }
    
}
