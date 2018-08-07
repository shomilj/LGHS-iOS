//
//  StudentList.swift
//  Falcon
//
//  Created by Shomil Jain on 6/21/18.
//  Copyright © 2018 Avina Labs. All rights reserved.
//

import Foundation
import UIKit
import Firebase

public class StudentList {
    
    private(set) var roster: [Student]?
    
    public init() {
        roster = nil
    }

    static let shared = StudentList()
    
    func downloadStudentList(completion: @escaping (Bool?) -> Void) {
        Database.database().reference().child(Keys.Database.version).child(Keys.Database.appData).child(Keys.Database.studentRoster).observeSingleEvent(of: .value) { (snapshot) in
            guard let list = snapshot.value as? [String: Any] else {
                Log.e("Failed to download list of students!")
                completion(false)
                return;
            }
            
            guard let students = StudentList.parseStudents(fromDict: list) else {
                Log.e("Failed to parse students!")
                return;
            }
            
            StudentList.shared.roster = students
            completion(true)
        }
    }
    
    static func parseStudents(fromDict dict: [String: Any]) -> [Student]? {
        var students = [Student]()
        for (studentId, detailsUW) in dict {
            guard let details = detailsUW as? [String: String] else {
                Log.w("Failed to find details of student (check YEAR INT/STR). Skipping.")
                continue;
            }
            guard let firstName = details[Keys.Database.StudentRoster.firstName] else {
                Log.w("Failed to find firstName of student! Skipping.")
                continue;
            }
            guard let lastName = details[Keys.Database.StudentRoster.lastName] else {
                Log.w("Failed to find lastName of student! Skipping.")
                continue;
            }
            guard let year = details[Keys.Database.StudentRoster.gradYear] else {
                Log.w("Failed to find gradYear of student! Skipping.")
                continue;
            }
            guard let email = details[Keys.Database.StudentRoster.email] else {
                Log.w("Failed to find email of student! Skipping.")
                continue;
            }
            students.append(Student(first: firstName, last: lastName, year: year, id: studentId, email: email))
        }
        if students.count == 0 {
            Log.e("Failed to download/parse students! There are ZERO in the database.")
            return nil
        }
        return students
    }

    // Precondition: singleton has been set by downloadStudentList()
    static func getStudent(fromEmail email: String) -> Student? {
        if let students = StudentList.shared.roster {
            for student in students {
                if student.email == email {
                    return student
                }
            }
        } else {
            Log.w("The singleton must be set using downloadStudentList() before calling these functions.")
        }
        return nil
    }
    
}
