//
//  HandleErrors.swift
//  Neo
//
//  Created by Thomas Martins on 11/11/2017.
//  Copyright © 2017 Neo. All rights reserved.
//

import Foundation
import UIKit


class HandleErrors{
    
    private func createAlert(title: String, message: String) -> UIAlertController{
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
        
        return alert
    }
    
    /* Display an alert with the error message */
    
    public static func displayError(message: String, controller: UIViewController){
        
        controller.present(HandleErrors().createAlert(title: "An error occured", message: message), animated: true, completion: nil)
        
    }
    
}

