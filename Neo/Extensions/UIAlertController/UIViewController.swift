//
//  UIViewController.swift
//  Neo
//
//  Created by Thomas Martins on 13/03/2018.
//  Copyright © 2018 Neo. All rights reserved.
//

import UIKit

extension UIViewController{
    
    func performUIAlert(title: String?, message: String?, actionTitles:[String?], actions:[(UIAlertAction) -> Void]) {
        
        let alert =  UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        for (index, title) in actionTitles.enumerated() {
            let action = UIAlertAction(title: title, style: .default, handler: actions[index])
            alert.addAction(action)
        }
        self.present(alert, animated: true, completion: nil)
    }
}

