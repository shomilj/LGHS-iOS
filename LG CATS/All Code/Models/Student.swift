//
//  Student.swift
//  Falcon
//
//  Created by Shomil Jain on 6/21/18.
//  Copyright © 2018 Avina Labs. All rights reserved.
//

import Foundation
import UIKit
import Firebase

struct ParsedStudents {
    private(set) var students: [Student]?
    private(set) var error: String?
}

public class Student {
    
    private(set) var firstName: String!
    private(set) var lastName: String!
    private(set) var year: String!
    private(set) var id: String!
    private(set) var email: String!
    
    var fullName: String {
        return firstName + " " + lastName
    }
    
    public init(first: String, last: String, year: String, id: String, email: String) {
        self.firstName = first
        self.lastName = last
        self.year = year
        self.id = id
        self.email = email
    }
    
    struct TableIndex {
        static var studentId = 0
        static var firstName = 1
        static var lastName = 2
        static var email = 3
        static var year = 4
        static var COLUMN_COUNT = 5
    }
    
    static func parseStudents(fromTSV tsv: [[String]]) -> ParsedStudents {
        var table = tsv
        table.removeFirst()
        var students: [Student] = []
        for (rowNumber, row) in table.enumerated() {
            if row.count != TableIndex.COLUMN_COUNT {
                return ParsedStudents(students: nil, error: "Please check row \(rowNumber + 1) of your spreadsheet. We expected \(TableIndex.COLUMN_COUNT) columns but received \(row.count) instead.")
            }
            students.append(Student(first: row[TableIndex.firstName],
                                    last: row[TableIndex.lastName], year: row[TableIndex.year], id: row[TableIndex.studentId], email: row[TableIndex.email]))
        }
        return ParsedStudents(students: students, error: nil)
    }
        
    func deleteSelf() {
        Database.database().reference()
            .child(Keys.Database.version)
            .child(Keys.Database.appData)
            .child(Keys.Database.studentRoster)
            .child(id).setValue(nil)
    }
    
    static func upload(students: [Student]) {
        var dict = [String: [String: String]]()
        for student in students {
            dict[student.id] = [
                Keys.Database.StudentRoster.firstName: student.firstName,
                Keys.Database.StudentRoster.lastName: student.lastName,
                Keys.Database.StudentRoster.email: student.email,
                Keys.Database.StudentRoster.gradYear: student.year
            ]
        }
        
        Database.database().reference()
            .child(Keys.Database.version)
            .child(Keys.Database.appData)
            .child(Keys.Database.studentRoster).setValue(dict)
    }
    
    public enum Grade: Int {
        case before = 8
        case freshman = 9
        case sophomore = 10
        case junior = 11
        case senior = 12
        case after = 13
    }
    
    func getGrade() -> Grade {
        let date = Date()
        let calendar = Calendar.current
        let components = calendar.dateComponents([.month, .year], from: date)
        
        let month = components.month!
        
        // the current year (i.e. 2018)
        let currentYear = components.year!
        
        // the year that the school year ends in. (i.e. 2018)
        var endingYear = currentYear
        
        // the month is >= july
        if month >= 7 {
            // school year string is currentYear -> currentYear + 1
            endingYear = currentYear + 1
        }
        
        // i.e 12 - (2018 - 2018) = 12 - 0 = 12
        let grade = (12 - (Int(year)! - endingYear))
        Log.i("YEAR = \(Int(year)!)")
        if grade < 9 {
            return .before
        } else if grade == 9 {
            return .freshman
        } else if grade == 10 {
            return .sophomore
        } else if grade == 11 {
            return .junior
        } else if grade == 12 {
            return .senior
        } else {
            return .after
        }
    }
    
}
