//
//  FirstVC.swift
//  Falcon
//
//  Created by Shomil Jain on 6/20/18.
//  Copyright © 2018 Avina Labs. All rights reserved.
//

import UIKit
import Firebase
import NVActivityIndicatorView
import PopupDialog
import Crashlytics

class FirstVC: UIViewController {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var schoolNameLabel: UILabel!    
    @IBOutlet weak var activityIndicator: NVActivityIndicatorView!
    
    struct Traces {
        static var screenTimeTrace: Trace!
        static var linkDownloadTrace: Trace!
        static var surveyDownloadTrace: Trace!
        
        static var screenTime = "First VC Screen Time"
        static var linkDownloads = "First VC Link Sheet Download Time"
        static var surveyDownloads = "First VC Survey Download Time"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Log.m()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        
        Traces.screenTimeTrace = Performance.startTrace(name: Traces.screenTime)
        
        self.activityIndicator.color = UIColor.primary
        self.activityIndicator.startAnimating()
        
        checkAuthStatus()
        DispatchQueue.global(qos: .background).async {
            Log.i("Downloading links in the background!")
            self.fetchLinks()
            // TODO: ADD THIS IN A FUTURE VERSION!
            // self.checkForUpdate()
        }
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        Traces.screenTimeTrace.stop()
    }
    
    func fetchLinks() {
        Traces.linkDownloadTrace = Performance.startTrace(name: Traces.linkDownloads)
        // Let's do this first. If the defaults values are empty, then let's fill them with the default values. Otherwise, they go off of the previously cached values.
        if UserDefaults.standard.object(forKey: Keys.Defaults.backendLinks.rawValue) == nil {
            Log.d("Couldn't find saved backend links! Using on-device backup link PLIST.")
            UserDefaults.standard.set(Links.getLinkSheet(fromFile: "BackendLinks"), forKey: Keys.Defaults.backendLinks.rawValue)
        }
        if UserDefaults.standard.object(forKey: Keys.Defaults.frontendLinks.rawValue) == nil {
            Log.d("Couldn't find saved frontend links! Using on-device backup link PLIST.")
            UserDefaults.standard.set(Links.getLinkSheet(fromFile: "FrontendLinks"), forKey: Keys.Defaults.frontendLinks.rawValue)
        }
        
        // We don't need to fetch the Resources page until we land on the resources.
        guard let backendURL = Links.getLink(fromKey: Links.Config.linkBackend, isGoogle: true) else {
            Log.e("Can't find the link to the backend dictionary! This is an error. Stall app launch.")
            return;
        }
        
        guard let frontendURL = Links.getLink(fromKey: Links.Config.linkFrontend, isGoogle: true) else {
            Log.e("Can't find the link to the frontend dictionary! This is an error. Stall app launch.")
            return;
        }
        
        Downloader.downloadTextFile(fromLink: backendURL) { (backendDataUW) in
            Downloader.downloadTextFile(fromLink: frontendURL, completion: { (frontendDataUW) in
                if let backend = Links.parseLinkSheet(fileContentsUW: backendDataUW) {
                    Log.i("Successfully downloaded & saved backend links!")
                    UserDefaults.standard.set(backend, forKey: Keys.Defaults.backendLinks.rawValue)
                } else {
                    Log.i("Attempted download on backend links, but found nothing! Reverting to defaults.")
                    UserDefaults.standard.set(Links.getLinkSheet(fromFile: "BackendLinks"), forKey: Keys.Defaults.backendLinks.rawValue)
                }
                
                if let frontend = Links.parseLinkSheet(fileContentsUW: frontendDataUW) {
                    Log.i("Successfully downloaded & saved frontend links!")
                    UserDefaults.standard.set(frontend, forKey: Keys.Defaults.frontendLinks.rawValue)
                } else {
                    Log.i("Attempted download on frontend links, but found nothing! Reverting to defaults.")
                    UserDefaults.standard.set(Links.getLinkSheet(fromFile: "FrontendLinks"), forKey: Keys.Defaults.frontendLinks.rawValue)
                }
                Log.i("Link fetching is complete! Now performing OTHER downloads.")
                Traces.linkDownloadTrace.stop()
                self.performOtherDownloads()
            })
        }
    }
    
    func performOtherDownloads() {
        Log.i("Performing downloads that do NOT require authentication!")
        // Performs misc. downloads in the background.
        // Let's perform this download in the background.
        ResourceModel.updateSharedFromNetwork(completion: { (success) in
            Log.d("Downloaded Resource Model in background! Success = \(success)")
        })
    }
    
    func performFirebaseDownloads() {
        DispatchQueue.global(qos: .background).async {
            Log.i("Performing downloads from Firebase that require Authentication!")
            DayType.downloadDayCalendar(completion: { (completion) in
                Log.d("Downloaded Day Calendar in background! Success = \(completion)")
            })
            self.downloadSurveys()
        }
    }
    
    func downloadSurveys() {
        Traces.surveyDownloadTrace = Performance.startTrace(name: Traces.surveyDownloads)
        Survey.downloadSurveys { (surveysUW) in
            Traces.surveyDownloadTrace.stop()
            sleep(4)
            let validSurveys = surveysUW ?? [Survey]()
            Log.i("Downloaded surveys! There are \(validSurveys) valid surveys. Checking for Read Status.")
            for survey in validSurveys {
                if survey.hasBeenRead() == false {
                    DispatchQueue.main.async {
                        Log.i("Found a survey that hasn't been read! Attempting to show alert.")
                        if var topController = UIApplication.shared.keyWindow?.rootViewController {
                            while let presentedViewController = topController.presentedViewController {
                                topController = presentedViewController
                            }
                            survey.markAsRead()
                            let popup = PopupDialog(title: "New Message: \(survey.name!)", message: "\(survey.description!)")
                            let buttonOne = CancelButton(title: "View Later") {}
                            let buttonTwo = DefaultButton(title: "View Now") {
                                topController.openLink(withURL: survey.url!)
                            }
                            popup.addButtons([buttonOne, buttonTwo])
                            topController.present(popup, animated: true, completion: nil)
                            Log.i("Presented alert for new survey!")
                        } else {
                            Log.e("Cannot show show survey alert from background! Can't find Nav Controller!")
                        }
                    }
                    return;
                } else {
                    Log.d("Skipped a survey that had been read already - \(survey.name)")
                }
            }
            Log.i("No new surveys available!")
        }
    }
    
