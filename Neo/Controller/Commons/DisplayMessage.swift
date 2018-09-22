//
//  DisplayMessage.swift
//  Neo
//
//  Created by Thomas Martins on 18/09/2018.
//  Copyright © 2018 Neo. All rights reserved.
//

import Foundation
import UIKit

class DisplayMessage {
    
    private func createAlert(title: String, message: String) -> UIAlertController{
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
        
        return alert
    }
    
    /* Display an alert with the message */
    
    public static func displayMessageAsAlert(title: String, message: String, controller: UIViewController){
        
        controller.present(DisplayMessage().createAlert(title: title, message: message), animated: true, completion: nil)
        
    }
    
}
