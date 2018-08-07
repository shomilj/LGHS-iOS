//
//  SResourcesTVC.swift
//  Falcon
//
//  Created by Shomil Jain on 7/20/18.
//  Copyright © 2018 Avina Labs. All rights reserved.
//

import UIKit
import Iconic
import SkeletonView
import SideMenu

class ResourcesTVC: UITableViewController {
    
    var tableData = [SResourceHeader]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Log.m()
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: FontAwesomeIcon.listIcon.image(ofSize: CGSize(width: 20, height: 20), color: UIColor.primary), style: .plain, target: self, action: #selector(menuTapped))
        
        self.navigationItem.title = "Resources"
        
        if let structure = ResourceModel.shared.structure {
            self.tableData = structure
            self.tableView.reloadData()
        } else {
            if tableData.count == 0 {
                self.showError(message: "An error occurred while loading the resources page. Please try again later or contact support.", title: "Error")
            }
        }
    }
    
    @objc func menuTapped() {
        present(SideMenuManager.default.menuLeftNavigationController!, animated: true, completion: nil)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableData.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? ResourceHeaderCell
        cell?.mainLabel.text = tableData[indexPath.row].name
        cell?.subtitleLabel.text = tableData[indexPath.row].description
        cell?.iconImageView.image = FontAwesomeIcon(named: tableData[indexPath.row].iconName).image(ofSize: CGSize(width: 50.0, height: 50.0), color: UIColor.primary)
        
        cell?.imageView?.contentMode = .scaleAspectFit
        
        return cell!
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let path = self.tableView.indexPathForSelectedRow,
            let children = tableData[path.row].children,
            let identifier = segue.identifier,
            identifier == "next",
            let nextView = segue.destination as? ResourcesDetailTVC {
            Log.logSelection(toScreen: "Resources: " + tableData[path.row].name)
            nextView.tableData = children
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70.0
    }
    
}
