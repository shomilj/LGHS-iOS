//
//  School.swift
//  Falcon
//
//  Created by Shomil Jain on 7/27/18.
//  Copyright © 2018 Avina Labs. All rights reserved.
//

// Everything in this file is customizable by school.

import Foundation
import UIKit
import Iconic
import AVKit

struct School {
    
    static var SUPPORT_EMAIL = "lghs-support@avinalabs.com"
    
    static var DOMAIN_TEACHER = "lgsuhsd.org"
    static var DOMAIN_STUDENT = "lgsstudent.org"
    
    static var SCHOOL_LATITUDE = 37.221735
    static var SCHOOL_LONGITUDE =  -121.976280
    
    static var HIGH_SCHOOL_SHORT_NAME = "Los Gatos"
    
    static var DAY_CAL_NAME = "Orange/Black Calendar"
    
    
    static var BARCODE_TYPE = AVMetadataObject.ObjectType.code39.rawValue
    
    static var APP_NAME = "LG CATS App"
    public enum SchoolName: String {
        case acronym = "LGHS"
        case short = "Los Gatos"
        case medium = "Los Gatos High"
        case long = "Los Gatos High School"
    }
    
    public enum Images: String {
        case logo = "LGHSLogo.jpg"
    }
    
    static var ToolsTableData =
        ["CALCULATORS":
            [SToolsCellModel(main: "Final Grade Calculator", icon: FontAwesomeIcon._462Icon, segue: "toFinal", link: nil),
             SToolsCellModel(main: "GPA Calculator", icon: FontAwesomeIcon._388Icon, segue: "toGPA", link: nil)],
         "DIRECTORIES":
            [SToolsCellModel(main: "Student Directory", icon: FontAwesomeIcon.userIcon, segue: nil, link: Links.getLink(fromKey: .studentDirectory)!),
             SToolsCellModel(main: "Staff Directory", icon: FontAwesomeIcon.groupIcon, segue: nil, link: Links.getLink(fromKey: .staffDirectory)!),
             SToolsCellModel(main: "Find a Tutor", icon: FontAwesomeIcon.searchIcon, segue: nil, link: Links.getLink(fromKey: .tutoringProgram)!)],
         "TECHNOLOGY SUPPORT":
            [SToolsCellModel(main: "Canvas/G-Suite Help", icon: FontAwesomeIcon.googlePlusSignIcon, segue: nil, link: Links.getLink(fromKey: .canvasSupport)!),
             SToolsCellModel(main: "Connect to LGHS WiFi", icon: FontAwesomeIcon._461Icon, segue: nil, link: Links.getLink(fromKey: .wifiSupport)!),
             SToolsCellModel(main: "Password Reset Portal", icon: FontAwesomeIcon.laptopIcon, segue: nil, link: Links.getLink(fromKey: .passwordPortal)!)],
         "MORNING ANNOUNCEMENTS":
            [SToolsCellModel(main: "Submit an Announcement", icon: FontAwesomeIcon.bullhornIcon, segue: nil, link: Links.getLink(fromKey: .dailyAnnouncementMessageSubmit)!),
             SToolsCellModel(main: "Submit a Joke of the Day", icon: FontAwesomeIcon.smileIcon, segue: nil, link: Links.getLink(fromKey: .dailyAnnouncementJokeSubmit)!)]]
    
    static var CIEventOptions = ["School Dance": "dance",
                                 "Sporting Event (i.e. Football Game)": "sporting",
                                 "Show (i.e. Unplugged)": "show",
                                 "Other": "other"]
    
    static var CIEventAudience = ["Class of 2019", "Class of 2020", "Class of 2021", "Class of 2022", "Custom"]
    
    static func getStudentTutorial() -> [STutorialSlideVC] {
        return [STutorialPageVC.getSlide(index: 0,
                                         title: "Access your student ID",
                                         subtitle: "Check out textbooks, purchase food at the cafeteria, or check in to school events.",
                                         imageName: "CardIcon.png"),
                
                STutorialPageVC.getSlide(index: 1,
                                         title: "Find anything on campus",
                                         subtitle: "Find information on locations, services, courses, colleges, and other resources.",
                                         imageName: "SearchIcon.png"),
                
                STutorialPageVC.getSlide(index: 2,
                                         title: "Read the school news",
                                         subtitle: "Access the latest daily announcements or award-winning El Gato News.",
                                         imageName: "NewsIcon.png"),
                
                STutorialPageVC.getSlide(index: 3,
                                         title: "Stay up to date",
                                         subtitle: "Receive notifications for upcoming school events, modified bell schedules, emergencies, and more.",
                                         imageName: "LoudspeakerIcon.png"),
                
                STutorialPageVC.getSlide(index: 4,
                                         title: "Safety first",
                                         subtitle: "Request SafeRides, access mental health resources, and submit anonymous tips.",
                                         imageName: "WarningIcon.png")]
    }
    
}

extension UIColor {
    static var primary = UIColor(red:0.98, green:0.35, blue:0.00, alpha:1.0)
    static var primaryDark = UIColor.black
    static var primaryLight = UIColor.white
}
