//
//  UserUtil.swift
//  Falcon
//
//  Created by Shomil Jain on 6/20/18.
//  Copyright © 2018 Avina Labs. All rights reserved.
//

import Foundation
import SideMenu
import UIKit
import Crashlytics
import Firebase

public class UserUtil {
    
    // Values stored on device via user defaults
    public enum Stored: String {
        case type
    }
    
    static var KEY_TYPE = "key_type"
    
    struct AnalyticsKeys {
        static var userType = "userType"
        static var gradYear = "gradYear"
    }
    
    public enum UserType: String {
        case student
        case teacher
        case visitor
        case parent
        // shared, school-wide device
        case common
    }
    
    
    public static var userType: UserType? {
        if let type = UserDefaults.standard.string(forKey: UserUtil.KEY_TYPE), let user = UserType(rawValue: type) {
            return user
        } else {
            return nil
        }
    }
        
    public static func setUserType(type: UserType) {
        UserDefaults.standard.set(type.rawValue, forKey: KEY_TYPE)
        Analytics.setUserProperty(userType?.rawValue, forName: AnalyticsKeys.userType)
    }
    
    public static func logout() {
        if let year = UserUtil.getCurrentStudent()?.year {
            Messaging.messaging().unsubscribe(fromTopic: "Class of \(year)")
            Log.i("Successfully removed topic for student's graduation year!")
        }
        
        for topic in Keys.Topics.allTopics {
            Messaging.messaging().unsubscribe(fromTopic: topic)
        }
        
        if let uuid = Auth.auth().currentUser?.uid, let type = UserUtil.userType {
            let ref = Database.database().reference().child(Keys.Database.version).child(Keys.Database.fcmTokens)
            ref.child("parents").child(uuid).setValue(nil)
            ref.child("students").child(uuid).setValue(nil)
            ref.child("staff").child(uuid).setValue(nil)
        } else {
            Log.w("Couldn't remove UUID's from fcmTokens database registry!")
        }
        
        Analytics.setUserProperty(nil, forName: UserUtil.AnalyticsKeys.gradYear)
        Analytics.setUserProperty(nil, forName: UserUtil.AnalyticsKeys.userType)

        SideMenuManager.default.menuLeftNavigationController = nil
        Crashlytics.sharedInstance().setUserIdentifier(nil)
        UserDefaults.standard.set(nil, forKey: KEY_TYPE)
        
        StudentData.allCases.forEach { (value) in
            UserDefaults.standard.set(nil, forKey: getKey(forStudentData: value))
        }
        TeacherData.allCases.forEach { (value) in
            UserDefaults.standard.set(nil, forKey: getKey(forTeacherData: value))
        }
    }
    
    // MARK: - Student Attributes & Methods
    
    // If the user is a student, we will store their attributes for quick access.
    public enum StudentData: String {
        case firstName
        case lastName
        case email
        case year
        case id
    }
    
    public static func getKey(forStudentData data: StudentData) -> String {
        return "key_" + data.rawValue
    }
    
    // If the user is a teacher, we will store their attributes for quick access.
    public enum TeacherData: String {
        case firstName
        case lastName
        case email
        case isAdmin
    }
    
    public static func getKey(forTeacherData data: TeacherData) -> String {
        return "key_" + data.rawValue
    }
    
    public static func saveStudent(student: Student) {
        UserDefaults.standard.set(student.firstName, forKey: getKey(forStudentData: .firstName))
        UserDefaults.standard.set(student.lastName, forKey: getKey(forStudentData: .lastName))
        UserDefaults.standard.set(student.id, forKey: getKey(forStudentData: .id))
        UserDefaults.standard.set(student.email, forKey: getKey(forStudentData: .email))
        UserDefaults.standard.set(student.year, forKey: getKey(forStudentData: .year))
        Analytics.setUserProperty(student.year, forName: AnalyticsKeys.gradYear)
    }

    public static func saveTeacher(teacher: Teacher) {
        UserDefaults.standard.set(teacher.firstName, forKey: getKey(forTeacherData: .firstName))
        UserDefaults.standard.set(teacher.lastName, forKey: getKey(forTeacherData: .lastName))
        UserDefaults.standard.set(teacher.email, forKey: getKey(forTeacherData: .email))
        UserDefaults.standard.set(teacher.isAdmin, forKey: getKey(forTeacherData: .isAdmin))
    }

    // Precondition: if the type has been set to Student, assume ALL VALUES EXIST in UserDefaults!
    public static func getCurrentStudent() -> Student? {
        if let type = userType, type == .student {
            let firstName = UserDefaults.standard.string(forKey: getKey(forStudentData: .firstName))!
            let lastName = UserDefaults.standard.string(forKey: getKey(forStudentData: .lastName))!
            let id = UserDefaults.standard.string(forKey: getKey(forStudentData: .id))!
            let email = UserDefaults.standard.string(forKey: getKey(forStudentData: .email))!
            let year = UserDefaults.standard.string(forKey: getKey(forStudentData: .year))!
            return Student(first: firstName, last: lastName, year: year, id: id, email: email)
        } else {
            return nil
        }
    }
    
    // Precondition: if the type has been set to Student, assume ALL VALUES EXIST in UserDefaults!
    public static func getCurrentTeacher() -> Teacher? {
        if let type = userType, type == .teacher {
            let firstName = UserDefaults.standard.string(forKey: getKey(forTeacherData: .firstName))!
            let lastName = UserDefaults.standard.string(forKey: getKey(forTeacherData: .lastName))!
            let email = UserDefaults.standard.string(forKey: getKey(forTeacherData: .email))!
            let isAdmin = UserDefaults.standard.bool(forKey: getKey(forTeacherData: .isAdmin))
            return Teacher(firstName: firstName, lastName: lastName, email: email, isAdmin: isAdmin)
        } else {
            return nil
        }
    }
    
}
extension UserUtil.TeacherData: CaseIterable {}
extension UserUtil.StudentData: CaseIterable {}
