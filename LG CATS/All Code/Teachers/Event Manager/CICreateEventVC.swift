//
//  CICreateEventVC.swift
//  Falcon
//
//  Created by Shomil Jain on 7/24/18.
//  Copyright © 2018 Avina Labs. All rights reserved.
//

import UIKit
import Eureka
import Firebase

class CICreateEventVC: FormViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.tintColor = UIColor.primary
        
        var setRequired = RuleSet<String>()
        setRequired.add(rule: RuleRequired())
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelTapped))
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(saveTapped))
        
        form +++ Section()
            <<< NameRow(Keys.Database.Event.name) { row in
                row.title = "Event Name"
                row.placeholder = "Coronation"
                row.add(rule: RuleRequired())
            }
            <<< NameRow(Keys.Database.Event.location) { row in
                row.title = "Event Location"
                row.placeholder = "LGHS Front Lawn"
                row.add(rule: RuleRequired())
            }
            
            <<< PushRow<String>() {
                $0.title = "Event Type"
                $0.options = Array(CIEvent.EventOptions.keys).reversed()
                $0.add(rule: RuleRequired())
                }.onPresent { from, to in
                    to.dismissOnSelection = false
                    to.dismissOnChange = false
            }
        
        form +++ Section()
            <<< DateTimeRow(Keys.Database.Event.date) {
                $0.title = "Event Date & Time";
                $0.value = Date()
                $0.add(rule: RuleRequired())
        }
        
        form +++ Section()
            <<< MultipleSelectorRow<String>(Keys.Database.Event.roster) {
                $0.title = "Audience"
                $0.add(rule: RuleRequired())
                $0.options = School.CIEventAudience
                $0.selectorTitle = "Select one or more."
                }.onPresent { from, to in
                    to.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: from, action: #selector(CICreateEventVC.multipleSelectorDone(_:)))
                    }
        
    }
    
    @objc func cancelTapped(_ item: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func multipleSelectorDone(_ item:UIBarButtonItem) {
        _ = navigationController?.popViewController(animated: true)
    }
    
    @objc func saveTapped(_item: UIBarButtonItem) {
        LoadingOverlay.shared.showOverlay(self.view)
        let errors = form.validate()
        if errors.count == 0 {
            // Get the value of all rows which have a Tag assigned
            // The dictionary contains the 'rowTag':value pairs.
            var valuesDictionary = form.values()
            var eventTime = (valuesDictionary[Keys.Database.Event.date] as! Date).timeIntervalSince1970
            if eventTime < Date().timeIntervalSince1970 {
                LoadingOverlay.shared.hideOverlayView()
                self.showAlert(message: "Please select an event date and time that is in the future.", title: "Error")
                return;
            }
            
            let date = valuesDictionary[Keys.Database.Event.date] as! Date
            let formatter = DateFormatter()
            formatter.dateFormat = "YYYYMMddHHmm"
            
            // Overwrite the date with the reformatted one.
            valuesDictionary[Keys.Database.Event.date] = Int(formatter.string(from: date))!
            
            Log.d("\(valuesDictionary)")
            
            let rosterOptions = Array(valuesDictionary[Keys.Database.Event.roster] as! Set<String>)
            
            if rosterOptions.contains("Other") {
                // Skip! No roster! Remove from dictionary!
                valuesDictionary[Keys.Database.Event.roster] = nil
            } else {
                // User selected presets! WE need student roster.
                
                StudentList.shared.downloadStudentList { (success) in
                    if success ?? false, let roster = StudentList.shared.roster {
                        let options = rosterOptions.joined(separator: ",")
                        var filteredStudents = [Student]()
                        for student in roster {
                            if options.contains(student.year) {
                                filteredStudents.append(student)
                            }
                        }
                        // Now, we have the students we need to add to Firebase!
                        var studentDict = [String: [String: Any]]()
                        for student in filteredStudents {
                            studentDict[student.id] = [Keys.Database.Event.name: student.fullName,
                                                       Keys.Database.Event.checkedIn: false]
                        }
                        
                        // Now, we can upload studentDict directly.
                        valuesDictionary[Keys.Database.Event.roster] = studentDict
                        
                        Log.d("VALUES DICTIONARY UPLOAD TO FIREBASE –––")
                        Log.d("\(valuesDictionary)")
                        Database.database().reference()
                            .child(Keys.Database.version)
                            .child(Keys.Database.appData)
                            .child(Keys.Database.events)
                            .child(UUID().uuidString).setValue(valuesDictionary)
                        
                        LoadingOverlay.shared.hideOverlayView()
                        self.dismiss(animated: true, completion: nil)
                    } else {
                        self.showError(message: "An error occurred while generating a student roster per your request. Please try again or select \"Custom\" to enter a roster later.")
                    }
                }
            }
            
        } else {
            LoadingOverlay.shared.hideOverlayView()
            self.showAlert(message: "Please answer all of the required fields!", title: "Hold on!")
        }
        
    }
    

}
