//
//  STutorialSlideVC.swift
//  Falcon
//
//  Created by Shomil Jain on 6/20/18.
//  Copyright © 2018 Avina Labs. All rights reserved.
//

import UIKit

class STutorialSlideVC: UIViewController {

    var image: UIImage!
    var titleText: String!
    var subtitleText: String!
    var index: Int!
        
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.imageView.image = image
        self.titleLabel.text = titleText
        self.subtitleLabel.text = subtitleText
    }

}
