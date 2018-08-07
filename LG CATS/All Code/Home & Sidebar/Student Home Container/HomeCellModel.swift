//
//  SHRCellModel.swift
//  Falcon
//
//  Created by Shomil Jain on 6/26/18.
//  Copyright © 2018 Avina Labs. All rights reserved.
//

import Foundation
import UIKit
import Iconic

class HomeCellModel {
    private(set) var mainText: String!
    private(set) var subtitleText: String!
    private(set) var icon: FontAwesomeIcon!
    private(set) var segue: String?
    private(set) var link: String?
    
    public init(main: String, subtitle: String, icon: FontAwesomeIcon, segue: String? = nil, link: String? = nil) {
        self.mainText = main
        self.subtitleText = subtitle
        self.icon = icon
        self.segue = segue
        self.link = link
    }
}
