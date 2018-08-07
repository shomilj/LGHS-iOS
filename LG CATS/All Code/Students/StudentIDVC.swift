//
//  SIDViewController.swift
//  Falcon
//
//  Created by Shomil Jain on 6/22/18.
//  Copyright © 2018 Avina Labs. All rights reserved.
//

import Foundation
import UIKit
import CoreGraphics
import AVFoundation
import RSBarcodes_Swift

class StudentIDVC: UIViewController {
    
    // Black
    @IBOutlet weak var spacerLabelOne: UILabel!
    
    // Black
    @IBOutlet weak var spacerLabelTwo: UILabel!
    
    // Black, White Text: "High School"
    @IBOutlet weak var highSchoolLabelSubtitle: UILabel!
    
    // Clear, Black Text: "Los Gatos"
    @IBOutlet weak var highSchoolLabelTitle: UILabel!
    
    // Background view: self.view
    @IBOutlet weak var asbLabel: UILabel!
    
    func format() {
        // Attributes
        spacerLabelOne.backgroundColor = UIColor.primaryDark
        spacerLabelTwo.backgroundColor = UIColor.primaryDark
        highSchoolLabelSubtitle.textColor = UIColor.primaryLight
        highSchoolLabelSubtitle.backgroundColor = UIColor.primaryDark
        highSchoolLabelTitle.textColor = UIColor.primaryDark
        highSchoolLabelTitle.backgroundColor = UIColor.clear
        asbLabel.textColor = UIColor.primaryDark
        schoolYearLabel.textColor = UIColor.primaryLight
        schoolYearLabel.backgroundColor = UIColor.primaryDark
        nameLabel.textColor = UIColor.primaryLight
        nameLabel.backgroundColor = UIColor.primaryDark
        idLabel.textColor = UIColor.primaryDark
        gradeLabel.textColor = UIColor.primaryDark
        
        mainBackgroundView.backgroundColor = UIColor.primaryLight
        view.backgroundColor = UIColor.primary
        
        
        
        // Values
        schoolLogoImageView.image = UIImage(named: School.Images.logo.rawValue)!
        highSchoolLabelTitle.text = School.SchoolName.short.rawValue
    }
    
    // White
    @IBOutlet weak var mainBackgroundView: UIView!
    
    @IBOutlet weak var barcodeImageView: UIImageView!
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var idLabel: UILabel!
    @IBOutlet weak var gradeLabel: UILabel!
    @IBOutlet weak var schoolYearLabel: UILabel!
    
    // School logo
    @IBOutlet weak var schoolLogoImageView: UIImageView!
    
    var oldBrightness: CGFloat = 0.5
    
    override func viewDidLoad() {
        super.viewDidLoad()
        format()
        let barcode = ""
        let defaults = UserDefaults.standard
        defaults.set(barcode, forKey: "StudentID")
        
        schoolLogoImageView.layer.borderWidth = 1
        schoolLogoImageView.layer.masksToBounds = false
        schoolLogoImageView.layer.borderColor = UIColor.black.cgColor
        schoolLogoImageView.layer.cornerRadius = schoolLogoImageView.frame.height/2
        schoolLogoImageView.clipsToBounds = true
        schoolYearLabel.text = DayType.getCurrentSchoolYear()
        schoolYearLabel.transform = CGAffineTransform(rotationAngle: CGFloat(-Double.pi/2))

        if let student = UserUtil.getCurrentStudent() {
            self.nameLabel.text = student.fullName
            self.gradeLabel.text = "\(student.getGrade().rawValue)"
            self.idLabel.text = "ID# \(student.id!)"
            let img = RSUnifiedCodeGenerator.shared.generateCode("\(student.id!)", machineReadableCodeObjectType: School.BARCODE_TYPE)
            self.barcodeImageView.image = img
        } else {
            showError(message: "An error occurred while trying to generate your student ID barcode. Please try again later or contact support.", title: "Error") {
                self.dismiss(animated: true, completion: nil)
            }
        }
        
        oldBrightness = UIScreen.main.brightness
        UIScreen.main.brightness = CGFloat(1.0)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        while (UIScreen.main.brightness > oldBrightness) {
            UIScreen.main.brightness = (UIScreen.main.brightness - 0.1)
            usleep(10000)
        }
    }
    
}
