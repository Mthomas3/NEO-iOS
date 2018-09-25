//
//  ControllerContactTabMenu.swift
//  Neo
//
//  Created by Thomas Martins on 11/09/2018.
//  Copyright © 2018 Neo. All rights reserved.
//

import UIKit
import XLPagerTabStrip

struct ItemCellData {
    var Name: String
    var Date: String
    var Id: Int
}

class ControllerContactTabMenu: ButtonBarPagerTabStripViewController {
    private var _uiBarButton : UIBarButtons!
    
    override func viewDidLoad() {
        _uiBarButton = UIBarButtons(navigationItem: navigationItem)
        SetUpNavigationMenu()
        super.viewDidLoad()
        setUpNavigationBar()
        tabBarController?.tabBar.barTintColor = UIColor.white
    }
    
    private func setUpNavigationBar() {
        title = "Cercles"
        let rightFriendRequestBarButtonItem:UIBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.done, target: self, action: #selector(self.createNewCircleView))
        rightFriendRequestBarButtonItem.setTitleTextAttributes([NSAttributedStringKey.font: UIFont(name: "Font Awesome 5 Pro", size: 17)!], for: .normal)
        self.navigationItem.setRightBarButtonItems([rightFriendRequestBarButtonItem], animated: true)
    }
    
    @objc private func createNewCircleView() {
         self.performSegue(withIdentifier: "segueToCreateCircle", sender: self)
    }
    
    private func SetUpNavigationMenu() {
 
        settings.style.buttonBarBackgroundColor = .white
        settings.style.buttonBarItemBackgroundColor = .white
        settings.style.buttonBarItemFont = UIFont(name: "Helvetica", size: 16.0)!
        settings.style.buttonBarItemTitleColor = .gray
        settings.style.buttonBarMinimumLineSpacing = 0
        settings.style.buttonBarItemsShouldFillAvailableWidth = true
        settings.style.buttonBarLeftContentInset = 0
        settings.style.buttonBarRightContentInset = 1
        
        settings.style.selectedBarHeight = 3.0
        settings.style.selectedBarBackgroundColor = CommonFunc.hexStringToUIColor(hex: "#3EB3BE")
        changeCurrentIndexProgressive = { (oldCell: ButtonBarViewCell?, newCell: ButtonBarViewCell?, progressPercentage: CGFloat, changeCurrentIndex: Bool, animated: Bool) -> Void in
            guard changeCurrentIndex == true else { return }
            oldCell?.label.textColor = .gray
            newCell?.label.textColor = CommonFunc.hexStringToUIColor(hex: "#3EB3BE")
        }
    }
    
    override func viewControllers(for pagerTabStripController: PagerTabStripViewController) -> [UIViewController] {
        
        let child1 = UIStoryboard.init(name: "Contacts", bundle: nil).instantiateViewController(withIdentifier: "ChildViewController") as! ChildViewController
        child1.childNumber = "Cercles"
        
        let child2 = UIStoryboard.init(name: "Contacts", bundle: nil).instantiateViewController(withIdentifier: "ChildViewControllerInvitationsCircle") as! ChildViewControllerInvitationsCircle
        child2.childNumber = "Invitations"
    
        return [child1, child2]
    }
    
    @IBAction func unwindToCircles(segue:UIStoryboardSegue) { }

    
}
