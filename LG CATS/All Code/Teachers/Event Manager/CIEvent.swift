//
//  CIEvent.swift
//  Black Panther
//
//  Created by Shomil Jain on 5/22/18.
//  Copyright © 2018 Avina Labs. All rights reserved.
//

import Foundation
import Firebase

public struct CIEventStudent {
    var name = String()
    var id = String()
    var checkedIn = false
}

public class CIEvent {
    
    private var eventId: String!
    private var name: String!
    private var students: [CIEventStudent]!
    private var type: CIEventType!
    private var datestamp: String!
    private var location: String!
   
    public enum CIEventType: String {
        case dance
        case sporting
        case show
        case other
    }
    
    static var EventOptions = School.CIEventOptions
    
    public init(eventId: String, name: String, students: [CIEventStudent], type: CIEventType, datestamp: String, location: String) {
        self.eventId = eventId
        self.name = name
        self.students = students
        self.type = type
        self.datestamp = datestamp
        self.location = location
    }
    
    public init() {
        self.eventId = String()
        self.name = String()
        self.students = [CIEventStudent]()
        self.type = CIEventType.other
        self.datestamp = String()
        self.location = String()
    }
    
    public func getName() -> String {
         return name
    }
    
    public func getStudents() -> [CIEventStudent]! {
        return students
    }
    
    public func getId() -> String {
        return eventId
    }
    
    public func getType() -> CIEventType! {
        return type
    }
    
    public func getDatestamp() -> String {
        return datestamp
    }
    
    public func getLocation() -> String {
        return location
    }
    
    public func getDate() -> Date {
        let formatter = DateFormatter()
        formatter.dateFormat = "YYYYMMddHHmm"
        return formatter.date(from: datestamp)!
    }
    
    public enum CIDateFormat: String {
        case month = "MMM"
        case date = "d"
        case day = "E"
        case time = "h:mm a"
        case long = "E, MMM d, yyyy @ h:mm a"
    }
    
    func getCount() -> String {
        let attending = students.count
        var checkedIn = 0
        for stu in students {
            if stu.checkedIn {
                checkedIn += 1
            }
        }
        return "\(checkedIn) of \(attending)"
    }
    
    func getDate(inFormat format: CIDateFormat) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format.rawValue
        return formatter.string(from: getDate())
    }
    
    func checkIn(student id: String) {
        updateStatus(forStudent: id, value: true)
    }
    
    func updateStatus(forStudent studentId: String, value: Bool) {
        Database.database().reference()
            .child(Keys.Database.version)
            .child(Keys.Database.appData)
            .child(Keys.Database.events)
            .child(eventId)
            .child(Keys.Database.Event.roster)
            .child(studentId)
            .child(Keys.Database.Event.checkedIn).setValue(value)
    }
    
    func delete() {
        Database.database().reference()
            .child(Keys.Database.version)
            .child(Keys.Database.appData)
            .child(Keys.Database.events)
            .child(eventId)
            .setValue(nil)
    }
    
    func getDetails() -> String {
        return "\(getDate(inFormat: .day)) \(getDate(inFormat: .time)) • \(location!) • \(students.count) attending"
    }
    
    static func getEventFromInfo(eventInfo: [String: Any], eventId: String) -> CIEvent? {
        guard let name = eventInfo[Keys.Database.Event.name] as? String else {
            Log.w("CIEVENT: Can't find event name!")
            return nil;
        }
        guard let location = eventInfo[Keys.Database.Event.location] as? String else {
            Log.w("CIEVENT: Can't find event location!")
            return nil;
        }
        var date = String()
        if let dateString = eventInfo[Keys.Database.Event.date] as? String {
            date = dateString
        } else if let dateInt = eventInfo[Keys.Database.Event.date] as? Int {
            date = "\(dateInt)"
        } else {
            Log.w("CIEVENT: Can't find date!")
            return nil;
        }
        
        var students = [CIEventStudent]()
        let studentDict = eventInfo[Keys.Database.Event.roster] as? [String: Any] ?? [:]
        for (stuId, subNodeUW) in studentDict {
            if let subNode = subNodeUW as? [String: Any],
                let name = subNode[Keys.Database.Event.name] as? String,
                let checkedIn = subNode[Keys.Database.Event.checkedIn] as? Bool {
                students.append(CIEventStudent(name: name, id: stuId, checkedIn: checkedIn))
            }
        }
        
        let type = eventInfo[Keys.Database.Event.type] as? CIEvent.CIEventType ?? CIEvent.CIEventType.other
        
        let event = CIEvent(eventId: eventId,
                            name: name,
                            students: students,
                            type: type,
                            datestamp: date,
                            location: location)
        
        return event
    }

    // MARK: - Shared Instance & Singleton
    
    // For the shared instance:
    static let shared = CIEvent()
    static let ref = Database.database().reference()
    
    // Database handle
    private var databaseHandle: UInt?
    
    public func getHandle() -> UInt? { return databaseHandle }
    public func setHandle(handle: UInt) { self.databaseHandle = handle }
    
    public static func observeEvent(withId eventId: String) {
        let handle = ref.child(Keys.Database.version)
            .child(Keys.Database.appData)
            .child(Keys.Database.events)
            .child(eventId).observe(.value, with: { snapshot in
                
            Log.i("Observer was called in the EVENTS node!")
            if let dict = snapshot.value as? [String: Any] {
                CIEvent.updateShared(eventId: eventId, dict: dict)
            }
        })
        CIEvent.shared.setHandle(handle: handle)
        print("Handle saved \(String(describing: self.shared.getHandle()))")
    }
    
    public static func endObserving() {
        if let handle = CIEvent.shared.getHandle() {
            Log.d("Got the handle \(handle)")
            self.ref.removeObserver(withHandle: handle)
        }
        CIEvent.clearShared()
    }
    
    static func clearShared() {
        updateShared(withEvent: CIEvent())
    }
    
    static func updateShared(eventId: String, dict: [String: Any]) {
        guard let newEvent = CIEvent.getEventFromInfo(eventInfo: dict, eventId: eventId) else {
            Log.d("Failed to update singleton for course!")
            return;
        }
        updateShared(withEvent: newEvent)
        Downloader.postUpdate()
    }
    
    static func updateShared(withEvent newEvent: CIEvent) {
        shared.eventId =  newEvent.eventId
        shared.name = newEvent.name
        shared.students = newEvent.students
        shared.type = newEvent.type
        shared.datestamp = newEvent.datestamp
        shared.location = newEvent.location
        Downloader.postUpdate()
    }
    
}
