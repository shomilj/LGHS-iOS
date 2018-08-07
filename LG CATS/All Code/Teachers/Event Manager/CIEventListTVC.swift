//
//  CIEventListTVC.swift
//  Black Panther
//
//  Created by Shomil Jain on 5/21/18.
//  Copyright © 2018 Avina Labs. All rights reserved.
//

import UIKit
import Firebase

class CIEventListTVC: UITableViewController {

    var events = [CIEvent]()
    var ref: DatabaseReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.tintColor = UIColor.primary

    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        CIEvent.endObserving()
        
        ref = Database.database().reference()
            .child(Keys.Database.version)
            .child(Keys.Database.appData)
            .child(Keys.Database.events)
        
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            guard let eventList = snapshot.value as? [String: Any] else {
                Log.d("Can't find any events!")
                return;
            }
            self.events = [CIEvent]()
            for (eventKey, eventNodeUW) in eventList {
                guard let eventNode = eventNodeUW as? [String: Any] else {
                    Log.d("Can't find event node! Skip.")
                    continue;
                }
                
                print("EVENT NODE downloaded for \(eventKey)")
                
                guard let event = CIEvent.getEventFromInfo(eventInfo: eventNode, eventId: eventKey) else {
                    print("Couldn't find event!")
                    return;
                }
                self.events.append(event)
            }
            self.events = self.events.sorted(by: { $0.getDate() < $1.getDate() })
            self.tableView.reloadData()
        }) { (error) in
            print("Failed to parse events!")
            print(error.localizedDescription)
        }

    }
    
    override func viewDidDisappear(_ animated: Bool) {
        if isMovingFromParentViewController {
            Log.d("Removing all observers on event!")
            ref.removeAllObservers()
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return events.count
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 62
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! CIEventCell
        let event = events[indexPath.row]
        cell.titleLabel.text = event.getName()
        cell.dateDDLabel.text = event.getDate(inFormat: .date)
        cell.dateMMLabel.text = event.getDate(inFormat: .month)
        cell.subtitleLabel.text = event.getDetails()
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let selectedRow = self.tableView.indexPathForSelectedRow?.row {
            CIEvent.observeEvent(withId: events[selectedRow].getId())
        }
    }
    
}
