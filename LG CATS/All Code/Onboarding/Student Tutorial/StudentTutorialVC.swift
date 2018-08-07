//
//  StudentTutorialVC.swift
//  Falcon
//
//  Created by Shomil Jain on 6/20/18.
//  Copyright © 2018 Avina Labs. All rights reserved.
//

import UIKit
import Firebase
import GoogleSignIn

class StudentTutorialVC: UIViewController, STutorialPageDelegate, GIDSignInUIDelegate, GIDSignInDelegate {

    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var pageControl: UIPageControl!
    
    var pageContainerView: STutorialPageVC!
    var notificationPageIndex = -1
    var pageCount = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.nextButton.layer.cornerRadius = 8
        self.nextButton.backgroundColor = UIColor.primary
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().clientID = FirebaseApp.app()?.options.clientID
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance().hostedDomain = School.DOMAIN_STUDENT

        GIDSignIn.sharedInstance().loginHint = "Please sign in with your school-provided Google account."
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? STutorialPageVC,
            segue.identifier == "toContainer" {
            vc.pageDelegate = self
            self.pageContainerView = segue.destination as! STutorialPageVC
        }
    }
    
    func pageCountDidLoad(count: Int) {
        pageCount = count
        self.pageControl.numberOfPages = pageCount
    }
    
    func userDidSwipe(toIndex index: Int) {
        self.pageControl.currentPage = index
        if index == pageCount - 1 {
            self.nextButton.setTitle("Log In", for: .normal)
        }
    }
    
    func setNotificationPageIndex(index: Int) {
        self.notificationPageIndex = index
    }
    
    @IBAction func nextTapped(_ sender: Any) {
        if self.nextButton.currentTitle == "Log In" {
            LoadingOverlay.shared.showOverlay(self.view)
            UserUtil.logout()
            GIDSignIn.sharedInstance().signIn()
            return;
        }
        if pageContainerView!.currentIndex == notificationPageIndex {
            requestNotificationPermission()
        }
        if pageContainerView!.currentIndex == pageCount - 2 {
            self.nextButton.setTitle("Log In", for: .normal)
            pageContainerView!.scrollToPage(.next, animated: true)
        } else {
            pageContainerView!.scrollToPage(.next, animated: true)
        }
    }

    func requestNotificationPermission() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.askNotificationsPermissions()
    }
    
    enum LoginError: Int {
        case GIDSignInError = 0
        case UserAuthenticationError = 1
        case AuthRetrieveDataError = 2
        case CurrentUserNilError = 4
        case CurrentUserEmailNilError = 5
        case FailedStudentListDownloadError = 6
        case StudentObjectFailureError = 7
        case HomeModelParseFail = 8
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
            self.verifyStudent(email: email)
        }
    }
    
    func verifyStudent(email: String) {
        if StudentList.shared.roster != nil {
            self.handleStudent(student: StudentList.getStudent(fromEmail: email))
        } else {
            StudentList.shared.downloadStudentList { (success) in
                if success ?? false {
                    self.handleStudent(student: StudentList.getStudent(fromEmail: email))
                } else {
                    Log.e("Failed to download student list!")
                    self.loginError(code: .FailedStudentListDownloadError)
                }
            }
        }
    }
    
    func handleStudent(student: Student?) {
        if let stu = student {
            UserUtil.setUserType(type: .student)
            UserUtil.saveStudent(student: stu)
            loginSuccess()
        } else {
            LoadingOverlay.shared.hideOverlayView()
            showError(message: "Please sign in with your school-provided email address ending in \(School.DOMAIN_STUDENT). If this isn't working, please send a picture of your student ID to support for verification.")
        }
    }
    
    func loginSuccess() {
        STHomeModel.updateShared(forType: .student) { (success) in
            if success {
                LoadingOverlay.shared.hideOverlayView()
                self.performSegue(withIdentifier: "toStudentHome", sender: self)
            } else {
                self.loginError(code: .HomeModelParseFail)
            }
        }
    }
    
    func loginError(error: Error? = nil, code: LoginError) {
        Log.e("Failed to sign in user: \(String(describing: error?.localizedDescription)) || \(code.rawValue)")
        LoadingOverlay.shared.hideOverlayView()
        showError(message: "An error occurred while trying to sign you in. Please try again later or contact support (error code: \(code.rawValue)).")
    }
    
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {
        loginError(error: error, code: .GIDSignInError)
        return;
    }
    
}
