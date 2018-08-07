//
//  SResourcesDetailTVC.swift
//  Falcon
//
//  Created by Shomil Jain on 7/20/18.
//  Copyright © 2018 Avina Labs. All rights reserved.
//

import UIKit
import Iconic

class ResourcesDetailTVC: UITableViewController {

    var tableData = [SResourceChild]()

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableData.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let iconName = tableData[indexPath.row].iconName, iconName != "--" {
            let cell = tableView.dequeueReusableCell(withIdentifier: "withImage", for: indexPath) as? ResourceChildCell
            cell?.mainLabel.text = tableData[indexPath.row].name
            cell?.iconImageView.image = FontAwesomeIcon(named: iconName).image(ofSize: CGSize(width: 50, height: 50), color: UIColor.primary)
            return cell!
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "basic", for: indexPath)
            cell.textLabel?.text = tableData[indexPath.row].name
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let url = URL(string: tableData[indexPath.row].link) {
            openLink(withURL: url)
        } else {
            showAlert(message: "This resource is not currently available. Please try again later.")
        }
    }

}
