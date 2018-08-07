//
//  DailyAnnouncementsVC.swift
//  Falcon
//
//  Created by Shomil Jain on 6/22/18.
//  Copyright © 2018 Avina Labs. All rights reserved.
//

import Foundation
import UIKit
import FeedKit

class DailyAnnouncementsVC: UITableViewController {
    
    var list: [DAAnnouncement] = []
    var feed: RSSFeed?
    
    // Outlets
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    @IBOutlet weak var publishedByLabel: UILabel!
    @IBOutlet weak var publishDateLabel: UILabel!
    
    @IBOutlet weak var contentTextView: UITextView!
    
    @IBOutlet weak var moreAnnouncementsTitleLabel: UILabel!
    @IBOutlet weak var moreButton1: UIButton!
    @IBOutlet weak var moreButton2: UIButton!
    @IBOutlet weak var moreButton3: UIButton!
    @IBOutlet weak var moreButton4: UIButton!
    
    @IBOutlet weak var submitAnnouncementButton: UIButton!
    @IBOutlet weak var submitJokeButton: UIButton!
    
    var allViews: [UIView] = [UIView]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        format()
        showSkeleton()
        downloadAnnouncements()
    }
    
    func downloadAnnouncements() {
        let link = URL(string: "https://lghsdailyannouncements.wordpress.com?feed=rss")!
        FeedParser(URL: link).parseAsync { (result) in
            self.feed = result.rssFeed
            self.parse()
        }
    }
    
    func parse() {
        guard let items = feed?.items else {
            Log.e("Can't parse items!")
            showAlert(message: "The daily announcements are not available at this time. Please try again later.") {
                self.dismiss(animated: true, completion: nil)
            }
            return;
        }
        for item in items {
            if let title = item.title, let content = item.content, let pubDate = item.pubDate, let text = content.contentEncoded?.html2String {
                list.append(DAAnnouncement(date: title, content: text, pubDate: pubDate))
            }
        }
        DispatchQueue.main.async {
            if self.list.count < 2 {
                self.showAlert(message: "The daily announcements are not available at this time. Please try again later.") {
                    self.dismiss(animated: true, completion: nil)
                }
                return;
            }
            let first = self.list.first!
            self.titleLabel.text = "Latest Announcements"
            self.moreAnnouncementsTitleLabel.text = "MORE ANNOUNCEMENTS"
            self.dateLabel.text = first.date.uppercased()
            self.publishedByLabel.text = School.SchoolName.long.rawValue.uppercased()
            self.publishDateLabel.text = first.getLastUpdated()
            self.contentTextView.text = first.content
            self.contentTextView.sizeToFit()
            self.assignMoreAnnouncements()
            self.contentTextView.isScrollEnabled = false
            self.contentTextView.sizeToFit()
            self.tableView.beginUpdates()
            self.tableView.endUpdates()


            self.hideSkeleton()
        }
    }
    
    func assignMoreAnnouncements() {
        let moreButtons: [UIButton] = [moreButton1, moreButton2, moreButton3, moreButton4]
        let firstRemoved = list.dropFirst()
        for (index, value) in firstRemoved.enumerated() {
            if index > moreButtons.count - 1 {
                return;
            }
            moreButtons[index].setTitle(value.date + " >", for: .normal)
        }
        for button in moreButtons {
            if button.currentTitle == "Date Here" {
                button.isHidden = true
            }
        }
    }
    
    var selectedAnnouncement: DAAnnouncement?
    
    @IBAction func firstMoreTapped(_ sender: Any) {
        // This is the SECOND item in the list.
        selectedAnnouncement = list[1]
        self.performSegue(withIdentifier: "more", sender: self)
    }
    @IBAction func secondMoreTapped(_ sender: Any) {
        selectedAnnouncement = list[2]
        self.performSegue(withIdentifier: "more", sender: self)
    }
    @IBAction func thirdMoreTapped(_ sender: Any) {
        selectedAnnouncement = list[3]
        self.performSegue(withIdentifier: "more", sender: self)
    }
    @IBAction func fourthMoreTapped(_ sender: Any) {
        selectedAnnouncement = list[4]
        self.performSegue(withIdentifier: "more", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let id = segue.identifier, id == "more", let nextVC = segue.destination as? DailyAnnouncementsDetailVC, let announcement = selectedAnnouncement {
            nextVC.announcement = announcement
        }
    }
    
    func showSkeleton() {
        for view in allViews {
            view.showAnimatedSkeleton()
        }
    }
    
    func hideSkeleton() {
        for view in allViews {
            view.hideSkeleton()
        }
    }
    
    func format() {
        let darkLabels: [UILabel] = [titleLabel, dateLabel, publishedByLabel, publishDateLabel, moreAnnouncementsTitleLabel]
        for label in darkLabels {
            // label.textColor = UIColor.primaryDark
        }
        let moreButtons: [UIButton] = [moreButton1, moreButton2, moreButton3, moreButton4]
        for button in moreButtons {
            button.contentHorizontalAlignment = .left
            button.setTitleColor(UIColor.primary, for: .normal)
        }
        let submitButtons: [UIButton] = [submitJokeButton, submitAnnouncementButton]
        for button in submitButtons {
            button.backgroundColor = UIColor.primary
            button.layer.cornerRadius = 10
        }
        
        allViews.append(contentsOf: darkLabels)
        allViews.append(contentsOf: moreButtons)
        allViews.append(contentsOf: submitButtons)
        for v in allViews {
            v.isSkeletonable = true
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return 100.0
        } else if indexPath.row == 1 {
            return UITableViewAutomaticDimension
        } else if indexPath.row == 2 {
            return 183.0
        } else if indexPath.row == 3 {
            return 200.0
        } else {
            return UITableViewAutomaticDimension
        }
    }
    
    @IBAction func submitAnnouncementTapped(_ sender: Any) {
        Log.logSelection(toScreen: "Submit Announcement")
        openLink(withURL: Links.getLink(fromKey: .dailyAnnouncementMessageSubmit))
    }
    
    @IBAction func submitJokeTapped(_ sender: Any) {
        Log.logSelection(toScreen: "Submit Joke")
        openLink(withURL: Links.getLink(fromKey: .dailyAnnouncementJokeSubmit))
    }
    
}
