//
//  FinalCalculatorVC.swift
//  Falcon
//
//  Created by Shomil Jain on 7/22/18.
//  Copyright © 2018 Avina Labs. All rights reserved.
//

import UIKit

class FinalCalculatorVC: UIViewController {
    
    @IBOutlet weak var currentGrade: UITextField!
    @IBOutlet weak var desiredGrade: UITextField!
    @IBOutlet weak var weightFinal: UITextField!
    
    @IBOutlet weak var calculateButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        calculateButton.tintColor = UIColor.primary
    }
    
    @IBAction func calculate(_ sender: Any) {
        Log.logSelection(toScreen: "Calculated Final Grade")
        if let cur = currentGrade.text, let des = desiredGrade.text, let wei = weightFinal.text {
            let c = Double(cur)
            let g = Double(des)
            let w = Double(wei)
            let z = String(format: "%.2f", (((100 * g!) - ((100 - w!) * c!)) / w!))
            
            showAlert(message: "You need a \(z)% percent on the final to get a \(g!)% in the class!")
        } else {
            showAlert(message: "Please enter text in all fields.")
        }
    }
    
}
