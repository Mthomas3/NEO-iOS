//
//  DataBaseManager.swift
//  Neo
//
//  Created by Thomas Martins on 11/03/2018.
//  Copyright © 2018 Neo. All rights reserved.
//

import UIKit
import CoreData

final class DataBaseManager {
    
    
   static private func loadUser() -> Bool {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Users")
        request.returnsObjectsAsFaults = false
        
        do {
            let results = try context.fetch(request)
            if results.count > 0
            {
                
                return true
            }
        } catch {
            //Process error
            return false
        }
        return false
    }
    

    /// `saveDataToBase` save the data of the user and return true if success otherwise false
    /// - Parameter : Take an AppDelegate as parameter
    /// - Returns: Bool
    static public func saveDataToBase(appDelegate: AppDelegate) -> Bool{
        
        let newUser = NSEntityDescription.insertNewObject(forEntityName: "Users", into: appDelegate.persistentContainer.viewContext)
        
        newUser.setValue(User.sharedInstance.getParameter(parameter: "email"), forKey: "email")
        newUser.setValue(User.sharedInstance.getParameter(parameter: "password"), forKey: "password")
        
        do {  try (appDelegate.persistentContainer.viewContext).save()
                return true
        }
            catch { /*catch the error here */
                return false
        }
    }
}
