//
//  SHomeModel.swift
//  Falcon
//
//  Created by Shomil Jain on 6/21/18.
//  Copyright © 2018 Avina Labs. All rights reserved.
//

import Foundation
import UIKit

public class STHomeModel: HomeModel {
    
    private(set) var name: String!
    private(set) var greeting: String!
    private(set) var dayType: String!
    private(set) var weather: String!
    private(set) var date: String!
    private(set) var userType: UserUtil.UserType!
        
    static let shared = STHomeModel()
    
    public func isUpdated() -> Bool {
        return name != nil
    }
    
    public static func updateShared(forType type: UserUtil.UserType, completion: @escaping (Bool) -> Void) {
        var name: String!
        if type == .student {
            guard let studentName = UserUtil.getCurrentStudent()?.firstName else {
                Log.e("Can't find student name in home model!")
                completion(false)
                return;
            }
            name = studentName
        } else if type == .teacher {
            guard let teacherName = UserUtil.getCurrentTeacher()?.firstName else {
                Log.e("Can't find teacher name in home model!")
                completion(false)
                return;
            }
            name = teacherName
        }
        if name == nil {
            Log.e("Can't find S/T name in home model!")
            completion(false)
            return;
        }
        shared.userType = type
        shared.name = name + "."
        shared.greeting = getGreeting(type: .student)
        shared.dayType = getDayType()
        shared.date = getDate()
        Log.d("Fetching weather...")
        getTemperature { (weatherFetched) in
            Log.d("Fetched weather!")
            self.shared.weather = weatherFetched ?? "Weather @ LGHS >"
            completion(true)
        }
    }
    
    public static func updateSharedManual(forType type: UserUtil.UserType, completion: @escaping (Bool) -> Void) {
        DayType.downloadDayCalendar(completion: { (firstC) in
            updateShared(forType: type) { (secondC) in
                completion(firstC && secondC)
            }
        })
    }
    
}
