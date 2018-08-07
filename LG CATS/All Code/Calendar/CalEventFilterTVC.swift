//
//  CalEventFilterTVC.swift
//  Falcon
//
//  Created by Shomil Jain on 7/25/18.
//  Copyright © 2018 Avina Labs. All rights reserved.
//

import UIKit
import PopupDialog

class CalEventFilterTVC: UITableViewController {

    var feeds = [CalFeed]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.tintColor = UIColor.primary
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        navigationController?.setToolbarHidden(false, animated: false)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return feeds.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "cell")
        let feed = feeds[indexPath.row]
        cell?.textLabel?.text = feed.name
        cell?.tintColor = UIColor.primary
        if feed.isVisible {
            cell?.accessoryType = .checkmark
        } else {
            cell?.accessoryType = .none
        }
        return cell!
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableView.deselectRow(at: indexPath, animated: true)
        let feed = feeds[indexPath.row]
        if feed.isVisible {
            feed.hide()
            self.tableView.cellForRow(at: indexPath)!.accessoryType = .none
        } else {
            feed.show()
            self.tableView.cellForRow(at: indexPath)!.accessoryType = .checkmark
        }
    }
    
    @IBAction func subscribeTapped(_ sender: Any) {
        let popup = PopupDialog(title: "Please select a calendar.", message: "Which of the following calendars would you like to subscribe to?")
        
        let cancel = DestructiveButton(title: "Cancel") {
            
        }
        var buttons = [PopupDialogButton]()
        for feed in feeds {
            buttons.append(DefaultButton(title: feed.name) {
                self.openLink(withURL: feed.link)
            })
        }
        buttons.append(cancel)
        popup.addButtons(buttons)
        self.present(popup, animated: true, completion: nil)
    }
    
    @IBAction func showAllTapped(_ sender: Any) {
        for feed in feeds {
            feed.show()
        }
        self.tableView.reloadData()
    }
}
