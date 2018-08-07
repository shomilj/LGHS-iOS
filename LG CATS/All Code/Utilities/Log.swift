//
//  Log.swift
//  Falcon
//
//  Created by Shomil Jain on 6/20/18.
//  Copyright © 2018 Avina Labs. All rights reserved.
//

import Foundation
import Firebase

public class Log {
    static var dateFormat = "yyyy-MM-dd hh:mm:ssSSS"
    static var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = dateFormat
        formatter.locale = Locale.current
        formatter.timeZone = TimeZone.current
        return formatter
    }
    
    static var CODE_ERROR = 5
    static var CODE_WARNING = 4
    static var CODE_WTF = 3
    
    static func logSelection(toScreen screenName: String) {
        Log.i("Logging selection to \(screenName).")
        Analytics.logEvent("ScreenName", parameters: [
            "screen": screenName as NSObject,
            "userType": (UserUtil.userType?.rawValue ?? "unknown") as NSObject
            ])
    }
    
    // call Log.m for method description
    class func m(file: String = #file, line: Int = #line, column: Int = #column, funcName: String = #function) {
        let text = "☎️☎️ METHOD: \(funcName) called! [\(getName(fromFile: file))]"
        print(text)
    }
    
    class func getName(fromFile file: String) -> String {
        let components = file.components(separatedBy: "/")
        let name = components.isEmpty ? "" : components.last!
        let truncated = name.substring(to: name.index(name.endIndex, offsetBy: -6))
        return truncated
    }
    
    class func d(_ message: String, file: String = #file, line: Int = #line, column: Int = #column, funcName: String = #function) {
        let text = "🛠🛠 DEBUG: \(message) [\(getName(fromFile: file))]"
        print(text)
    }
    
    class func i(_ message: String, file: String = #file, line: Int = #line, column: Int = #column, funcName: String = #function) {
        let text = "ℹ️ℹ️ INFO: \(message) [\(getName(fromFile: file))]"
        print(text)
    }
    
    class func wtf(_ message: String, file: String = #file, line: Int = #line, column: Int = #column, funcName: String = #function) {
        let text = "🔥🔥 WTF ERROR: \(message) [\(getName(fromFile: file))]"
        print(text)
        let error = NSError(domain: getName(fromFile: file), code: CODE_WTF, userInfo: [NSLocalizedDescriptionKey: message, NSLocalizedFailureReasonErrorKey: "Occurred in \(funcName) at line \(line) and col \(column).", NSLocalizedRecoverySuggestionErrorKey: "Unknown"])
        Crashlytics.sharedInstance().recordError(error)
    }
    
    class func w(_ message: String, file: String = #file, line: Int = #line, column: Int = #column, funcName: String = #function) {
        let text = "⚠️⚠️ WARNING: \(message) [\(getName(fromFile: file))]"
        print(text)
        let error = NSError(domain: getName(fromFile: file), code: CODE_WARNING,
                            userInfo: [NSLocalizedDescriptionKey: message,
                                       NSLocalizedFailureReasonErrorKey: "Occurred in \(funcName) at line \(line) and col \(column).", NSLocalizedRecoverySuggestionErrorKey: "Unknown"])
        Crashlytics.sharedInstance().recordError(error)
    }
    
    class func e(_ message: String, file: String = #file, line: Int = #line, column: Int = #column, funcName: String = #function) {
        let text = "‼️‼️ ERROR: \(message) [\(getName(fromFile: file))]"
        print(text)
        let error = NSError(domain: getName(fromFile: file), code: CODE_ERROR, userInfo: [NSLocalizedDescriptionKey: message, NSLocalizedFailureReasonErrorKey: "Occurred in \(funcName) at line \(line) and col \(column).", NSLocalizedRecoverySuggestionErrorKey: "Unknown"])
        Crashlytics.sharedInstance().recordError(error)
    }
    
}
