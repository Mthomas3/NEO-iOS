//
//  CreateConvController.swift
//  Neo
//
//  Created by Nicolas Gascon on 12/05/2018.
//  Copyright © 2018 Neo. All rights reserved.
//

import UIKit
import TextFieldEffects

/*class Circ {
    var name: String?
    var id: Int?
    var email: String?
}*/

class CreateConvController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    @IBOutlet weak var name: HoshiTextField!
    @IBOutlet weak var picker: UIPickerView!
    
    var circles: [Circ] = []
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        picker.delegate = self
        picker.dataSource = self
        
        loadCircles()
    }
    
    func loadCircles() {
        circles.removeAll()
        ApiManager.performAlamofireRequest(url: ApiRoute.ROUTE_ACCOUNT_INFO, param: ["token": User.sharedInstance.getParameter(parameter: "token")]).done {
            accInfoJson in
            let ctcAcc = accInfoJson["content"] as? [String: Any]
            let circlesArr = ctcAcc!["circles"] as? [[String: Any]]
            for idx in 0...(circlesArr?.count)! - 1 {
                let circle = circlesArr![idx]
                
                let c = Circ()
                c.id = circle["id"] as? Int
                c.name = (circle["circle"] as! [String: Any])["name"] as? String
                self.circles.append(c)
            }
            self.picker.reloadAllComponents()
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
    
    @IBAction func backAction(_ sender: Any) {
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    @IBAction func createAction(_ sender: Any) {
        ApiManager.performAlamofireRequest(url: ApiRoute.ROUTE_CONVERSATION_CREATE, param: ["token": User.sharedInstance.getParameter(parameter: "token"), "circle_id": self.circles[picker.selectedRow(inComponent: 0)].id!, "email": name.text!, "text_message": ""]).done {_ in
            self.performSegue(withIdentifier: "backSegue", sender: self)
            
        }.catch { _ in
                //print("Errrrr") //lzzaaaaaa
                HandleErrors.displayError(message: "Erreur pendant la création de la conversation.", controller: self)
        }
    }
    

}
