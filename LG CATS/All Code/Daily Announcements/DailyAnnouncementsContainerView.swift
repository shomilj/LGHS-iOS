//
//  DailyAnnouncementsContainerView.swift
//  Falcon
//
//  Created by Shomil Jain on 6/26/18.
//  Copyright © 2018 Avina Labs. All rights reserved.
//

import Foundation
import UIKit

class DAContainerView: UIViewController {
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.navigationController?.navigationBar.backgroundColor = UIColor.primary
        self.navigationController?.navigationBar.barTintColor = UIColor.primary
        self.view.backgroundColor = UIColor.primary
    }
    
}
