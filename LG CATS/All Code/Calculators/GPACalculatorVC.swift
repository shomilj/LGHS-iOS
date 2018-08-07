//
//  GPACalculatorVC.swift
//  Falcon
//
//  Created by Shomil Jain on 7/22/18.
//  Copyright © 2018 Avina Labs. All rights reserved.
//

import UIKit

struct Gradebook {
    var regularClasses: GradeSet = GradeSet()
    var honorsClasses: GradeSet = GradeSet()
}

struct GradeSet {
    var numA: Int = 0
    var numB: Int = 0
    var numC: Int = 0
    var numD: Int = 0
    var numF: Int = 0
}

class GPACalculatorVC: UIViewController {

    var grades: Gradebook = Gradebook()
    var steppers: [UIStepper] = []
    
    @IBOutlet weak var regAL: UILabel!
    @IBOutlet weak var regBL: UILabel!
    @IBOutlet weak var regCL: UILabel!
    @IBOutlet weak var regDL: UILabel!
    @IBOutlet weak var regFL: UILabel!
    
    @IBOutlet weak var honAL: UILabel!
    @IBOutlet weak var honBL: UILabel!
    @IBOutlet weak var honCL: UILabel!
    @IBOutlet weak var honDL: UILabel!
    @IBOutlet weak var honFL: UILabel!
    
    @IBOutlet weak var regAS: UIStepper!
    @IBOutlet weak var regBS: UIStepper!
    @IBOutlet weak var regCS: UIStepper!
    @IBOutlet weak var regDS: UIStepper!
    @IBOutlet weak var regFS: UIStepper!
    
    @IBOutlet weak var honAS: UIStepper!
    @IBOutlet weak var honBS: UIStepper!
    @IBOutlet weak var honCS: UIStepper!
    @IBOutlet weak var honDS: UIStepper!
    @IBOutlet weak var honFS: UIStepper!
    
    @IBAction func aeriesTapped(_ sender: Any) {
        openLink(withURL: Links.getLink(fromKey: .aeries))
    }
    
    @IBAction func regASC(_ sender: UIStepper) {
        regAL.text = Int(sender.value).description
        grades.regularClasses.numA = Int(sender.value)
    }
    @IBAction func regBSC(_ sender: UIStepper) {
        regBL.text = Int(sender.value).description
        grades.regularClasses.numB = Int(sender.value)
    }
    @IBAction func regCSC(_ sender: UIStepper) {
        regCL.text = Int(sender.value).description
        grades.regularClasses.numC = Int(sender.value)
    }
    @IBAction func regDSC(_ sender: UIStepper) {
        regDL.text = Int(sender.value).description
        grades.regularClasses.numD = Int(sender.value)
    }
    @IBAction func regFSC(_ sender: UIStepper) {
        regFL.text = Int(sender.value).description
        grades.regularClasses.numF = Int(sender.value)
    }
    //Honors Classes
    @IBAction func honASC(_ sender: UIStepper) {
        honAL.text = Int(sender.value).description
        grades.honorsClasses.numA = Int(sender.value)
    }
    @IBAction func honBSC(_ sender: UIStepper) {
        honBL.text = Int(sender.value).description
        grades.honorsClasses.numB = Int(sender.value)
    }
    @IBAction func honCSC(_ sender: UIStepper) {
        honCL.text = Int(sender.value).description
        grades.honorsClasses.numC = Int(sender.value)
    }
    @IBAction func honDSC(_ sender: UIStepper) {
        honDL.text = Int(sender.value).description
        grades.honorsClasses.numD = Int(sender.value)
    }
    @IBAction func honFSC(_ sender: UIStepper) {
        honFL.text = Int(sender.value).description
        grades.honorsClasses.numF = Int(sender.value)
    }
    
    @IBAction func calcButton(_ sender: AnyObject) {
        Log.logSelection(toScreen: "Calculated GPA")

        let regA : Double = Double(grades.regularClasses.numA)
        let regB : Double = Double(grades.regularClasses.numB)
        let regC : Double = Double(grades.regularClasses.numC)
        let regD : Double = Double(grades.regularClasses.numD)
        let regF : Double = Double(grades.regularClasses.numF)
        let honA : Double = Double(grades.honorsClasses.numA)
        let honB : Double = Double(grades.honorsClasses.numB)
        let honC : Double = Double(grades.honorsClasses.numC)
        let honD : Double = Double(grades.honorsClasses.numD)
        let honF : Double = Double(grades.honorsClasses.numF)
        let numclasses = regA + regB + regC + regD + regF + honA + honB + honC + honD + honF
        let points = regA * 4 + regB * 3 + regC * 2 + regD + honA * 5 + honB * 4 + honC * 3 + honD
        
        if numclasses == 0 {
            showAlert(message: "Please enter one or more values to calculate your GPA.")
        } else {
            let gpa = (points / numclasses)
            showAlert(message: "Your GPA is: \(gpa.roundTo(places: 3))")
        }
    }
    
    func clearSteppers() {
        for stepper in steppers {
            stepper.value = 0
        }
        grades = Gradebook()
    }
    
    @IBOutlet weak var openGradePortalButton: UIButton!
    @IBOutlet weak var calculateButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        steppers = [regAS, regBS, regCS, regDS, regFS, honAS, honBS, honCS, honDS, honFS]
        [regAL, regBL, regCL, regDL, regFL, honAL, honBL, honCL, honDL, honFL].forEach { (label) in
            label?.text = "0"
        }
        for stepper in steppers {
            stepper.wraps = true
            stepper.autorepeat = true
            stepper.maximumValue = 50
            stepper.tintColor = UIColor.primary
        }
        openGradePortalButton.tintColor = UIColor.primary
        calculateButton.tintColor = UIColor.primary
    }
}
