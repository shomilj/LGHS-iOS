//
//  FileUtil.swift
//  Falcon
//
//  Created by Shomil Jain on 7/20/18.
//  Copyright © 2018 Avina Labs. All rights reserved.
//

import Foundation

public class FileUtil {
    
    public static func getStringFromFile(name file: String) -> String? {
        if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            let fileURL = dir.appendingPathComponent(file)
            do {
                let text = try String(contentsOf: fileURL, encoding: .utf8)
                return text
            } catch {
                Log.e("Failed to read file!")
                return nil
            }
        } else {
            Log.e("Cannot find file with name \(file).")
            return nil
        }
    }
}
