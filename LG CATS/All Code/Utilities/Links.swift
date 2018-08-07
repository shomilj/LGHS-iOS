//
//  Links.swift
//  Falcon
//
//  Created by Shomil Jain on 6/26/18.
//  Copyright © 2018 Avina Labs. All rights reserved.
//

import Foundation
import Firebase

class Links {
    
    // These values match the remoteConfig PLIST file!
    public enum Config: String {
        case linkResources
        case linkBackend
        case linkFrontend
    }
    
    public enum Backend: String {
        case dailyAnnouncementsFeed
        case calendarMainFeed
        case calendarSportsFeed
        case calendarCollegesFeed
        case calendarClubsFeed
        case adminClubListTemplate
        case adminTeacherRosterTemplate
        case adminStudentRosterTemplate
        case adminDayCalendarTemplate
        case eventRosterTemplate
        case feedbackForm
    }
    
    public enum Frontend: String {
        case newsFeed
        case campusMap
        case canvas
        case dayCalendar
        case dailyAnnouncementMessageSubmit
        case dailyAnnouncementJokeSubmit
        case bellSchedule
        case twitterFeed
        case termsAndConditions
        case wetip
        case lgpdWebsite
        case cassyForm
        case additionalHotlines
        case studentDirectory
        case staffDirectory
        case tutoringProgram
        case canvasSupport
        case passwordPortal
        case wifiSupport
        case aeries
        case weather
        case attendance
    }
    
    static func getLinkSheet(fromFile plistName: String) -> [String: String]? {
        if let path = Bundle.main.path(forResource: plistName, ofType: "plist") {
            let dict = NSDictionary(contentsOfFile: path)
            let answer = dict as? [String: String]
            return answer
        } else {
            return nil
        }
    }
    
    // dataUW is the unwrapped string passed in from the file
    public static func parseLinkSheet(fileContentsUW: String?) -> [String: String]? {
        guard let file = fileContentsUW else {
            return nil;
        }
        var tsv = Downloader.parseTSV(fromString: file) ?? []
        // If count = 0 then error parsing. If count = 1 then only header exists.
        if tsv.count < 2 {
            return nil;
        } else {
            tsv.removeFirst()
            var table = [String: String]()
            for row in tsv {
                if row.count != 3 {
                    Log.w("Skipping a table row, invalid size = \(row.count)")
                    continue;
                }
                let key = row[1]
                let link = row[2]
                table[key] = link
            }
            return table
        }
    }

    static func parseGoogleLink(rawLink: String) -> URL? {
        let arrayOfPieces = rawLink.split(separator: "/")
        if let key = arrayOfPieces.max(by: {$1.count > $0.count}) {
            let newString = "https://docs.google.com/spreadsheets/d/\(key)/export?format=tsv"
            return URL(string: newString)
        } else {
            Log.e("Failed to parse Google Link! Raw: \(rawLink)")
            return nil
        }
    }

    public static func getLink(fromKey key: Config, isGoogle: Bool = false) -> URL? {
        if let sheet = getLinkSheet(fromFile: "ConfigLinks"), let value = sheet[key.rawValue] {
            if isGoogle, let url = parseGoogleLink(rawLink: value) {
                Log.i("Successfully found Google-Based configLink - \(key.rawValue).")
                return url
            } else {
                Log.i("Successfully found ConfigLink - \(key.rawValue).")
                return URL(string: value)
            }
        } else {
            Log.e("When fetching a ConfigKey, failed to find a link!")
            return nil
        }
    }

    // TODO: Implement default values
    public static func getLink(fromKey key: Backend, isGoogle: Bool = false) -> URL? {
        guard let keys = UserDefaults.standard.object(forKey: Keys.Defaults.backendLinks.rawValue) as? [String: String] else {
            Log.e("Failed to fetch keys from user defaults!")
            return nil
        }
        if let url = keys[key.rawValue] {
            if isGoogle {
                return parseGoogleLink(rawLink: url)
            } else {
                return URL(string: url)
            }
        } else {
            Log.e("Failed to fetch url for backend string with key: \(key.rawValue)")
            return nil
        }
    }
    
    public static func getLink(fromKey key: Frontend, isGoogle: Bool = false) -> URL? {
        guard let keys = UserDefaults.standard.object(forKey: Keys.Defaults.frontendLinks.rawValue) as? [String: String] else {
            Log.e("Failed to fetch keys from user defaults!")
            return nil
        }
        if let url = keys[key.rawValue] {
            if isGoogle {
                return parseGoogleLink(rawLink: url)
            } else {
                return URL(string: url)
            }
        } else {
            Log.e("Failed to fetch url for frontend string with key: \(key.rawValue)")
            return nil
        }
    }
    
    
}
