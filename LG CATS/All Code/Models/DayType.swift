//
//  DayType.swift
//  Falcon
//
//  Created by Shomil Jain on 6/21/18.
//  Copyright © 2018 Avina Labs. All rights reserved.
//

import Foundation
import Firebase

struct ParsedDayTypes {
    private(set) var types: [DayType]?
    private(set) var error: String?
}

public class DayType {
    
    private(set) var dates: [String]!
    private(set) var todayDescription: String!
    private(set) var tomorrowDescription: String!
    
    public init(dates: [String]!, todayDescription: String!, tomorrowDescription: String!) {
        self.dates = dates
        self.todayDescription = todayDescription
        self.tomorrowDescription = tomorrowDescription
    }
    
    static func downloadDayCalendar(completion: @escaping (Bool) -> Void) {
        Database.database().reference()
            .child(Keys.Database.version)
            .child(Keys.Database.appData)
            .child(Keys.Database.dayCalendar)
            .observeSingleEvent(of: .value) { (snapshot) in
                
                guard let list = snapshot.value as? [String: [String: Any]] else {
                    Log.e("Failed to download list of day types!")
                    completion(false)
                    return;
                }
                
                var types = [DayType]()
                for (_, details) in list {
                    guard let dates = details[Keys.Database.DayCalendar.dates] as? [String: String] else {
                        Log.e("No dates associated with this day type!")
                        completion(false)
                        continue;
                    }
                    guard let todayDescription = details[Keys.Database.DayCalendar.todayDescription] as? String else {
                        Log.e("No todayDesc associated with this day type!")
                        continue;
                    }
                    guard let tomorrowDescription = details[Keys.Database.DayCalendar.tomorrowDescription] as? String else {
                        Log.e("No tomorrowDesc associated with this day type!")
                        continue;
                    }
                    types.append(DayType(dates: Array(dates.values), todayDescription: todayDescription, tomorrowDescription: tomorrowDescription))
                }
                // Now, we have an array of day types.
                // We need to save it as a DICTIONARY (a massive one, for sure) to UserDefaults.
                self.saveDayTypes(types: types)
                completion(true)
        }
    }
    
    private static func saveDayTypes(types: [DayType]) {
        var list = [[String: String]]()
        for type in types {
            list.append([Keys.Database.DayCalendar.dates: type.dates.joined(separator: ","),
                               Keys.Database.DayCalendar.todayDescription: type.todayDescription,
                               Keys.Database.DayCalendar.tomorrowDescription: type.tomorrowDescription])
        }
        UserDefaults.standard.set(list, forKey: Keys.Defaults.dayCalendar.rawValue)
    }
    
    static func fetchSavedDayTypes() -> [DayType]? {
        if let list = UserDefaults.standard.array(forKey: Keys.Defaults.dayCalendar.rawValue) as? [[String: String]] {
            var types = [DayType]()
            for dict in list {
                types.append(DayType(dates: dict[Keys.Database.DayCalendar.dates]!.components(separatedBy: ","), todayDescription: dict[Keys.Database.DayCalendar.todayDescription], tomorrowDescription: dict[Keys.Database.DayCalendar.tomorrowDescription]))
            }
            return types
        } else {
            return nil
        }
    }
    
    static func dayTypesExist() -> Bool {
        return UserDefaults.standard.array(forKey: Keys.Defaults.dayCalendar.rawValue) as? [[String: String]] != nil
    }
    
    private static func getMMDDYYToday() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/yyyy"
        let today = formatter.string(from: Date())
        return today
    }
    
    private static func getMMDDYYTomorrow() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/yyyy"
        let today = formatter.string(from: Date().addDays(1))
        return today
    }
    
    // Precondition: userdefaults has saved values!
    static func getToday() -> DayType? {
        let today = getMMDDYYToday()
        if let types = fetchSavedDayTypes() {
            for type in types {
                if type.dates.contains(today) {
                    return type
                }
            }
        }
        return nil
    }
    
    // Precondition: userdefaults has saved values!
    static func getTomorrow() -> DayType? {
        let tomorrow = getMMDDYYTomorrow()
        if let types = fetchSavedDayTypes() {
            for type in types {
                if type.dates.contains(tomorrow) {
                    return type
                }
            }
        }
        return nil
    }
    
    
    // Transfer from GSheets to Firebase logic here
    struct TableIndex {
        static var dayType = 0
        static var todayDescription = 1
        static var tomorrowDescription = 2
        static var dateList = 3
        static var COLUMN_COUNT = 4
    }
    
    static func parseDayTypes(fromTSV tsv: [[String]]) -> ParsedDayTypes {
        var table = tsv
        table.removeFirst()
        var types: [DayType] = []
        for (rowNumber, row) in table.enumerated() {
            if row.count != TableIndex.COLUMN_COUNT {
                return ParsedDayTypes(types: nil, error: "Please check row \(rowNumber + 1) of your spreadsheet. We expected \(TableIndex.COLUMN_COUNT) columns but received \(row.count) instead.")
            }
            types.append(DayType(dates: row[TableIndex.dateList].components(separatedBy: ","),
                                 todayDescription: row[TableIndex.todayDescription],
                                 tomorrowDescription: row[TableIndex.tomorrowDescription]))
        }
        return ParsedDayTypes(types: types, error: nil)
    }
    
    static func upload(types: [DayType]) {
        var dict = [String: Any]()
        for type in types {
            var dateDict = [String: String]()
            for date in type.dates {
                dateDict[UUID().uuidString] = date
            }
            dict[UUID().uuidString] = [
                Keys.Database.DayCalendar.todayDescription: type.todayDescription,
                Keys.Database.DayCalendar.tomorrowDescription: type.tomorrowDescription,
                Keys.Database.DayCalendar.dates: dateDict
            ]
        }
        
        Database.database().reference()
            .child(Keys.Database.version)
            .child(Keys.Database.appData)
            .child(Keys.Database.dayCalendar).setValue(dict)
    }

    
    // TODO: Move to better place
    static func getCurrentSchoolYear() -> String {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.month, .year], from: Date())
        
        let month = components.month!
        
        // the current year (i.e. 2017)
        let currentYear = components.year!
        
        // the year that the school year ends in. (i.e. 2018)
        var schoolYear = "\(currentYear - 1) - \(currentYear)"
        // the month is >= August
        if month >= 7 {
            // school year string is currentYear - currentYear + 1
            schoolYear = "\(currentYear) - \(currentYear + 1)"
        }
        return schoolYear
    }
    

}
