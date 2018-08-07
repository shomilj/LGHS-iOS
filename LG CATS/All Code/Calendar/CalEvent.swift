//
//  CalEvent.swift
//  Falcon
//
//  Created by Shomil Jain on 7/25/18.
//  Copyright © 2018 Avina Labs. All rights reserved.
//

import Foundation
import UIKit

struct CalEvent {
    private(set) var summary: String!
    private(set) var startDate: Date!
    private(set) var endDate: Date!
    private(set) var allDay: Bool!
    private(set) var location: String?
    private(set) var tintColor: UIColor!
    
    public enum DateFormat: String {
        case month = "MMM" // Jul
        case date = "d" // 5
        case day = "E" // Sat
        case header = "E, MMM d, YYYY"
        case time = "h:mm a" // 9:00 AM
        case dayTime = "E, h:mm a"
        case dayOnly = "EEEE, MMM d, yyyy"
        case full = "EEEE, MMM d, yyyy @ h:mm a"
    }
    
    func getStart() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = DateFormat.time.rawValue
        return formatter.string(from: startDate)
    }
    
    func getEnd() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = DateFormat.time.rawValue
        return formatter.string(from: endDate)
    }

    func getStartDate(inFormat format: DateFormat) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format.rawValue
        return formatter.string(from: startDate)
    }

    func getEndDate(inFormat format: DateFormat) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format.rawValue
        return formatter.string(from: endDate)
    }

    public func withoutTime() -> Date {
        return Calendar.current.date(from: Calendar.current.dateComponents([.year, .month, .day], from: startDate))!
    }
}
