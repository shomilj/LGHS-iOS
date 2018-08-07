//
//  TeacherList.swift
//  Falcon
//
//  Created by Shomil Jain on 7/23/18.
//  Copyright © 2018 Avina Labs. All rights reserved.
//

import Foundation
import Firebase

public class TeacherList {
    
    private(set) var roster: [Teacher]?
    
    public init() {
        roster = nil
    }
    
    static let shared = TeacherList()
    
    func downloadTeacherList(completion: @escaping (Bool?) -> Void) {
        Database.database().reference()
            .child(Keys.Database.version)
            .child(Keys.Database.appData).child(Keys.Database.teacherRoster).observeSingleEvent(of: .value) { (snapshot) in
            guard let list = snapshot.value as? [String: Any] else {
                Log.e("Failed to download list of teachers!")
                completion(false)
                return;
            }
            var teachers = [Teacher]()
            for (teacherId, detailsUW) in list {
                guard let details = detailsUW as? [String: Any] else {
                    Log.w("Failed to find details of teachers. Skipping.")
                    continue;
                }
                guard let firstName = details[Keys.Database.TeacherRoster.firstName] as? String else {
                    Log.w("Failed to find firstName of teacher! Skipping.")
                    continue;
                }
                guard let lastName = details[Keys.Database.TeacherRoster.lastName] as? String else {
                    Log.w("Failed to find lastName of teacher! Skipping.")
                    continue;
                }
                guard let email = details[Keys.Database.TeacherRoster.email] as? String else {
                    Log.w("Failed to find email of teacher! Skipping.")
                    continue;
                }
                guard let isAdmin = details[Keys.Database.TeacherRoster.isAdmin]  as? Bool else {
                    Log.w("Failed to find isAdmin of teacher! Skipping.")
                    continue;
                }
                teachers.append(Teacher(firstName: firstName, lastName: lastName, email: email, isAdmin: isAdmin))
            }
            if teachers.count == 0 {
                Log.e("Failed to download/parse teachers! There are ZERO in the database.")
                completion(false)
            }
            TeacherList.shared.roster = teachers
            completion(true)
        }
    }
    
    // Precondition: singleton has been set by downloadStudentList()
    static func getTeacher(fromEmail email: String) -> Teacher? {
        if let teachers = TeacherList.shared.roster {
            for teacher in teachers {
                if teacher.email == email {
                    return teacher
                }
            }
        } else {
            Log.w("The singleton must be set using downloadTeacherList() before calling this function.")
        }
        return nil
    }
    
}
