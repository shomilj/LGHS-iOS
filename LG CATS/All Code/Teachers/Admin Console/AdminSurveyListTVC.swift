//
//  AdminSurveyListTVC.swift
//  Falcon
//
//  Created by Shomil Jain on 7/24/18.
//  Copyright © 2018 Avina Labs. All rights reserved.
//

import UIKit
import DZNEmptyDataSet
import Iconic
import Firebase

class AdminSurveyListTVC: UITableViewController, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {

    var showEmpty = false
    
    var selectedSurvey: Survey!
    
    var tableKeys = [String]()
    var tableData = [String: [Survey]]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Configure the empty data set
        tableView.emptyDataSetSource = self
        tableView.emptyDataSetDelegate = self
        tableView.tableFooterView = UIView()

        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: FontAwesomeIcon.plusIcon.image(ofSize: CGSize(width: 20, height: 20), color: UIColor.primary), style: .plain, target: self, action: #selector(addTapped))
        self.navigationItem.title = "All Surveys"
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        LoadingOverlay.shared.showOverlay(self.view)
        self.reload()
    }
    
    @objc func reload() {
        
        Database.database().reference()
            .child(Keys.Database.version)
            .child(Keys.Database.appData)
            .child(Keys.Database.surveys).observeSingleEvent(of: .value) { (snapshot) in
                guard let dict = snapshot.value as? [String: Any] else {
                    Log.e("Failed to download surveys!")
                    self.showEmpty = true
                    self.tableView.reloadData()
                    LoadingOverlay.shared.hideOverlayView()
                    return;
                }
                
                var surveys = [Survey]()
                surveys = Survey.parseSurveys(dict: dict)
                
                Log.d("There are \(surveys.count) surveys.")
                
                var active = [Survey]()
                var upcoming = [Survey]()
                var expired = [Survey]()
                
                for survey in surveys {
                    if survey.getStatus() == .upcoming {
                        upcoming.append(survey)
                    } else if survey.getStatus() == .active {
                        active.append(survey)
                    } else if survey.getStatus() == .expired {
                        expired.append(survey)
                    }
                }
                
                var myData = [String: [Survey]]()
                var keys = [String]()
                if active.count > 0 {
                    myData["Active Messages"] = active
                    keys.append("Active Messages")
                }
                if upcoming.count > 0 {
                    myData["Upcoming Messages"] = upcoming
                    keys.append("Upcoming Surveys")
                }
                if expired.count > 0 {
                    myData["Expired Messages"] = expired
                    keys.append("Expired Messages")
                }
                
                self.tableData = myData
                self.tableKeys = keys
                
                if self.tableData.count == 0 {
                    self.showEmpty = true
                }
                Log.d("There are \(self.tableData.count) surveys in the table.")
                DispatchQueue.main.async {
                    LoadingOverlay.shared.hideOverlayView()
                    self.tableView.reloadData()
                }
        }
    }
    
    @objc func addTapped() {
        self.performSegue(withIdentifier: "add", sender: self)
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return tableKeys.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableData[tableKeys[section]]!.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! SurveyCell
        let survey = tableData[tableKeys[indexPath.section]]![indexPath.row]
        cell.descriptionTextLabel.text = survey.description
        cell.titleTextLabel.text = survey.name
        let timeIndicator = Date.init(timeIntervalSince1970: survey.expireTimestamp).timeAgoSinceNow().lowercased()
        var suffix = String()
        let status = survey.getStatus()
        if status == .active {
            suffix = "Ends " + timeIndicator
        } else if status == .expired {
            suffix = "Expired " + timeIndicator
        } else if status == .upcoming {
            suffix = "Begins " + timeIndicator
        }
        cell.subtitleTextLabel.text = "\(survey.submitter.uppercased()) | \(suffix)"
        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return tableKeys[section]
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        let surveyId = tableData[tableKeys[indexPath.section]]![indexPath.row].id!
        if editingStyle == .delete {
            // Delete the row from the data source
            Database.database().reference()
                .child(Keys.Database.version)
                .child(Keys.Database.appData)
                .child(Keys.Database.surveys)
                .child(surveyId).setValue(nil)
            self.tableData[tableKeys[indexPath.section]]!.remove(at: indexPath.row)
            tableView.beginUpdates()
            tableView.deleteRows(at: [indexPath], with: .fade)
            tableView.endUpdates()
            self.tableView.reloadData()
        }   
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableView.deselectRow(at: indexPath, animated: true)
        selectedSurvey = tableData[tableKeys[indexPath.section]]![indexPath.row]
    }
    
    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let id = segue.identifier, id == "edit", let next = segue.destination as? AdminCreateSurveyFVC {
            next.selectedSurvey = selectedSurvey
        }
    }
    
    
    // MARK: - Deal with the empty data set
    
    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        if !showEmpty {
            return nil
        }
        let str = "No Messages"
        let attrs = [NSAttributedStringKey.font: UIFont.preferredFont(forTextStyle: UIFontTextStyle.title1)]
        return NSAttributedString(string: str, attributes: attrs)
    }
    
    func description(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        if !showEmpty {
            return nil
        }
        let str = "You haven't created any messages yet! To get started, use the add icon in the upper right corner."
        let attrs = [NSAttributedStringKey.font: UIFont.preferredFont(forTextStyle: UIFontTextStyle.body)]
        return NSAttributedString(string: str, attributes: attrs)
    }
    
    func image(forEmptyDataSet scrollView: UIScrollView!) -> UIImage! {
        if !showEmpty {
            return nil
        }
        let image = FontAwesomeIcon.pencilIcon.image(ofSize: CGSize(width: 75, height: 75), color: UIColor.lightGray)
        return image
    }
    
    func verticalOffset(forEmptyDataSet scrollView: UIScrollView!) -> CGFloat {
        return -60.0
    }

}
