//
//  AdminEnterLinkVC.swift
//  Falcon
//
//  Created by Shomil Jain on 7/24/18.
//  Copyright © 2018 Avina Labs. All rights reserved.
//

import UIKit

class AdminEnterLinkVC: UIViewController {

    var selectedResource: AdminConsoleTVC.ResourceType!
    
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var linkField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        hideKeyboardWhenTappedAround()
        self.submitButton.layer.cornerRadius = 8
        self.submitButton.backgroundColor = UIColor.primary
    }

    @IBAction func submitTapped(_ sender: Any) {
        dismissKeyboard()
        LoadingOverlay.shared.showOverlay(self.view, text: "Processing data...")
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
            
            if self.selectedResource == .clubList {
                let result = Club.parseClubs(fromTSV: tsv)
                if let error = result.error {
                    self.endWithError(message: error)
                } else {
                    Club.upload(clubs: result.clubs!)
                    self.endWithSuccess(message: "The club list has been successfully uploaded! There are \(result.clubs!.count) clubs in total.")
                }
            } else if self.selectedResource == .studentRoster {
                let result = Student.parseStudents(fromTSV: tsv)
                if let error = result.error {
                    self.endWithError(message: error)
                } else {
                    Student.upload(students: result.students!)
                    self.endWithSuccess(message: "The student roster has been successfully uploaded! There are \(result.students!.count) students in total.")
                }
            } else if self.selectedResource == .teacherRoster {
                let result = Teacher.parseTeachers(fromTSV: tsv)
                if let error = result.error {
                    self.endWithError(message: error)
                } else {
                    Teacher.upload(teachers: result.teachers!)
                    self.endWithSuccess(message: "The teacher roster has been successfully uploaded! There are \(result.teachers!.count) teachers in total.")
                }
            } else if self.selectedResource == .dayCalendar {
                let result = DayType.parseDayTypes(fromTSV: tsv)
                if let error = result.error {
                    self.endWithError(message: error)
                } else {
                    DayType.upload(types: result.types!)
                    self.endWithSuccess(message: "These day types have been successfully uploaded! There are \(result.types!.count) types of days in total.")
                }

            }
            
        }
    }
    
    func endWithError(message: String) {
        DispatchQueue.main.async {
            LoadingOverlay.shared.hideOverlayView()
            self.showError(message: message, title: "Error") {
            }
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
