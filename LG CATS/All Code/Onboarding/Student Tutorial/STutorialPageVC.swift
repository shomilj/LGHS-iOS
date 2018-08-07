//
//  STutorialPageVC.swift
//  Falcon
//
//  Created by Shomil Jain on 6/20/18.
//  Copyright © 2018 Avina Labs. All rights reserved.
//

import UIKit
import Pageboy

protocol STutorialPageDelegate: class {
    func userDidSwipe(toIndex index: Int)
    func pageCountDidLoad(count: Int)
    func setNotificationPageIndex(index: Int)
}

class STutorialPageVC: PageboyViewController {
    
    weak var pageDelegate: STutorialPageDelegate? = nil
    
    var pageControllers = [UIViewController]()
    
    static func getSlide(index: Int, title: String, subtitle: String, imageName: String) -> STutorialSlideVC {
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let viewController = storyboard.instantiateViewController(withIdentifier: "STutorialSlideVC") as! STutorialSlideVC
        viewController.image = UIImage(named: imageName)
        viewController.index = index
        viewController.titleText = title
        viewController.subtitleText = subtitle
        return viewController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.pageControllers = School.getStudentTutorial()
        pageDelegate?.setNotificationPageIndex(index: 3)
        pageDelegate?.pageCountDidLoad(count: pageControllers.count)
        dataSource = self
        delegate = self
    }

}

extension STutorialPageVC: PageboyViewControllerDataSource {
    func numberOfViewControllers(in pageboyViewController: PageboyViewController) -> Int {
        return pageControllers.count
    }
    
    func viewController(for pageboyViewController: PageboyViewController,
                        at index: PageboyViewController.PageIndex) -> UIViewController? {
        return pageControllers[index]
    }
    
    func defaultPage(for pageboyViewController: PageboyViewController) -> PageboyViewController.Page? {
        return nil
    }
}

// MARK: PageboyViewControllerDelegate
extension STutorialPageVC: PageboyViewControllerDelegate {
    
    func pageboyViewController(_ pageboyViewController: PageboyViewController,
                               willScrollToPageAt index: Int,
                               direction: PageboyViewController.NavigationDirection,
                               animated: Bool) {
        
    }
    
    func pageboyViewController(_ pageboyViewController: PageboyViewController,
                               didScrollTo position: CGPoint,
                               direction: PageboyViewController.NavigationDirection,
                               animated: Bool) {
        
    }
    
    func pageboyViewController(_ pageboyViewController: PageboyViewController,
                               didScrollToPageAt index: Int,
                               direction: PageboyViewController.NavigationDirection,
                               animated: Bool) {
        pageDelegate?.userDidSwipe(toIndex: index)
    }
    
    func pageboyViewController(_ pageboyViewController: PageboyViewController,
                               didReloadWith currentViewController: UIViewController,
                               currentPageIndex: PageboyViewController.PageIndex) {
    }
}

