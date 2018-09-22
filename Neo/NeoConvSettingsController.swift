//
//  NeoConvSettingsController.swift
//  Neo
//
//  Created by Nicolas Gascon on 30/06/2018.
//  Copyright © 2018 Neo. All rights reserved.
//

import UIKit

class NeoConvSettingsController: UITableViewController {
    
    var isNeo: Bool = false
    
    @IBOutlet weak var cell: UITableViewCell!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let convConf = self.navigationController?.previousViewController() as! ConvConfigurationSettings
        
        ApiManager.performAlamofireRequest(url: ApiRoute.ROUTE_CONVERSATION_INFO, param: ["token": User.sharedInstance.getParameter(parameter: "token"), "conversation_id": convConf.convId!]).done {
            json in
            if let content = json["content"] as? [String: Any] {
                if content["device_access"] as! Bool == true {
                    self.isNeo = true
                    
                    self.switchLabel()
                }
            }
            }.catch {
                _ in
                
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 1
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let convConf = self.navigationController?.previousViewController() as! ConvConfigurationSettings
        
        self.isNeo = !self.isNeo
        
        if self.isNeo == true {
            ApiManager.performAlamofireRequest(url: ApiRoute.ROUTE_CONVERSATION_NEO_ADD, param: ["token": User.sharedInstance.getParameter(parameter: "token"), "conversation_id": convConf.convId!]).done {
                json in
                }.catch {
                    _ in
                    
            }
        } else {
            ApiManager.performAlamofireRequest(url: ApiRoute.ROUTE_CONVERSATION_NEO_REMOVE, param: ["token": User.sharedInstance.getParameter(parameter: "token"), "conversation_id": convConf.convId!]).done {
                json in
                }.catch {
                    _ in
                    
            }
        }
        switchLabel()
    }
    
    func switchLabel() {
        if self.isNeo == true {
            cell.textLabel?.text = "Enlever NEO"
            cell.textLabel?.textColor = UIColor.init(red: 0.7843, green: 0.4431, blue: 0.4431, alpha: 1)
        } else {
            cell.textLabel?.text = "Ajouter NEO"
            cell.textLabel?.textColor = UIColor.init(red: 0.4431, green: 0.6706, blue: 0.7843, alpha: 1)
        }
        tableView.reloadData()
    }

}

extension UINavigationController {
    
    func previousViewController() -> UIViewController?{
        
        let lenght = self.viewControllers.count
        
        let previousViewController: UIViewController? = lenght >= 2 ? self.viewControllers[lenght-2] : nil
        
        return previousViewController
    }
    
}
