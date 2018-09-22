//
//  ConvConfigurationSettings.swift
//  Neo
//
//  Created by Nicolas Gascon on 14/05/2018.
//  Copyright © 2018 Neo. All rights reserved.
//

import UIKit

class ConvConfigurationSettings: UITableViewController {
    
    var convId: Int?
    var isNeoB: Bool = false

    @IBOutlet weak var convName: UILabel!
    @IBOutlet weak var isNeo: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
    }
    
    func loadSettings() {
        ApiManager.performAlamofireRequest(url: ApiRoute.ROUTE_CONVERSATION_INFO, param: ["token": User.sharedInstance.getParameter(parameter: "token"), "conversation_id": convId!]).done {
            json in
                if let content = json["content"] as? [String: Any] {
                    //print("-----------------------------")
                    //print(content)
                    //print("-----------------------------")
                    self.convName.text = content["name"] as? String
                    
                    print(content["device_access"])
                    if content["device_access"] as! Bool == true {
                        self.isNeo.text = "Oui"
                        self.isNeoB = true
                    }
                }
            }.catch {
                _ in
                
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func performQuitConversation() {
        ApiManager.performAlamofireRequest(url: ApiRoute.ROUTE_CONVERSATION_QUIT, param: ["token": User.sharedInstance.getParameter(parameter: "token"), "conversation_id": convId!]).done {
            _ in
                self.navigationController?.popToRootViewController(animated: true)
            }.catch {
                _ in
                HandleErrors.displayError(message: "Une erreur est survenue. merci d'essayer à nouveau.", controller: self)
        }
    }
    
    private func handleLogOut() {
        self.performUIAlert(title: "Êtes-vous sûr de vouloir quitter la conversation ?", message: nil, actionTitles: ["Non", "Oui"], actions:
            [{ _ in }, {_ in self.performQuitConversation() }])
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 && indexPath.section == 0 {
            renameConv()
        } else if indexPath.row == 0 && indexPath.section == 3 {
            handleLogOut()
        }
    }
    
    @IBAction func renameConv() {
        // Create the action buttons for the alert.
        let defaultAction = UIAlertAction(title: "Changer le nom", style: .default) { (action) in
            let alertController = UIAlertController(title: "Changer le nom de la conversation", message: "Veuillez préciser le nouveau nom de la conversation", preferredStyle: .alert)
            
            alertController.addTextField { (textField : UITextField!) -> Void in
                textField.placeholder = "Nouveau nom"
            }
            let saveAction = UIAlertAction(title: "Save", style: .default, handler: { alert -> Void in
                let textField = alertController.textFields![0].text
                if textField?.isEmpty == false {
                    ApiManager.performAlamofireRequest(url: ApiRoute.ROUTE_CONVERSATION_UPDATE, param: ["token": User.sharedInstance.getParameter(parameter: "token"), "conversation_id": self.convId!, "conversation_name": textField!]).done {
                        _ in
                        }.catch {
                            _ in
                            HandleErrors.displayError(message: "Une erreur est survenue. merci d'essayer à nouveau.", controller: self)
                    }
                }
            })
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: {
                (action : UIAlertAction!) -> Void in })
            
            alertController.addAction(saveAction)
            alertController.addAction(cancelAction)
            
            self.present(alertController, animated: true, completion: nil)
        }
        
        let cancelAction = UIAlertAction(title: "Annuler", style: .cancel) { (action) in
        }
        
        // Create and configure the alert controller.
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alert.addAction(defaultAction)
        alert.addAction(cancelAction)
        
        self.present(alert, animated: true) {
        }
    }
}
