//
//  NameConvController.swift
//  Neo
//
//  Created by Nicolas Gascon on 09/07/2018.
//  Copyright © 2018 Neo. All rights reserved.
//

import UIKit
import TextFieldEffects

class NameConvController: ViewController {

    @IBOutlet weak var nameTextField: HoshiTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func backAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func createAction(_ sender: Any) {
        if nameTextField.text?.isEmpty == true {
            HandleErrors.displayError(message: "Vous devez spécifier un nom de conversation", controller: self)
            return
        }
        
        let count = self.navigationController?.viewControllers.count;
        let controller =  self.navigationController?.viewControllers[count! - 2] as! MembersCreateConvController
        let cells = controller.cells
        var checkedCells: [MemberCreateConvCell] = []
        
        for idx in 0..<cells.count {
            if cells[idx].isChecked == true {
                checkedCells.append(cells[idx])
            }
        }
        
        ApiManager.performAlamofireRequest(url: ApiRoute.ROUTE_CONVERSATION_CREATE, param: ["token": User.sharedInstance.getParameter(parameter: "token"), "circle_id": controller.circleId!, "email": checkedCells[checkedCells.count - 1].email!, "text_message": ""]).done { json in
                checkedCells.popLast()
            
                let convId = json["conversation_id"] as! Int
            
            
            
            //GetMEssageInfo to get conversation_id (message_id) in json : Int
            ApiManager.performAlamofireRequest(url: ApiRoute.ROUTE_CONVERSATION_UPDATE, param: ["token": User.sharedInstance.getParameter(parameter: "token"), "conversation_id": json["conversation_id"] as! Int, "conversation_name": self.nameTextField.text!]).done { json in
                
                    for idx in 0..<checkedCells.count {
                        ApiManager.performAlamofireRequest(url: ApiRoute.ROUTE_CONVERSATION_INVITE, param: ["token": User.sharedInstance.getParameter(parameter: "token"), "conversation_id": convId, "email": checkedCells[idx].email!]).done { json in
                            
                            
                            }.catch { _ in
                                HandleErrors.displayError(message: "Erreur pendant la création de la conversation.", controller: self)
                        }
                    }
                    //Change to baseviewcontroller
                    self.navigationController?.popToRootViewController(animated: true)
                }.catch { _ in
                        HandleErrors.displayError(message: "Erreur pendant la création de la conversation.", controller: self)
                }
            
            }.catch { _ in
                HandleErrors.displayError(message: "Erreur pendant la création de la conversation.", controller: self)
        }
    }
    

}
