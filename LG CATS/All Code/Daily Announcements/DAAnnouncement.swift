//
//  Announcement.swift
//  Falcon
//
//  Created by Shomil Jain on 6/22/18.
//  Copyright © 2018 Avina Labs. All rights reserved.
//

import Foundation

public class DAAnnouncement {
    
    private(set) var pubDate: Date!
    private(set) var date: String!
    private(set) var content: String!
    
    init(date: String, content: String, pubDate: Date) {
        self.date = date
        self.pubDate = pubDate
        self.content = content.replacingOccurrences(of: "   ", with: "\n\n").replacingOccurrences(of: "  ", with: "\n\n")
    }
    
    public func getLastUpdated() -> String {
        let form = DateFormatter()
        form.dateFormat = "MMM d, yyyy | h:mm a zzz"
        return "UPDATED \(form.string(from: pubDate))"
    }
    
}
