//
//  CIEventSubmitRosterVC.swift
//  Falcon
//
//  Created by Shomil Jain on 7/24/18.
//  Copyright © 2018 Avina Labs. All rights reserved.
//

import UIKit
import Firebase

class CIEventSubmitRosterVC: UIViewController {

    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var linkField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        hideKeyboardWhenTappedAround()
        self.view.tintColor = UIColor.primary

        self.submitButton.layer.cornerRadius = 8
        self.submitButton.backgroundColor = UIColor.primary
    }
    
    @IBAction func submitTapped(_ sender: Any) {
        dismissKeyboard()
        LoadingOverlay.shared.showOverlay(self.view)
        guard let link = linkField.text else {
            endWithError(message: "Please enter a link!")
            return;
        }
        DispatchQueue.global(qos: .background).async {
            self.process(link: link)
        }
    }
    
    func process(link: String) {
        guard let googleLink = Links.parseGoogleLink(rawLink: link) else {
            endWithError(message: "Please enter a valid link!")
            return;
        }
        
        Downloader.downloadTextFile(fromLink: googleLink) { (contentsUW) in
            guard let contents = contentsUW else {
                self.endWithError(message: "No data was found at this link. Please try again.")
                return;
            }
            guard let tsv = Downloader.parseTSV(fromString: contents) else {
                self.endWithError(message: "Please ensure that your link is valid and try again.")
                return;
            }
            self.writeToDatabase(studentData: tsv)
        }
    }
    
    struct TableStructure {
        static var id = 0
        static var firstName = 1
        static var lastName = 2
        static var COL_COUNT = 3
    }
    
    func writeToDatabase(studentData: [[String]]) {
        var dict = [String: [String: Any]]()
        for (index, row) in studentData.enumerated() {
            if row.count != TableStructure.COL_COUNT {
                endWithError(message: "Please check row \(index). We expected \(TableStructure.COL_COUNT) columns but received \(row.count) instead.")
                return;
            }
            let id = row[TableStructure.id]
            let first = row[TableStructure.firstName]
            let last = row[TableStructure.lastName]
            dict[id] = [Keys.Database.Event.name: first + " " + last,
                        Keys.Database.Event.checkedIn: false]
        }
        Database.database().reference()
            .child(Keys.Database.version)
            .child(Keys.Database.appData)
            .child(Keys.Database.events)
            .child(CIEvent.shared.getId())
            .child(Keys.Database.Event.roster).setValue(dict)
        endWithSuccess(message: "The student roster has successfully been imported! There are \(dict.count) students registered for this event. You may now begin to check students in.")
    }
    
    func endWithError(message: String) {
        DispatchQueue.main.async {
            LoadingOverlay.shared.hideOverlayView()
            self.showError(message: message, title: "Error") {}
        }
    }
    
    func endWithSuccess(message: String) {
        DispatchQueue.main.async {
            LoadingOverlay.shared.hideOverlayView()
            self.showAlert(message: message, title: "Success!") {
                _ = self.navigationController?.popViewController(animated: true)
            }
        }
    }

}
