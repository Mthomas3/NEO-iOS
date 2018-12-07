//
//  SettingViewController.swift
//  Neo
//
//  Created by Thomas Martins on 03/02/2018.
//  Copyright © 2018 Neo. All rights reserved.
//

import UIKit
import CoreData

class SettingViewController: UITableViewController {


    @IBOutlet weak var PersonNames: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.navigationItem.largeTitleDisplayMode = .always
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        PersonNames.text = "\(User.sharedInstance.getParameter(parameter: "fname")) \(User.sharedInstance.getParameter(parameter: "lname"))"
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    private func performLogOutFromApp() {
        ApiManager.performAlamofireRequest(url: ApiRoute.ROUTE_LOGOUT, param: User.sharedInstance.getTokenParameter()).done {
            _ in
                self.performSegue(withIdentifier: "performSegueLogout", sender: self)
            }.catch {
                _ in
                HandleErrors.displayError(message: "une erreur est survenue. merci d'essayer à nouveau ", controller: self)
        }
    }
    
    @IBAction func unwindToSetting(segue:UIStoryboardSegue) {
        print("WE ARE SETTING")
    }

    
    private func handleLogOut() {
        self.performUIAlert(title: "Êtes-vous de vouloir vous déconnecter?", message: nil, actionTitles: ["Non", "Oui"], actions:
            [{ _ in }, {_ in self.performLogOutFromApp()}])
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            print("first row in the setting table view, this row is not used \(indexPath.row)")
        } else if indexPath.row == 2{
            handleLogOut()
        }
    }
}
