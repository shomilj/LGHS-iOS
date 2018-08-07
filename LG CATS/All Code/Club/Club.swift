//
//  Club.swift
//  Falcon
//
//  Created by Shomil Jain on 7/22/18.
//  Copyright © 2018 Avina Labs. All rights reserved.
//

import Foundation
import Firebase

struct ParsedClubs {
    private(set) var clubs: [Club]?
    private(set) var error: String?
}

struct Club {
    private(set) var name: String!
    private(set) var president: String!
    private(set) var vicePresident: String!
    private(set) var location: String!
    private(set) var time: String!
    private(set) var advisor: String!
    private(set) var description: String!
    private(set) var contactInfo: String!
    
    struct TableIndex {
        static var name = 0
        static var president = 1
        static var vicePresident = 2
        static var location = 6
        static var time = 5
        static var advisor = 3
        static var description = 7
        static var contactInfo = 4
    }
    
    static func parseClubs(fromTSV tsv: [[String]]) -> ParsedClubs {
        var table = tsv
        table.removeFirst()
        var clubs: [Club] = []
        for (rowNumber, row) in table.enumerated() {
            if row.count != 8 {
                return ParsedClubs(clubs: nil, error: "Please check row \(rowNumber + 1) of your spreadsheet. We expected 8 columns but received \(row.count) instead.")
            }
            clubs.append(Club(name: row[TableIndex.name],
                              president: row[TableIndex.president],
                              vicePresident: row[TableIndex.vicePresident],
                              location: row[TableIndex.location],
                              time: row[TableIndex.time],
                              advisor: row[TableIndex.advisor],
                              description: row[TableIndex.description],
                              contactInfo: row[TableIndex.contactInfo]))
        }
        return ParsedClubs(clubs: clubs, error: nil)
    }
    
    static func upload(clubs: [Club]) {
        var dict = [String: Any]()
        for club in clubs {
            dict[UUID().uuidString] = [
                Keys.Database.Club.name: club.name,
                Keys.Database.Club.president: club.president,
                Keys.Database.Club.vicePresident: club.vicePresident,
                Keys.Database.Club.location: club.location,
                Keys.Database.Club.time: club.time,
                Keys.Database.Club.advisor: club.advisor,
                Keys.Database.Club.description: club.description,
                Keys.Database.Club.contactInfo: club.contactInfo
            ]
        }
        
        Database.database().reference()
            .child(Keys.Database.version)
            .child(Keys.Database.appData)
            .child(Keys.Database.clubs).setValue(dict)
    }
    
    static func parseClubs(fromDict dict: [String: [String: String]]) -> [Club] {
        var clubs = [Club]()
        for (_, clubData) in dict {
            guard let name = clubData[Keys.Database.Club.name] else {
                Log.w("Failed to find club name!")
                continue;
            }
            guard let advisor = clubData[Keys.Database.Club.advisor] else {
                Log.w("Failed to find club advisor!")
                continue;
            }
            guard let contactInfo = clubData[Keys.Database.Club.contactInfo] else {
                Log.w("Failed to find club contactInfo!")
                continue;
            }
            guard let location = clubData[Keys.Database.Club.location] else {
                Log.w("Failed to find club location!")
                continue;
            }
            guard let president = clubData[Keys.Database.Club.president] else {
                Log.w("Failed to find club president!")
                continue;
            }
            guard let vicePresident = clubData[Keys.Database.Club.vicePresident] else {
                Log.w("Failed to find club vicePresident!")
                continue;
            }
            guard let time = clubData[Keys.Database.Club.time] else {
                Log.w("Failed to find club time!")
                continue;
            }
            guard let desc = clubData[Keys.Database.Club.description] else {
                Log.w("Failed to find club description!")
                continue;
            }
            clubs.append(Club(name: name, president: president, vicePresident: vicePresident, location: location, time: time, advisor: advisor, description: desc, contactInfo: contactInfo))
        }
        return clubs
    }
    
}
