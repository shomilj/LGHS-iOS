//
//  TeacherWelcomeVC.swift
//  Falcon
//
//  Created by Shomil Jain on 7/23/18.
//  Copyright © 2018 Avina Labs. All rights reserved.
//

import UIKit
import Firebase
import GoogleSignIn

class TeacherWelcomeVC: UIViewController, GIDSignInUIDelegate, GIDSignInDelegate {

    @IBOutlet weak var continueButton: UIButton!

    enum LoginError: Int {
        case GIDSignInError = 0
        case UserAuthenticationError = 1
        case AuthRetrieveDataError = 2
        case CurrentUserNilError = 4
        case CurrentUserEmailNilError = 5
        case FailedTeacherListDownloadError = 6
        case TeacherObjectFailureError = 7
        case HomeModelParseFail = 8
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.continueButton.layer.cornerRadius = 8
        self.continueButton.backgroundColor = UIColor.primary
        
        let isRegisteredForRemoteNotifications = UIApplication.shared.isRegisteredForRemoteNotifications
        if isRegisteredForRemoteNotifications {
            Log.i("This user is already registered for push notifications!")
        } else {
            requestNotificationPermission()
        }
        
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().clientID = FirebaseApp.app()?.options.clientID
        GIDSignIn.sharedInstance().hostedDomain = School.DOMAIN_TEACHER
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance().loginHint = "Please sign in with your school-provided Google account."
    }
    
    @IBAction func continueTapped(_ sender: Any) {
        LoadingOverlay.shared.showOverlay(self.view)
        UserUtil.logout()
        GIDSignIn.sharedInstance().signIn()
    }
    
    func requestNotificationPermission() {
        showAlert(message: "When prompted, please allow notifications in order to receive school-wide alerts regarding events, emergencies, and more.", title: "Notifications", image: nil) {
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            appDelegate.askNotificationsPermissions()
        }
    }

    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error?) {
        if let error = error {
            loginError(error: error, code: .GIDSignInError)
            return
        }
        
        guard let authentication = user.authentication else {
            loginError(code: .UserAuthenticationError)
            return;
        }
        let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken, accessToken: authentication.accessToken)
        Auth.auth().signInAndRetrieveData(with: credential) { (authResult, error) in
            if let error = error {
                self.loginError(error: error, code: .AuthRetrieveDataError)
                return
            }
            
            guard let user = Auth.auth().currentUser else {
                self.loginError(code: .CurrentUserNilError)
                return;
            }
            Log.i("""
                NEW USER INFORMATION:
                Display Name: \(user.displayName ?? "unknown")
                Email: \(user.email ?? "unknown")
                Phone: \(user.phoneNumber ?? "unknown")
                Photo: \(String(describing: user.photoURL))
                """)
            // TODO: Check if user signed in with a school account!
            guard let email = user.email else {
                self.loginError(code: .CurrentUserEmailNilError)
                return;
            }
            self.verifyTeacher(email: email)
        }
    }

    func verifyTeacher(email: String) {
        if TeacherList.shared.roster != nil {
            self.handleTeacher(teacher: TeacherList.getTeacher(fromEmail: email))
        } else {
            TeacherList.shared.downloadTeacherList { (success) in
                if success ?? false {
                    self.handleTeacher(teacher: TeacherList.getTeacher(fromEmail: email))
                } else {
                    Log.e("Failed to download teacher list!")
                    self.loginError(code: .FailedTeacherListDownloadError)
                }
            }
        }
    }
    
    func handleTeacher(teacher: Teacher?) {
        if let tea = teacher {
            UserUtil.setUserType(type: .teacher)
            UserUtil.saveTeacher(teacher: tea)
            loginSuccess()
        } else {
            LoadingOverlay.shared.hideOverlayView()
            showError(message: "Please sign in with your school-provided email address ending in \(School.DOMAIN_TEACHER). If this isn't working, please send an email to support for verification.")
        }
    }
    
    func loginSuccess() {
        STHomeModel.updateShared(forType: .teacher) { (success) in
            if success {
                LoadingOverlay.shared.hideOverlayView()
                self.performSegue(withIdentifier: "toTeacherHome", sender: self)
            } else {
                self.loginError(code: .HomeModelParseFail)
            }
        }
    }
    
    func loginError(error: Error? = nil, code: LoginError) {
        Log.e("Failed to sign in user: \(String(describing: error?.localizedDescription)) || \(code.rawValue)")
        DispatchQueue.main.async {
            LoadingOverlay.shared.hideOverlayView()
            self.showError(message: "An error occurred while trying to sign you in. Please try again later or contact support (error code: \(code.rawValue)).")
        }
    }
    
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {
        loginError(error: error, code: .GIDSignInError)
        return;
    }

}
