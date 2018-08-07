//
//  AdminCreateSurveyFVC.swift
//  Falcon
//
//  Created by Shomil Jain on 7/24/18.
//  Copyright © 2018 Avina Labs. All rights reserved.
//

import UIKit
import Eureka
import Firebase

class AdminCreateSurveyFVC: FormViewController {

    var selectedSurvey: Survey?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.tintColor = UIColor.primary
        
        var setRequired = RuleSet<String>()
        setRequired.add(rule: RuleRequired())

        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelTapped))

        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(saveTapped))
        
        form +++ Section()
            <<< NameRow(Keys.Database.Survey.name) { row in
                row.title = "Message Title"
                row.placeholder = "Class of 2020 T-Shirt Design Survey"
                row.value = selectedSurvey?.name
                row.add(rule: RuleRequired())
            }
            <<< NameRow(Keys.Database.Survey.submitter) { row in
                row.title = "Submitter"
                row.placeholder = "LGHS Admin, Leadership, etc."
                row.value = selectedSurvey?.submitter
                row.add(rule: RuleRequired())
            }
            <<< TextAreaRow(Keys.Database.Survey.description) {
                $0.title = "Message Description"
                $0.placeholder = "Vote on your favorite class shirt design! These shirts will be made available for pre-order in mid-October."
                $0.textAreaHeight = .dynamic(initialTextViewHeight: 110)
                $0.value = selectedSurvey?.description
                $0.add(rule: RuleRequired())
        }
        
        form +++ Section(footer: "Your message will only be made available between these dates.")
            <<< DateTimeRow(Keys.Database.Survey.beginDate) {
                $0.title = "Start Date/Time";
                if let begin = selectedSurvey?.beginTimestamp {
                    $0.value = Date(timeIntervalSince1970: begin)
                } else {
                    $0.value = Date()
                }
                $0.add(rule: RuleRequired())
            }
            <<< DateTimeRow(Keys.Database.Survey.expireDate) {
                $0.title = "End Date/Time";
                if let end = selectedSurvey?.expireTimestamp {
                    $0.value = Date(timeIntervalSince1970: end)
                } else {
                    $0.value = Date()
                }
                $0.add(rule: RuleRequired())
        }
        
        form +++ Section()
            <<< MultipleSelectorRow<String>(Keys.Database.Survey.audience) {
                $0.title = "Audience"
                $0.options = ["Class of 2019", "Class of 2020", "Class of 2021", "Class of 2022", "Parents", "Teachers"]
                
                if let oldAudience = selectedSurvey?.audience {
                    var previousAnswer = [String]()
                    for item in oldAudience.components(separatedBy: ",") {
                        if item.contains("2") {
                            previousAnswer.append("Class of \(item)")
                        } else {
                            previousAnswer.append(item)
                        }
                    }
                    $0.value = Set(previousAnswer)
                }
                
                }.onPresent { from, to in
                    to.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: from, action: #selector(AdminCreateSurveyFVC.multipleSelectorDone(_:)))
                }
            
            <<< AccountRow() { row in
                row.title = "Form Link"
                row.tag = Keys.Database.Survey.link
                row.value = selectedSurvey?.url.absoluteString
                row.placeholder = "https://tinyurl.com/DCDS323F"
                row.add(rule: RuleRequired())
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
            var startTime = (valuesDictionary[Keys.Database.Survey.beginDate] as! Date).timeIntervalSince1970
            var endTime = (valuesDictionary[Keys.Database.Survey.expireDate] as! Date).timeIntervalSince1970
            if startTime > endTime {
                LoadingOverlay.shared.hideOverlayView()
                self.showAlert(message: "Please select an end time that is after the selected start time.", title: "Error")
                return;
            } else if endTime < Date().timeIntervalSince1970 {
                LoadingOverlay.shared.hideOverlayView()
                self.showAlert(message: "Please select an end date and time that is in the future.", title: "Error")
                return;
            }
            
            valuesDictionary[Keys.Database.Survey.beginDate] = startTime
            valuesDictionary[Keys.Database.Survey.expireDate] = endTime
            
            Log.d("\(valuesDictionary)")
            var link = valuesDictionary[Keys.Database.Survey.link] as! String
            if URL(string: link) == nil {
                Log.d("Link is invalid – \(link)")
                link = "https://\(link)"
                if URL(string: link) != nil {
                    Log.d("Adding HTTPS to entered link – \(link)")
                    // Good, but needs https. Replace it!
                    valuesDictionary[Keys.Database.Survey.link] = link
                } else {
                    Log.d("User entered invalid link.")
                    // Bad Link
                    LoadingOverlay.shared.hideOverlayView()
                    showAlert(message: "Please check the format of your link and try again.", title: "Invalid Link")
                    return;
                }
            } else {
                Log.d("This link is valid! \(link)")
            }
            
            
            let audienceList = Array(valuesDictionary[Keys.Database.Survey.audience] as! Set<String>)
            
            var audience = String()
            for item in audienceList {
                audience.append(item.replacingOccurrences(of: "Class of", with: "") + ",")
            }
            // We added an extra comma!
            audience.removeLast()
            valuesDictionary[Keys.Database.Survey.audience] = audience
            
            Log.d("VALUES DICTIONARY UPLOAD TO FIREBASE –––")
            Log.d("\(valuesDictionary)")
           
           
            if let id = selectedSurvey?.id {
               Log.d("Existing survey updated!")
                Database.database().reference()
                    .child(Keys.Database.version)
                    .child(Keys.Database.appData)
                    .child(Keys.Database.surveys)
                    .child(id).setValue(valuesDictionary)
                
            } else {
                Log.d("New survey created!")
                Database.database().reference()
                    .child(Keys.Database.version)
                    .child(Keys.Database.appData)
                    .child(Keys.Database.surveys)
                    .childByAutoId().setValue(valuesDictionary)
                
            }
            
            LoadingOverlay.shared.hideOverlayView()
            self.dismiss(animated: true, completion: nil)
        } else {
            LoadingOverlay.shared.hideOverlayView()
            self.showAlert(message: "Please answer all of the required fields!", title: "Hold on!")
        }

    }
    
}
