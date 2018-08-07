//
//  SToolsTVC.swift
//  Falcon
//
//  Created by Shomil Jain on 7/22/18.
//  Copyright © 2018 Avina Labs. All rights reserved.
//

import UIKit
import Iconic
import SideMenu

struct SToolsCellModel {
    var main: String!
    var icon: FontAwesomeIcon!
    var segue: String?
    var link: URL?
}

class ToolsTVC: UITableViewController {

    var tableData = School.ToolsTableData

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: FontAwesomeIcon.listIcon.image(ofSize: CGSize(width: 20, height: 20), color: UIColor.primary), style: .plain, target: self, action: #selector(menuTapped))
        
        self.navigationItem.title = "Tools"
    }
    
    @objc func menuTapped() {
        present(SideMenuManager.default.menuLeftNavigationController!, animated: true, completion: nil)
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return tableData.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let header = Array(tableData.keys)[section]
        let set = tableData[header]!
        return set.count
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return Array(tableData.keys)[section]
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? HomeCell

        let header = Array(tableData.keys)[indexPath.section]
        let set = tableData[header]!
        let item = set[indexPath.row]
        cell?.iconImageView.image = item.icon.image(ofSize: CGSize(width: 50.0, height: 50.0), color: UIColor.primary)
        
        cell?.mainTextLabel.text = item.main
        
        return cell!
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let indexPath = self.tableView.indexPathForSelectedRow {
            let header = Array(tableData.keys)[indexPath.section]
            let set = tableData[header]!
            let item = set[indexPath.row]
            Log.logSelection(toScreen: item.main)
            if let segue = item.segue {
                self.performSegue(withIdentifier: segue, sender: self)
            } else if let link = item.link {
                openLink(withURL: link)
            } else {
                showAlert(message: "This feature is not currently available. Please try again later.")
            }
        }
        
        self.tableView.deselectRow(at: indexPath, animated: true)

    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50.0
    }

}
