//
//  Keys.swift
//  Falcon
//
//  Created by Shomil Jain on 6/20/18.
//  Copyright © 2018 Avina Labs. All rights reserved.
//

import Foundation
import Firebase

public class Keys {
    
    struct Topics {
        static var student = "Students"
        static var parent = "Parents"
        static var teacher = "Teachers"
        static var allTopics = ["Students", "Parents", "Teachers"]
    }
    struct Notifications {
        static var eventObserverUpdate = "eventObserverUpdate"
    }
    struct Database {
        static var version = "firebase_v1"
        static var appData = "appData"
        static var fcmTokens = "fcmTokens"
        
        static var studentRoster = "studentRoster"
        struct StudentRoster {
            static var email = "email"
            static var firstName = "firstName"
            static var lastName = "lastName"
            static var gradYear = "gradYear"
        }
        
        static var calendars = "calendars"
        struct Calendars {
            static var url = "url"
            static var color = "color"
            static var name = "name"
        }
        
        static var teacherRoster = "teacherRoster"
        struct TeacherRoster {
            static var email = "email"
            static var firstName = "firstName"
            static var lastName = "lastName"
            static var isAdmin = "isAdmin"
        }
        
        static var clubs = "clubs"
        struct Club {
            static var name = "name"
            static var contactInfo = "contactInfo"
            static var advisor = "advisor"
            static var location = "location"
            static var president = "president"
            static var time = "time"
            static var vicePresident = "vicePresident"
            static var description = "description"
        }

        static var surveys = "surveys"
        struct Survey {
            static var audience = "audience"
            static var beginDate = "beginDate"
            static var expireDate = "expireDate"
            static var link = "link"
            static var description = "description"
            static var name = "name"
            static var submitter = "submitter"
        }
        
        static var dayCalendar = "dayCalendar"
        struct DayCalendar {
            static var dates = "dates"
            static var todayDescription = "todayDescription"
            static var tomorrowDescription = "tomorrowDescription"
        }
        
        static var events = "events"
        struct Event {
            static var type = "type"
            static var date = "date"
            static var roster = "roster"
            static var location = "location"
            static var name = "name"
            static var checkedIn = "checkedIn"
        }
    }
    
    // These are stored in the User Defaults
    public enum Defaults: String {
        case readSurveys
        case dayCalendar
        case backendLinks
        case frontendLinks
        case resourceLinks
    }
    
    
}
