//
//  SResourcesModel.swift
//  Falcon
//
//  Created by Shomil Jain on 7/20/18.
//  Copyright © 2018 Avina Labs. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import Iconic

public class ResourceModel {
    
    static var RESOURCE_FILE_NAME = "ResourceTable.txt"
    private(set) var structure: [SResourceHeader]?
    
    static let shared = ResourceModel()
    
    public func isUpdated() -> Bool {
        return structure != nil
    }
    
    public static func updateSharedFromLocal() -> Bool {
        return processDownloadedFile(contents: nil)
    }
    
    public static func updateSharedFromNetwork(completion: @escaping (Bool) -> Void) {
        guard let link = Links.getLink(fromKey: .linkResources, isGoogle: true) else {
            Log.e("Failed to fetch/parse link to resource table.")
            completion(false)
            return;
        }
        Downloader.downloadTextFile(fromLink: link) { (fileUW) in
            completion(processDownloadedFile(contents: fileUW))
            return;
        }
    }
    
    private static func processDownloadedFile(contents fileUW: String?) -> Bool {
        var file = String()
        var newFile = false
        if let f = fileUW {
            Log.i("Successfully downloaded resource table.")
            file = f
            newFile = true
        } else if let defFile = FileUtil.getStringFromFile(name: RESOURCE_FILE_NAME) {
            Log.i("Failed to download resource table. Fetching from saved file.")
            file = defFile
        } else {
            Log.w("Cannot load resource table!")
            return false
        }
        
        guard var table = Downloader.parseTSV(fromString: file) else {
            Log.e("Failed to parse resources table! Check format.")
            return false
        }
        table.removeFirst()
        
        var i = 0
        var answer = [SResourceHeader]()
        
        while i < table.count {
            let row = table[i]
            if row.count != 3 || row.contains("") {
                i += 1;
                continue;
            }
            if URL(string: row[1]) == nil {
                // This is a header!
                let headerName = row[0]
                let headerIcon = row[2]
                let headerDescription = row[1]
                
                var children = [SResourceChild]()
                i += 1;
                while (i < table.count && URL(string: table[i][1]) != nil) {
                    children.append(SResourceChild(name: table[i][0], iconName: table[i][2], link: table[i][1]))
                    i += 1;
                }
                answer.append(SResourceHeader(name: headerName, iconName: headerIcon, description: headerDescription, children: children))
            } else {
                Log.e("Failed to process resource table - Started with a non-header @ i=\(i)")
                return false
            }
        }
        
        self.shared.structure = answer

        // Now that we've downloaded a file from the network, we can overwrite the file we have saved locally.
        if newFile {
            Log.d("We downloaded a new resource table! Let's try to save it.")
            if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
                let fileURL = dir.appendingPathComponent(RESOURCE_FILE_NAME)
                do {
                    try file.write(to: fileURL, atomically: false, encoding: .utf8)
                    Log.i("Successfully downloaded and saved resource table!")
                } catch {
                    Log.e("Error occurred while saving new resource table!")
                }
            } else {
                Log.e("Error while saving resource table – can't find path!")
            }
        }

        return true;
    }

}

public class SResourceHeader {
    private(set) var name: String!
    private(set) var description: String!
    private(set) var iconName: String!
    private(set) var children: [SResourceChild]!
    
    public init(name: String, iconName: String, description: String, children: [SResourceChild]) {
        self.name = name
        self.iconName = iconName
        self.children = children
        self.description = description
    }
}

public class SResourceChild {
    private(set) var name: String!
    private(set) var link: String!
    private(set) var iconName: String?
    
    public init(name: String, iconName: String?, link: String) {
        self.name = name
        self.iconName = iconName
        self.link = link
    }
}
