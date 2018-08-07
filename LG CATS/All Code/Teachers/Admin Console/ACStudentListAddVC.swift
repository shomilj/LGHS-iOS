//
//  ACStudentListAddVC.swift
//  LG CATS
//
//  Created by Shomil Jain on 7/28/18.
//  Copyright © 2018 Avina Labs. All rights reserved.
//

import UIKit
import Eureka
import Firebase

class ACStudentListAddVC: FormViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        form +++ Section()
            <<< NameRow(Keys.Database.StudentRoster.firstName){ row in
                row.title = "First Name"
                row.placeholder = "Everett"
                row.add(rule: RuleRequired())
            }
            <<< NameRow(Keys.Database.StudentRoster.lastName){ row in
                row.title = "Last Name"
                row.placeholder = "Ross"
                row.add(rule: RuleRequired())
            }
            <<< PhoneRow("StudentID"){
                $0.title = "Student ID"
                $0.placeholder = "123456"
                $0.add(rule: RuleRequired())
            }
            <<< EmailRow(Keys.Database.StudentRoster.email){
                $0.title = "Email Row"
                $0.placeholder = "rose3456@lgsstudent.org"
                $0.add(rule: RuleRequired())
            }
            <<< PhoneRow(Keys.Database.StudentRoster.gradYear) {
                $0.title = "Graduation Year"
                $0.placeholder = "2030"
                $0.add(rule: RuleRequired())
        }

    }
    
    @IBAction func doneTapped(_ sender: Any) {
        let errors = form.validate()
        if errors.count != 0 {
            showAlert(message: errors.first!.msg)
            return
        }
        
        var values = form.values()
        let studentId = values["StudentID"] as! String
        values["StudentID"] = nil
        
        Database.database().reference()
            .child(Keys.Database.version)
            .child(Keys.Database.appData)
            .child(Keys.Database.studentRoster)
            .child(studentId).setValue(values)
        
        showAlert(message: "This student has been successfully added!") {
            self.dismiss(animated: true, completion: nil)
        }
    }
    

}
