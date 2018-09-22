//
//  UIBarButtons.swift
//  Neo
//
//  Created by Thomas Martins on 09/02/2018.
//  Copyright © 2018 Neo. All rights reserved.
//

import UIKit

class UIBarButtons {
    
    private var _navigationItem : UINavigationItem
    
    init( navigationItem: UINavigationItem) {
        
        _navigationItem = navigationItem
    }
    
    public func setNavigationItem(newNavigationItem: UINavigationItem){ _navigationItem = newNavigationItem }
    
    public func getNavigationItem() -> UINavigationItem { return _navigationItem }
    
    /* Create a Bar Button Item such as "Done" in the navigation bar */
    
    public func createUIBarButtonItem(titleButton: String, sender: Any?) -> UIBarButtonItem {
        return UIBarButtonItem(title: titleButton, style: .plain, target: sender, action: nil)
    }
    
    /* Will create two UIBarButton in the navigation with "Done" and "Cancel" */
    
    public func setUpUIBarButtonItemSettings(titleLeft: String, titleRight: String, selectorLeft: Selector?, selectorRight: Selector?, sender: Any?) {
    
        _navigationItem.rightBarButtonItem = createUIBarButtonItem(titleButton: "Done", sender: sender)
        _navigationItem.leftBarButtonItem = createUIBarButtonItem(titleButton: "Cancel", sender: sender)
        
        _navigationItem.rightBarButtonItem?.action = selectorRight
        _navigationItem.leftBarButtonItem?.action = selectorLeft
        
    
    
    }
}
