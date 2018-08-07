//
//  LinkUtil.swift
//  Falcon
//
//  Created by Shomil Jain on 6/21/18.
//  Copyright © 2018 Avina Labs. All rights reserved.
//

import Foundation
import Firebase

public class LinkUtil {
    
    
    
    // These links are necessary for the app to properly function. These are located in the "Generic Links" spreadsheet. The link to the generic links spreadsheet is accessible through RemoteConfig.
    
    
//    static func getURL(fromKey key: RCLink) -> URL? {
//        guard let value = RemoteConfig.remoteConfig().configValue(forKey: key.rawValue).stringValue else {
//            Log.e("Can't find link for key \(key).")
//            return nil
//        }
//        guard let url = URL(string: value) else {
//            Log.e("Can't parse URL from string \(value) (Key: \(key)).")
//            return nil
//        }
//        return url
//    }
//    
//    static func getSheetURL(fromKey key: RCLink) -> URL? {
//        guard let original = RemoteConfig.remoteConfig().configValue(forKey: key.rawValue).stringValue else {
//            Log.e("Can't find link for key \(key).")
//            return nil
//        }
//        guard let parsed = LinkUtil.parseGoogleLink(rawLink: original) else {
//            Log.e("Can't parse Google Link for url \(original) (Key: \(key)).")
//            return nil
//        }
//        guard let url = URL(string: parsed) else {
//            Log.e("Can't parse URL for parsed link \(parsed) (Key: \(key)).")
//            return nil
//        }
//        return url
//    }

}
