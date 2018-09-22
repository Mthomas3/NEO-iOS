//
//  AddMemberToConvController.swift
//  Neo
//
//  Created by Nicolas Gascon on 13/05/2018.
//  Copyright © 2018 Neo. All rights reserved.
//

import UIKit
import TextFieldEffects

class AddMemberToConvController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {

    @IBOutlet weak var picker: UIPickerView!
    
    var circles: [Circ] = []
    
    var convId: Int?
    
    var viewController: UIViewController?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        picker.delegate = self
        picker.dataSource = self
    }
    
    func loadCircles() {
        circles.removeAll()
        ApiManager.performAlamofireRequest(url: "conversation/info", param: ["token": User.sharedInstance.getParameter(parameter: "token"), "conversation_id": convId]).done {
            json in
            let circle = (json["content"] as! [String: Any])["circle"] as! [String:Any]
            
            ApiManager.performAlamofireRequest(url: ApiRoute.ROUTE_CIRCLE_INFO, param: ["token": User.sharedInstance.getParameter(parameter: "token"), "circle_id": circle["id"] as! Int]).done {
                accInfoJson in
                let ctcAcc = accInfoJson["content"] as? [String: Any]
                let circlesArr = ctcAcc!["users"] as? [[String: Any]]
                for idx in 0...(circlesArr?.count)! - 1 {
                    let circle = circlesArr![idx]
                    let user = circle["user"] as! [String: Any]
                    
                    let c = Circ()
                    c.email = user["email"] as? String
                    c.name = user["first_name"] as! String + " " + (user["last_name"] as! String)
                    self.circles.append(c)
                }
                self.picker.reloadAllComponents()
            }
        }
        
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return circles.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return circles[row].name
    }
    
    @IBOutlet weak var backAction: NextButton!
    @IBAction func backAct(_ sender: Any) {
        //print("Back")
        self.navigationController?.popToViewController(viewController!, animated: true)
        //self.parent?.navigationController?.popViewController(animated: true)
        //self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func addAction(_ sender: Any) {
        print(self.circles[picker.selectedRow(inComponent: 0)].email!)
        ApiManager.performAlamofireRequest(url: ApiRoute.ROUTE_CONVERSATION_INVITE, param: ["token": User.sharedInstance.getParameter(parameter: "token"), "conversation_id": convId!, "email": self.circles[picker.selectedRow(inComponent: 0)].email!]).done {_ in
            self.navigationController?.popToViewController(self.viewController!, animated: true)
            
            }.catch { _ in
                //print("Errrrr") //lzzaaaaaa
                HandleErrors.displayError(message: "Erreur pendant l'invitation.", controller: self)
        }
    }
    
}
