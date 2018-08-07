//
//  CalEventDetailTVC.swift
//  LG CATS
//
//  Created by Shomil Jain on 8/4/18.
//  Copyright © 2018 Avina Labs. All rights reserved.
//

import UIKit
import MessageUI
import EventKit
import PopupDialog

class CalEventDetailTVC: UITableViewController, MFMailComposeViewControllerDelegate {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var addToCalendarButton: UITableViewCell!
    @IBOutlet weak var viewMyCalendarCell: UITableViewCell!
    @IBOutlet weak var reportErrorButton: UITableViewCell!
    
    var event: CalEvent!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.titleLabel.text = event.summary
        self.locationLabel.text = event.location ?? ""
        self.dateLabel.text = event.getStartDate(inFormat: .dayOnly)
        
        if event.allDay {
            self.timeLabel.text = "All Day"
        } else {
            self.timeLabel.text = "from " + event.getStartDate(inFormat: .time) + " to " + event.getEndDate(inFormat: .time)
        }
        self.tableView.estimatedRowHeight = 45
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.reloadData()
    }
    
    @IBAction func tappedLocation(_ sender: Any) {
        let popup = PopupDialog(title: nil, message: "\(event.location!)")
        let cancel = DestructiveButton(title: "Cancel") {}
        let maps = DefaultButton(title: "Open in Maps") {
            self.openInMaps()
        }
        let campus = DefaultButton(title: "View Campus Map") {
            self.openLink(withURL: Links.getLink(fromKey: .campusMap))
        }
        popup.addButtons([maps, campus, cancel])
        self.present(popup, animated: true, completion: nil)
    }
    
    func openInMaps() {
        var locationString = event.location ?? "Los Gatos High School"
        locationString = locationString.replacingOccurrences(of: " ", with: ",")
        if let url = URL(string: "http://maps.apple.com/?address=\(locationString)") {
            UIApplication.shared.openURL(url)
        } else {
            showAlert(message: "This location could not be found.")
        }
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableView.deselectRow(at: indexPath, animated: true)
        if let cell = self.tableView.cellForRow(at: indexPath) {
            if cell == addToCalendarButton {
                addToCalendar(event: event)
            } else if cell == reportErrorButton {
                reportError()
            } else if cell == viewMyCalendarCell {
                gotoAppleCalendar(date: event.startDate)
            }
        }
    }
    
    func gotoAppleCalendar(date: Date) {
        let interval = date.timeIntervalSinceReferenceDate
        let url = URL(string: "calshow:\(interval)")!
        UIApplication.shared.openURL(url)
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }

    func addToCalendar(event eventToAdd: CalEvent) {
        let eventStore : EKEventStore = EKEventStore()
        eventStore.requestAccess(to: .event) { (granted, error) in
            if (granted) && (error == nil) {
                let event:EKEvent = EKEvent(eventStore: eventStore)
                event.title = eventToAdd.summary!
                event.startDate = eventToAdd.startDate!
                event.endDate = eventToAdd.endDate!
                event.notes = "Added by the \(School.APP_NAME)."
                event.isAllDay = eventToAdd.allDay
                event.calendar = eventStore.defaultCalendarForNewEvents
                do {
                    try eventStore.save(event, span: .thisEvent)
                    self.showAlert(message: "This event has been added to your calendar.", title: "Success")
                } catch let error as NSError {
                    Log.e("Unable to add event to calendar: \(error.localizedDescription)")
                    self.showError(message: "We were unable to add this event to your calendar.")
                }
            } else {
                self.showError(message: "We were unable to add this event to your calendar.")
            }
        }
    }
    
    func reportError() {
        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            mail.setToRecipients([School.SUPPORT_EMAIL])
            mail.setMessageBody(
                """
                Please enter your corrections:



                CURRENT EVENT INFORMATION:
                Name: \(event.summary ?? "Unknown")
                Start Date: \(event.startDate ?? Date())
                End Date: \(event.endDate ?? Date())
                Location: \(event.location ?? "Unknown")

                """, isHTML: false)
            mail.setSubject("\(School.APP_NAME) – Calendar Correction")
            present(mail, animated: true)
        } else {
            showError(message: "This device is unable to send email. This error may not be reported.")
        }
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true)
    }

}
