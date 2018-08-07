//
//  CalEventListTVC.swift
//  Falcon
//
//  Created by Shomil Jain on 7/25/18.
//  Copyright © 2018 Avina Labs. All rights reserved.
//

import UIKit
import DZNEmptyDataSet
import Iconic
import PopupDialog
import EventKit
import Firebase

class CalHeader: UITableViewCell {
        @IBOutlet weak var headerLabel: UILabel!
}

class CalEventListTVC: UITableViewController, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {
    
    var showEmpty = false
    var feeds: [CalFeed]!
    var processedFeeds = 0

    var sortedKeys = [Date]()
    var tableData = [Date: [CalEvent]]()
    
    var selectedEvent: CalEvent!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        LoadingOverlay.shared.showOverlay(self.view)
        // Configure the empty data set
        tableView.emptyDataSetSource = self
        tableView.emptyDataSetDelegate = self
        tableView.tableFooterView = UIView()
        
        Database.database().reference()
            .child(Keys.Database.version)
            .child(Keys.Database.appData)
            .child(Keys.Database.calendars).observeSingleEvent(of: .value) { (snapshot) in
            
                guard let array = snapshot.value as? [[String: Any]] else {
                    Log.e("No calendars found!")
                    return;
                }
                
                self.feeds = []
                var index = 0
                for item in array {
                    guard let name = item[Keys.Database.Calendars.name] as? String else {
                        Log.w("Cannot find name for calendar!")
                        continue;
                    }
                    guard let link = item[Keys.Database.Calendars.url] as? String else {
                        Log.w("Cannot find URL for calendar!")
                        continue;
                    }
                    guard let url = URL(string: link) else {
                        Log.w("Cannot parse URL for calendar!")
                        continue;
                    }
                    
                    var color = UIColor.alizarin
                    if index < CalFeed.Colors.count {
                        color = CalFeed.Colors[index]
                    }
                    
                    self.feeds.append(CalFeed(name: name, link: url, color: color))
                    index += 1
                }
                
                self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: FontAwesomeIcon.listIcon.image(ofSize: CGSize(width: 20, height: 20), color: UIColor.primary), style: .plain, target: self, action: #selector(self.filterTapped))
                
                self.refreshControl?.addTarget(self, action: #selector(self.refresh), for: UIControlEvents.valueChanged)
                self.refresh(shouldShowOverlay: false)
        }
        
    }
    
    @objc func filterTapped() {
        Log.logSelection(toScreen: "Calendar Filter")
        self.performSegue(withIdentifier: "toFilter", sender: self)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toFilter",
            let navVC = segue.destination as? UINavigationController,
            let tableVC = navVC.viewControllers.first as? CalEventFilterTVC {
            
            tableVC.feeds = self.feeds
            
        } else if segue.identifier == "toEvent",
            let destination = segue.destination as? CalEventDetailTVC {
            
            destination.event = selectedEvent
            
        }
    }
    
    @IBAction func unwindToCal(_ sender: UIStoryboardSegue) {
        if let senderVC = sender.source as? CalEventFilterTVC {
            self.feeds = senderVC.feeds
            self.refresh()
        }
    }
    
    @objc func refresh(shouldShowOverlay: Bool = true) {
        if shouldShowOverlay {
            LoadingOverlay.shared.showOverlay(self.view)
        }
        DispatchQueue.global(qos: .background).async {
            self.processedFeeds = 0
            
            for feed in self.feeds {
                CalFeed.parse(feedURL: feed.link, color: feed.color, completion: { (eventListUW) in
                    guard let eventList = eventListUW else {
                        Log.w("Cannot find events for feed \(feed.name)! Skipping/ignoring!")
                        self.processedFeeds += 1;
                        return;
                    }
                    feed.setEvents(events: eventList)
                    self.processedFeeds += 1;
                    self.checkProcessed()
                })
            }
        }
    }
    
    func checkProcessed() {
        if processedFeeds != feeds.count {
            // We're not there yet!
            return;
        }
        
        // Now, we have a fully populated event list inside of each feed.
        // Let's now take a look at the events inside of the feed.
        
        tableData = [:]
        for feed in feeds {
            if feed.isVisible {
                if feed.events == nil {
                    continue;
                }
                for event in feed.events {
                    let header = event.withoutTime()
                    if tableData[header] == nil {
                        tableData[header] = [event]
                    } else {
                        tableData[header]!.append(event)
                    }
                }
            }
        }
        
        self.sortedKeys = Array(tableData.keys)
        sortedKeys.sort { (d1, d2) -> Bool in
            return d1 < d2
        }
        
        Log.d("SORTED KEYS: \(sortedKeys)")
        Log.d("TABLE DATA: \(tableData)")
        self.tableView.reloadData()
        self.refreshControl?.endRefreshing()
        LoadingOverlay.shared.hideOverlayView()
        showEmpty = true
        
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let header = sortedKeys[section]
        return tableData[header]!.count
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return sortedKeys.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "cell") as! CalEventCell
        let header = sortedKeys[indexPath.section]
        let event = tableData[header]![indexPath.row]
        cell.eventNameLabel.text = event.summary
        var loc = event.location ?? " "
        if loc.starts(with: ", ") {
            loc.removeFirst(2)
        }
        cell.eventSubtitleLabel.text = loc
        cell.separatorView.backgroundColor = event.tintColor
        cell.separatorInset = UIEdgeInsets(top: 0, left: 100, bottom: 0, right: 0)
        if event.allDay {
            cell.eventStartLabel.text = "All Day"
            cell.eventEndLabel.text = " "
        } else {
            cell.eventStartLabel.text = event.getStart()
            cell.eventEndLabel.text = event.getEnd()
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerCell = tableView.dequeueReusableCell(withIdentifier: "header") as! CalHeader
        headerCell.backgroundColor = UIColor.groupTableViewBackground
        headerCell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        headerCell.headerLabel.textColor = UIColor.primary
        let header = sortedKeys[section]
        let formatter = DateFormatter()
        formatter.dateFormat = CalEvent.DateFormat.header.rawValue
        headerCell.headerLabel.text = "\(formatter.string(from: header).uppercased())"
        return headerCell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableView.deselectRow(at: indexPath, animated: true)
        let header = sortedKeys[indexPath.section]
        selectedEvent = tableData[header]![indexPath.row]
        self.performSegue(withIdentifier: "toEvent", sender: self)
    }
    
    
    
    // MARK: - Deal with the empty data set
    
    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        if !showEmpty {
            return nil
        }
        let str = "No Events"
        let attrs = [NSAttributedStringKey.font: UIFont.preferredFont(forTextStyle: UIFontTextStyle.title1)]
        return NSAttributedString(string: str, attributes: attrs)
    }
    
    func description(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        if !showEmpty {
            return nil
        }
        let str = "There are no available events at this time. Please check back later!"
        let attrs = [NSAttributedStringKey.font: UIFont.preferredFont(forTextStyle: UIFontTextStyle.body)]
        return NSAttributedString(string: str, attributes: attrs)
    }
    
    func image(forEmptyDataSet scrollView: UIScrollView!) -> UIImage! {
        if !showEmpty {
            return nil
        }
        let image = FontAwesomeIcon.calendarEmptyIcon.image(ofSize: CGSize(width: 75, height: 75), color: UIColor.lightGray)
        return image
    }
    
    func verticalOffset(forEmptyDataSet scrollView: UIScrollView!) -> CGFloat {
        return -60.0
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 62
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 37.0
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }

}
