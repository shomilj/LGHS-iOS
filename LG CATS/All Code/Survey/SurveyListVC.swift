//
//  SurveyListVC.swift
//  Falcon
//
//  Created by Shomil Jain on 7/22/18.
//  Copyright © 2018 Avina Labs. All rights reserved.
//

import UIKit
import Firebase
import SkeletonView
import Iconic
import SideMenu
import DZNEmptyDataSet

class SurveyListVC: UIViewController, UITableViewDelegate, UITableViewDataSource, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    var refreshControl = UIRefreshControl()
    var tableData: [Survey] = []
    var showEmpty = false

    override func viewDidLoad() {
        super.viewDidLoad()
        Log.m()
        
        // Configure the empty data set
        tableView.emptyDataSetSource = self
        tableView.emptyDataSetDelegate = self
        tableView.tableFooterView = UIView()
        
        refreshControl.attributedTitle = NSAttributedString(string: "")
        refreshControl.addTarget(self, action: #selector(reload), for: UIControlEvents.valueChanged)
        tableView.addSubview(refreshControl) // not required when using UITableViewController

        LoadingOverlay.shared.showOverlay(self.view)

        navigationItem.leftBarButtonItem = UIBarButtonItem(image: FontAwesomeIcon.listIcon.image(ofSize: CGSize(width: 20, height: 20), color: UIColor.primary), style: .plain, target: self, action: #selector(menuTapped))
        
        self.navigationItem.title = "My Inbox"

        self.tableView.delegate = self
        self.tableView.dataSource = self
    
        self.reload()
    }
    
    @objc func reload() {
        Survey.downloadSurveys { (surveysUW) in
            let validSurveys = surveysUW ?? [Survey]()
            self.tableData = validSurveys
            if self.tableData.count == 0 {
                self.showEmpty = true
            }
            for survey in validSurveys {
                // We have "read" these surveys now, so we can add them to UserDefaults indicating that the user has seen them.
                survey.markAsRead()
            }
            Log.d("There are \(self.tableData.count) surveys in the table.")
            DispatchQueue.main.async {
                LoadingOverlay.shared.hideOverlayView()
                self.refreshControl.endRefreshing()
                self.tableView.reloadData()
            }
        }
    }
    
    @objc func menuTapped() {
        present(SideMenuManager.default.menuLeftNavigationController!, animated: true, completion: nil)
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! SurveyCell
        let survey = tableData[indexPath.row]
        cell.descriptionTextLabel.text = survey.description
        cell.titleTextLabel.text = survey.name
        cell.subtitleTextLabel.text = "\(survey.submitter.uppercased()) | Ends \(Date.init(timeIntervalSince1970: survey.expireTimestamp).timeAgoSinceNow().lowercased())"
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let survey = tableData[indexPath.row]
        self.tableView.deselectRow(at: indexPath, animated: true)
        openLink(withURL: survey.url)
    }
    
    // MARK: - Deal with the empty data set
    
    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        if !showEmpty {
            return nil
        }
        let str = "Hey there!"
        let attrs = [NSAttributedStringKey.font: UIFont.preferredFont(forTextStyle: UIFontTextStyle.title1)]
        return NSAttributedString(string: str, attributes: attrs)
    }
    
    func description(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        if !showEmpty {
            return nil
        }
        let str = "Your inbox is currently empty! Please check back later. If you've enabled notifications, we may alert you when a new message becomes available."
        let attrs = [NSAttributedStringKey.font: UIFont.preferredFont(forTextStyle: UIFontTextStyle.body)]
        return NSAttributedString(string: str, attributes: attrs)
    }
    
    func image(forEmptyDataSet scrollView: UIScrollView!) -> UIImage! {
        if !showEmpty {
            return nil
        }
        let image = FontAwesomeIcon.smileIcon.image(ofSize: CGSize(width: 75, height: 75), color: UIColor.lightGray)
        return image
    }
    
    func verticalOffset(forEmptyDataSet scrollView: UIScrollView!) -> CGFloat {
        return 0.0
    }

}
