//
//  Downloader.swift
//  Falcon
//
//  Created by Shomil Jain on 6/21/18.
//  Copyright © 2018 Avina Labs. All rights reserved.
//

import Foundation
import Firebase
import UIKit

public class Downloader {

    static func parseTSV(fromString stringValue: String) -> [[String]]? {
        var tableData: [[String]] = []
        let array = stringValue.components(separatedBy: "\r\n")
        for item in array {
            tableData.append(item.components(separatedBy: "\t"))
        }
        return tableData
    }
    
    public static func downloadTextFile(fromLink link: URL, completion: @escaping (String?) -> Void) {
        if let content = try? String(contentsOf: link) {
            completion(content)
        } else {
            completion(nil)
        }
    }
    
    public static func postUpdate() {
        let nc = NotificationCenter.default
        nc.post(name: Notification.Name(Keys.Notifications.eventObserverUpdate), object: nil)
    }

}