    func checkAuthStatus() {
        if let user = Auth.auth().currentUser {
            checkUserType()
            // Now we know user is authenticated
            // Perform other background downloads
            // And initiate crash reporting with UUID!
            Crashlytics.sharedInstance().setUserIdentifier(user.uid)
            self.performFirebaseDownloads()
            return;
        } else {
            goToWelcome()
        }
    }
    
    func checkUserType() {
        Log.m()
        // View types:
        // Student, which shows ID card & student features up front
        // Parent, which shows resources & notifications for grade levels
        // Visitor/Common, which shows student resources up front
        // Teacher, which shows staff tools
        if let type = UserUtil.userType {
            if type == .student {
                // Proceed to student segue
                Log.i("Student pre-authenticated!")
                goToStudent()
            } else if type == .parent {
                Log.i("Parent pre-authenticated!")
                // Proceed to parent segue
                goToParent()
            } else if type == .visitor {
                // Proceed to visitor segue
            } else if type == .teacher {
                Log.i("Teacher pre-authenticated!")
                goToTeacher()
                // Proceed to staff segue
            } else if type == .common {
                // Proceed to common segue
            }
        } else {
            Log.w("User is authenticated, but UserType cannot be found! Log this user out.")
            UserUtil.logout()
            goToWelcome()
        }
    }
    
    func goToParent() {
        Messaging.messaging().subscribe(toTopic: Keys.Topics.parent)
        PHomeModel.updateShared { (success) in
            if success {
                self.performSegue(withIdentifier: "toParentHome", sender: self)
            } else {
                self.showError(message: "An internal error occurred. Please try again later or contact support.")
            }
        }
    }
    
    func goToStudent() {
        Messaging.messaging().subscribe(toTopic: Keys.Topics.student)
        if let year = UserUtil.getCurrentStudent()?.year {
            Messaging.messaging().subscribe(toTopic: "Class of \(year)")
        }
        STHomeModel.updateShared(forType: .student) { (success) in
            if success {
                self.performSegue(withIdentifier: "toStudentHome", sender: self)
            } else {
                self.showError(message: "An internal error occurred. Please try again later or contact support.")
            }
        }
    }
    
    func goToTeacher() {
        Messaging.messaging().subscribe(toTopic: Keys.Topics.teacher)
        STHomeModel.updateShared(forType: .teacher) { (success) in
            if success {
                self.performSegue(withIdentifier: "toTeacherHome", sender: self)
            } else {
                self.showError(message: "An internal error occurred. Please try again later or contact support.")
            }
        }
    }
    
    func goToWelcome() {
        self.performSegue(withIdentifier: "toWelcome", sender: self)
    }
    
    // Update stuff
    
    /*
     func checkForUpdate() {
     Log.i("BACKGROUND: Checking for an update...")
     _ = try? isUpdateAvailable { (update, error) in
     if let error = error {
     Log.w("Error while checking for update! \(error)")
     } else if let update = update {
     if update {
     Log.d("An update is available!")
     self.updateAvailable()
     } else {
     Log.d("User is on latest version of app!")
     }
     }
     }
     }
     
     func updateAvailable() {
     DispatchQueue.main.async {
     if var topController = UIApplication.shared.keyWindow?.rootViewController {
     while let presentedViewController = topController.presentedViewController {
     topController = presentedViewController
     }
     
     let popup = PopupDialog(title: "Update Available", message: "An update is available!")
     let buttonOne = CancelButton(title: "Update Later") {}
     let buttonTwo = DefaultButton(title: "Update Now") {
     
     // TODO (IN FUTURE VERSIONS) – ADD LINK FOR UPDATE!
     
     }
     popup.addButtons([buttonOne])
     topController.present(popup, animated: true, completion: nil)
     } else {
     Log.e("Cannot show update alert from background! Can't find Nav Controller!")
     }
     }
     }
 
    
    enum VersionError: Error {
        case invalidResponse, invalidBundleInfo
    }

    func isUpdateAvailable(completion: @escaping (Bool?, Error?) -> Void) throws -> URLSessionDataTask {
        guard let info = Bundle.main.infoDictionary,
            let currentVersion = info["CFBundleShortVersionString"] as? String,
            let identifier = info["CFBundleIdentifier"] as? String,
            let url = URL(string: "http://itunes.apple.com/lookup?bundleId=\(identifier)") else {
                throw VersionError.invalidBundleInfo
        }
        
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            do {
                if let error = error { throw error }
                guard let data = data else { throw VersionError.invalidResponse }
                let json = try JSONSerialization.jsonObject(with: data, options: [.allowFragments]) as? [String: Any]
                guard let result = (json?["results"] as? [Any])?.first as? [String: Any], let version = result["version"] as? String else {
                    throw VersionError.invalidResponse
                }
                completion(version != currentVersion, nil)
            } catch {
                completion(nil, error)
            }
        }
        task.resume()
        return task
    }
 
 */
}
