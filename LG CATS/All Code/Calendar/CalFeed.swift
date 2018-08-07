//
//  CalFeed.swift
//  Falcon
//
//  Created by Shomil Jain on 7/26/18.
//  Copyright © 2018 Avina Labs. All rights reserved.
//

import Foundation
import UIKit
import MXLCalendarManager

class CalFeed {
    
    static var Colors = [
        UIColor.green,
        UIColor.blue,
        UIColor.orange,
        UIColor.amethyst,
        UIColor.midnightBlue,
        UIColor.yellow,
        UIColor.brown,
        UIColor.black,
        UIColor.lightGray
    ]
    
    private(set) var name: String!
    private(set) var link: URL!
    private(set) var events: [CalEvent]!
    private(set) var color: UIColor!
    private(set) var isVisible: Bool = true
    
    public init(name: String, link: URL, color: UIColor) {
        self.name = name
        self.link = link
        self.color = color
    }
    
    func show() {
        isVisible = true
    }
    
    func hide() {
        isVisible = false
    }
    
    func setEvents(events: [CalEvent]) {
        self.events = events
    }
    
    public static func parse(feedURL: URL?, color: UIColor, completion: @escaping ([CalEvent]?) -> Void) {
        guard let link = feedURL else {
            Log.e("FeedURL is nil or cannot be cast!")
            completion(nil)
            return;
        }
        
        var events = [CalEvent]()
        
        MXLCalendarManager().scanICSFile(atRemoteURL: link, withCompletionHandler: { (calendarUW, errorUW) in
            if let error = errorUW {
                Log.e("Error while parsing ICS: \(error.localizedDescription)")
                completion(nil)
                return;
            }
            
            guard let mxCalendar = calendarUW else {
                Log.e("Error while parsing ICS: cannot unwrap calendar!")
                completion(nil)
                return;
            }

            for e in mxCalendar.events {
                let event = e as! MXLCalendarEvent
                guard let eventSummary = event.eventSummary, let startDate = event.eventStartDate, let endDate = event.eventEndDate else {
                    Log.w("Found an incomplete event!")
                    continue;
                }
                if endDate < Date() {
                    // Old event!
                    continue;
                }
                let allDay = event.eventIsAllDay
                var location: String? = event.eventLocation
                if location != nil && location!.starts(with: ", ") {
                    location?.removeFirst(2)
                }
                if location == "" {
                    location = nil
                }
                events.append(CalEvent(summary: eventSummary, startDate: startDate, endDate: endDate, allDay: allDay, location: location, tintColor: color))
            }
            
            completion(events)
        })
        
    }
}
