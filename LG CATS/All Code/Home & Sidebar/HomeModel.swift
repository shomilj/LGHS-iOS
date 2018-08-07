//
//  HomeModel.swift
//  Falcon
//
//  Created by Shomil Jain on 7/23/18.
//  Copyright © 2018 Avina Labs. All rights reserved.
//

import Foundation
import UIKit
import ForecastIO
import SideMenu

public class HomeModel {
    
    public static func setupMenu(storyboard: UIStoryboard, menuViewId: String, width: CGFloat, navigationController: UINavigationController) {
        // Define the menus
        let menuLeftNavigationController = storyboard.instantiateViewController(withIdentifier: menuViewId) as! UISideMenuNavigationController
        SideMenuManager.default.menuLeftNavigationController = menuLeftNavigationController
        SideMenuManager.default.menuAnimationBackgroundColor = UIColor.primary
        SideMenuManager.default.menuPresentMode = .menuSlideIn
        SideMenuManager.default.menuAnimationFadeStrength = 0.6
        SideMenuManager.default.menuWidth = width
        SideMenuManager.default.menuAnimationBackgroundColor = UIColor.black
        SideMenuManager.default.menuFadeStatusBar = false
        // Enable gestures. The left and/or right menus must be set up above for these to work.
        // Note that these continue to work on the Navigation Controller independent of the view controller it displays!
        SideMenuManager.default.menuAddScreenEdgePanGesturesToPresent(toView: navigationController.view)
        SideMenuManager.default.menuPushStyle = .replace
        SideMenuManager.default.menuAlwaysAnimate = false
        
        SideMenuManager.default.menuAllowPushOfSameClassTwice = false
    }
    
    public static func getDate() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE, MMMM d"
        return dateFormatter.string(from: Date())
    }

    public static func getTemperature(completion: @escaping (String?) -> Void) {
        let client = DarkSkyClient(apiKey: "fc9dc2f6cee79c69dabf3240c26c3d6f")
        client.getForecast(latitude: School.SCHOOL_LATITUDE, longitude: School.SCHOOL_LONGITUDE) { result in
            switch result {
            case .success(let currentForecast, let requestMetadata):
                print("Hi")
                
                if let high = currentForecast.daily?.data.first?.temperatureHigh, let low = currentForecast.daily?.data.first?.temperatureLow {
                    completion("H: \(Int(high.rounded()))°F | L: \(Int(low.rounded()))°F")
                } else {
                    Log.e("Error while fetching weather! \(currentForecast)")
                    completion(nil)
                }
            case .failure(let error):
                Log.e("Error while fetching weather! \(error.localizedDescription)")
                completion(nil)
            }
        }
    }
    
    public static func getDayType() -> String {
        if let type = DayType.getToday() {
            return type.todayDescription
        }
        if let type = DayType.getTomorrow() {
            return type.tomorrowDescription
        }
        return "\(School.DAY_CAL_NAME) >"
        
    }
    
    public static func getGreeting(type: UserUtil.UserType) -> String {
        // let hour = NSCalendar.currentCalendar().component(.Hour, fromDate: NSDate()) Swift 2 legacy
        let hour = Calendar.current.component(.hour, from: Date())
        var greeting = "Good "
        switch hour {
        case 1..<12 : greeting += "morning"
        case 12..<17 : greeting += "afternoon"
        case 17..<24 : greeting += "evening"
        default: greeting = "It's midnight"
        }
        if type == .student {
            return greeting + ","
        } else if type == .parent {
            return greeting + "."
        } else {
            return greeting
        }
    }
    
}
