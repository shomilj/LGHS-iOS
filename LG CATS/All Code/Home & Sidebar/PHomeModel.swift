//
//  PHomeModel.swift
//  Falcon
//
//  Created by Shomil Jain on 7/23/18.
//  Copyright © 2018 Avina Labs. All rights reserved.
//

import Foundation
import UIKit

public class PHomeModel: HomeModel {
    
    private(set) var greeting: String!
    private(set) var dayType: String!
    private(set) var weather: String!
    private(set) var date: String!
    
    static let shared = PHomeModel()

    public func isUpdated() -> Bool {
        return greeting != nil
    }
    
    public static func updateShared(completion: @escaping (Bool) -> Void) {
        shared.greeting = getGreeting(type: .parent)
        shared.dayType = getDayType()
        shared.date = getDate()
        Log.d("Fetching weather...")
        getTemperature { (weatherFetched) in
            Log.d("Fetched weather!")
            self.shared.weather = weatherFetched ?? "Weather @ LGHS >"
            completion(true)
        }
    }

}
