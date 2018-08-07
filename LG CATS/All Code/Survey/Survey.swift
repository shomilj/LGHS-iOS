//
//  Survey.swift
//  Falcon
//
//  Created by Shomil Jain on 7/24/18.
//  Copyright © 2018 Avina Labs. All rights reserved.
//

import Foundation
import Firebase

struct Survey {
    var beginTimestamp: Double!
    var expireTimestamp: Double!
    var url: URL!
    var description: String!
    var name: String!
    var submitter: String!
    var audience: String!
    var id: String!
    
    func isCurrent() -> Bool {
        return getStatus() == .active
    }
    
    public enum Status: String {
        case upcoming
        case active
        case expired
    }
    
    func markAsRead() {
        var list = UserDefaults.standard.stringArray(forKey: Keys.Defaults.readSurveys.rawValue) ?? [String]()
        if list.contains(self.id) == false {
            list.append(self.id)
            UserDefaults.standard.set(list, forKey: Keys.Defaults.readSurveys.rawValue)
        }
    }
    
    func hasBeenRead() -> Bool {
        let list = UserDefaults.standard.stringArray(forKey: Keys.Defaults.readSurveys.rawValue) ?? [String]()
        return list.contains(self.id)
    }
    
    public func getStatus() -> Status {
        if beginTimestamp < Date().timeIntervalSince1970 && Date().timeIntervalSince1970 < expireTimestamp {
            return .active
        } else if Date().timeIntervalSince1970 < beginTimestamp {
            return .upcoming
        } else {
            return .expired
        }
    }
    
    func shouldShowToCurrentUser() -> Bool {
        if let user = UserUtil.userType {
            if user == .common {
                return false
            } else if user == .parent {
                return audience.lowercased().contains("parents")
            } else if user == .teacher {
                return audience.lowercased().contains("teachers")
            } else if user == .student {
                if let student = UserUtil.getCurrentStudent() {
                    return audience.contains(student.year)
                }
            }
        }
        return false
    }
    
    static func downloadSurveys(completion: @escaping ([Survey]?) -> Void) {
        Database.database().reference()
            .child(Keys.Database.version)
            .child(Keys.Database.appData)
            .child(Keys.Database.surveys).observeSingleEvent(of: .value) { (snapshot) in
                guard let dict = snapshot.value as? [String: Any] else {
                    Log.e("Failed to download surveys!")
                    completion(nil);
                    return;
                }
                
                var surveys = [Survey]()
                surveys = Survey.parseSurveys(dict: dict)
                var validSurveys = [Survey]()
                for survey in surveys {
                    if survey.isCurrent() && survey.shouldShowToCurrentUser() {
                        validSurveys.append(survey)
                    }
                }
                
                Log.d("There are \(surveys.count) surveys.")
                Log.d("There are \(validSurveys.count) valid surveys.")
                completion(validSurveys)
        }
    }
    
    static func parseSurveys(dict: [String: Any]) -> [Survey] {
        var surveys = [Survey]()
        for (surveyId, surveyDetails) in dict {
            guard let details = surveyDetails as? [String: Any] else {
                Log.w("Cannot find survey dets, skipping.")
                continue;
            }
            guard let audience = details[Keys.Database.Survey.audience] as? String else {
                Log.w("Cannot find survey audience, skipping.")
                continue;
            }
            
            guard let name = details[Keys.Database.Survey.name] as? String else {
                Log.w("Cannot find survey name, skipping.")
                continue;
            }
            
            guard let submitter = details[Keys.Database.Survey.submitter] as? String else {
                Log.w("Cannot find survey submitter, skipping.")
                continue;
            }
            
            guard let desc = details[Keys.Database.Survey.description] as? String else {
                Log.w("Cannot find survey description, skipping.")
                continue;
            }
            
            guard let expireDate = details[Keys.Database.Survey.expireDate] as? Double else {
                Log.w("Cannot find survey expireDate, skipping.")
                continue;
            }
            
            guard let beginDate = details[Keys.Database.Survey.beginDate] as? Double else {
                Log.w("Cannot find survey expireDate, skipping.")
                continue;
            }
            
            guard let link = details[Keys.Database.Survey.link] as? String, let url = URL(string: link) else {
                Log.w("Cannot find survey link, skipping.")
                continue;
            }
            surveys.append(Survey(beginTimestamp: beginDate, expireTimestamp: expireDate, url: url, description: desc, name: name, submitter: submitter, audience: audience, id: surveyId))
        }
        return surveys
    }
}
