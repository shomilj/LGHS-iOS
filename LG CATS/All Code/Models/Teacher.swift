//
//  Teacher.swift
//  Falcon
//
//  Created by Shomil Jain on 7/23/18.
//  Copyright © 2018 Avina Labs. All rights reserved.
//

import Foundation
import UIKit
import Firebase

struct ParsedTeachers {
    private(set) var teachers: [Teacher]?
    private(set) var error: String?
}

public class Teacher {
    
    private(set) var firstName: String!
    private(set) var lastName: String!
    private(set) var email: String!
    private(set) var isAdmin: Bool!
    
    var fullName: String {
        return firstName + " " + lastName
    }
    
    public init(firstName: String, lastName: String, email: String, isAdmin: Bool) {
        self.firstName = firstName
        self.lastName = lastName
        self.email = email
        self.isAdmin = isAdmin
    }
    
    struct TableIndex {
        static var firstName = 0
        static var lastName = 1
        static var email = 2
        static var isAdmin = 3
        static var COLUMN_COUNT = 4
    }

    static func parseTeachers(fromTSV tsv: [[String]]) -> ParsedTeachers {
        var table = tsv
        table.removeFirst()
        var teachers: [Teacher] = []
        for (rowNumber, row) in table.enumerated() {
            if row.count != TableIndex.COLUMN_COUNT {
                return ParsedTeachers(teachers: nil, error: "Please check row \(rowNumber + 1) of your spreadsheet. We expected \(TableIndex.COLUMN_COUNT) columns but received \(row.count) instead.")
            }
            teachers.append(Teacher(firstName: row[TableIndex.firstName], lastName: row[TableIndex.lastName], email: row[TableIndex.email], isAdmin: (row[TableIndex.isAdmin]) == "YES"))
        }
        return ParsedTeachers(teachers: teachers, error: nil)
    }
    
    static func upload(teachers: [Teacher]) {
        var dict = [String: Any]()
        for teacher in teachers {
            dict[UUID().uuidString] = [
                Keys.Database.TeacherRoster.firstName: teacher.firstName,
                Keys.Database.TeacherRoster.lastName: teacher.lastName,
                Keys.Database.TeacherRoster.email: teacher.email,
                Keys.Database.TeacherRoster.isAdmin: teacher.isAdmin
            ]
        }
        
        Database.database().reference()
            .child(Keys.Database.version)
            .child(Keys.Database.appData)
            .child(Keys.Database.teacherRoster).setValue(dict)
    }

}
