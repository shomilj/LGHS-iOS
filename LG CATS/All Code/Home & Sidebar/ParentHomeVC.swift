//
//  ParentHomeVC.swift
//  Falcon
//
//  Created by Shomil Jain on 7/23/18.
//  Copyright © 2018 Avina Labs. All rights reserved.
//

import UIKit
import SideMenu
import Iconic
import SkeletonView

class ParentHomeVC: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    
    // Items we need:
    @IBOutlet weak var weatherButton: UIButton!
    @IBOutlet weak var campusMapButton: UIButton!
    @IBOutlet weak var dayTypeButton: UIButton!
    @IBOutlet weak var greetingLabel: UILabel!

    @IBOutlet weak var topView: UIView!
    
    let tableData: [HomeCellModel] = [
        HomeCellModel(main: "Daily Announcements",
                      subtitle: "Read the latest from LGHS.",
                      icon: FontAwesomeIcon.uniF2CEIcon,
                      segue: "toAnnouncements"),
        HomeCellModel(main: "Grades",
                      subtitle: "View student grades in Canvas.",
                      icon: FontAwesomeIcon.pencilIcon,
                      link: Links.getLink(fromKey: .canvas)!.absoluteString),
        HomeCellModel(main: "Calendar",
                      subtitle: "Athletics, colleges, & events.",
                      icon: FontAwesomeIcon.calendarIcon,
                      segue: "toCalendar"),
        HomeCellModel(main: "Clubs",
                      subtitle: "Browse over 50+ on-campus clubs!",
                      icon: FontAwesomeIcon.searchIcon,
                      segue: "toClubs"),
        HomeCellModel(main: "Attendance Hotline",
                      subtitle: "Excuse your student from class.",
                      icon: FontAwesomeIcon.phoneIcon,
                      link: Links.getLink(fromKey: .attendance)!.absoluteString)
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Log.m()
        self.weatherButton.setTitle(PHomeModel.shared.weather, for: .normal)
        self.dayTypeButton.setTitle(PHomeModel.shared.dayType, for: .normal)
        self.greetingLabel.text = PHomeModel.shared.greeting
        self.title = PHomeModel.shared.date

        navigationItem.leftBarButtonItem = UIBarButtonItem(image: FontAwesomeIcon.listIcon.image(ofSize: CGSize(width: 20, height: 20), color: UIColor.primary), style: .plain, target: self, action: #selector(menuTapped))

        self.dayTypeButton.contentHorizontalAlignment = .left
        self.campusMapButton.contentHorizontalAlignment = .left
        self.weatherButton.contentHorizontalAlignment = .left

        self.topView.backgroundColor = UIColor.primary

        self.tableView.delegate = self
        self.tableView.dataSource = self
        setupMenu()
    }
    
    @objc func menuTapped() {
        present(SideMenuManager.default.menuLeftNavigationController!, animated: true, completion: nil)
    }
    
    func setupMenu() {
        HomeModel.setupMenu(storyboard: storyboard!, menuViewId: "MenuNavigationController", width: view.frame.width * (0.80), navigationController: self.navigationController!)
    }

    @IBAction func dayCalendarTapped(_ sender: Any) {
        openLink(withURL: Links.getLink(fromKey: .dayCalendar))
    }
    @IBAction func weatherTapped(_ sender: Any) {
        openLink(withURL: Links.getLink(fromKey: .weather))
    }
    @IBAction func mapTapped(_ sender: Any) {
        openLink(withURL: Links.getLink(fromKey: .campusMap))
    }

    
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
        return UITableViewAutomaticDimension
    }
}
