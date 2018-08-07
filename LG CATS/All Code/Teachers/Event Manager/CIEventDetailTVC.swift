//
//  CIEventDetailTVC.swift
//  Black Panther
//
//  Created by Shomil Jain on 5/21/18.
//  Copyright © 2018 Avina Labs. All rights reserved.
//

import UIKit
import BarcodeScanner
import AVKit
import Firebase
import PopupDialog
import Iconic

class CIEventDetailTVC: UITableViewController {

    @IBOutlet weak var checkInCell: UITableViewCell!
    @IBOutlet weak var importRosterCell: UITableViewCell!
    @IBOutlet weak var deleteEvent: UITableViewCell!
    
    @IBOutlet weak var rosterImageView: UIImageView!
    @IBOutlet weak var scannerImageView: UIImageView!
    @IBOutlet weak var importImageView: UIImageView!
    
    @IBOutlet weak var eventName: UILabel!
    @IBOutlet weak var eventDate: UILabel!
    @IBOutlet weak var eventLocation: UILabel!
    @IBOutlet weak var checkedInLabel: UILabel!
    @IBOutlet weak var deleteEventLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        rosterImageView.image = FontAwesomeIcon.groupIcon.image(ofSize: CGSize(width: 50, height: 50), color: UIColor.primary)
        scannerImageView.image = FontAwesomeIcon.ticketIcon.image(ofSize: CGSize(width: 50, height: 50), color: UIColor.primary)
        importImageView.image = FontAwesomeIcon.copyIcon.image(ofSize: CGSize(width: 50, height: 50), color: UIColor.primary)
        
        deleteEventLabel.textColor = UIColor.primary
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateUI), name: Notification.Name(Keys.Notifications.eventObserverUpdate), object: nil)
        updateUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.navigationController?.setToolbarHidden(true, animated: true)
    }
    
    @objc func updateUI() {
        self.eventName.text = CIEvent.shared.getName()
        self.eventDate.text = CIEvent.shared.getDate(inFormat: .long)
        self.eventLocation.text = CIEvent.shared.getLocation()
        self.checkedInLabel.text = CIEvent.shared.getCount()
        self.navigationItem.title = CIEvent.shared.getName()
        self.tableView.reloadData()
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableView.deselectRow(at: indexPath, animated: true)
        if let cell = tableView.cellForRow(at: indexPath) {
            if cell == checkInCell {
                checkInTapped()
            } else if cell == importRosterCell {
                importRosterTapped()
            } else if cell == deleteEvent {
                delete()
            }
        }
    }
    
    func delete() {
        let popup = PopupDialog(title: "Delete Event", message: "Are you sure you would like to delete this event? This action may not be undone.")
        let buttonOne = CancelButton(title: "Dismiss") {}
        let buttonTwo = DestructiveButton(title: "Delete") {
            CIEvent.shared.delete()
            _ = self.navigationController?.popViewController(animated: true)
        }
        popup.addButtons([buttonOne, buttonTwo])
        self.present(popup, animated: true, completion: nil)
    }
    
    func importRosterTapped() {
        let message =
        """
        In order to import a student roster, you will need to create a Google Spreadsheet as described below. You may either create a spreadsheet from scratch or use the template provided.

        This spreadsheet is formatted as follows:
        Row 1 = HEADER ROW (see template)

        Column 1 = Student ID
        Column 2 = First Name
        Column 3 = Last Name
        """
        
        let popup = PopupDialog(title: "Roster Template Information", message: message)
        let buttonOne = CancelButton(title: "Dismiss") {}
        let buttonTwo = DefaultButton(title: "Share Template Link (to other device)") {
            self.shareLink(link: Links.getLink(fromKey: .eventRosterTemplate))
        }
        let buttonThree = DefaultButton(title: "Open Template") {
            self.openLink(withURL: Links.getLink(fromKey: .eventRosterTemplate))
        }
        let buttonFour = DefaultButton(title: "I'm Ready! Proceed to Import.") {
            self.performSegue(withIdentifier: "toImport", sender: self)
        }
        popup.addButtons([buttonFour, buttonThree, buttonTwo, buttonOne])
        self.present(popup, animated: true, completion: nil)

    }
        
    func checkInTapped() {
        let viewController = makeBarcodeScannerViewController()
        viewController.title = "Barcode Scanner"
        present(viewController, animated: true, completion: nil)
    }
    
    private func makeBarcodeScannerViewController() -> BarcodeScannerViewController {
        let viewController = BarcodeScannerViewController()
        viewController.codeDelegate = self
        viewController.errorDelegate = self
        viewController.dismissalDelegate = self
        viewController.headerViewController.titleLabel.text = "Check In"
        viewController.headerViewController.closeButton.tintColor = .black
        viewController.headerViewController.closeButton.setTitle("Done", for: .normal)
        viewController.metadata = [AVMetadataObject.ObjectType.code39]
        viewController.messageViewController.textLabel.text = "Processing student..."
        return viewController
    }

}

// MARK: - BarcodeScannerCodeDelegate

extension CIEventDetailTVC: BarcodeScannerCodeDelegate {
    func scanner(_ controller: BarcodeScannerViewController, didCaptureCode code: String, type: String) {
        
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            controller.messageViewController.textLabel.text = "Processing student..."
            for student in CIEvent.shared.getStudents() {
                if student.id == code {
                    // Check student in!
                    if student.checkedIn {
                        controller.resetWithError(message: "\(student.name) has already been checked in!")
                        return;
                    } else {
                        CIEvent.shared.checkIn(student: code)
                        controller.messageViewController.textLabel.text = "\(student.name) is checked in!"
                        controller.reset()
                        controller.messageViewController.textLabel.text = "\(student.name) is now checked in!"
                        self.resetFooter(forController: controller)
                        return;
                    }
                }
            }
            controller.resetWithError(message: "This student doesn't have a ticket!")
            controller.messageViewController.textLabel.text = "This student doesn't have a ticket!"
            self.resetFooter(forController: controller)
        }
    }
    
    func resetFooter(forController controller: BarcodeScannerViewController) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 10.0) {
            controller.messageViewController.textLabel.text = "Please place a student ID card within the window to scan. The card will be recognized automatically."
        }
    }
}

// MARK: - BarcodeScannerErrorDelegate

extension CIEventDetailTVC: BarcodeScannerErrorDelegate {
    func scanner(_ controller: BarcodeScannerViewController, didReceiveError error: Error) {
        print(error)
    }
}

// MARK: - BarcodeScannerDismissalDelegate

extension CIEventDetailTVC: BarcodeScannerDismissalDelegate {
    func scannerDidDismiss(_ controller: BarcodeScannerViewController) {
        controller.dismiss(animated: true, completion: nil)
    }
}
