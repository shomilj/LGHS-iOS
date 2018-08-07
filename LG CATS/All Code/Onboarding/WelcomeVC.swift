//
//  WelcomeVC.swift
//  Falcon
//
//  Created by Shomil Jain on 6/18/18.
//  Copyright © 2018 Avina Labs. All rights reserved.
//

import UIKit

class WelcomeVC: UIViewController {

    @IBOutlet weak var getStartedButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getStartedButton.layer.cornerRadius = 8
        getStartedButton.backgroundColor = UIColor.primary
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }

}
