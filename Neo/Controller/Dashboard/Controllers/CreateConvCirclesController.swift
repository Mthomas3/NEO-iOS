//
//  CreateConvCirclesController.swift
//  Neo
//
//  Created by Nicolas Gascon on 09/07/2018.
//  Copyright © 2018 Neo. All rights reserved.
//

import UIKit

class Circ {
    var name: String?
    var id: Int?
    var email: String?
}

class CreateConvCirclesController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    @IBOutlet weak var picker: UIPickerView!
    
    var circles: [Circ] = []
    var selectedCircle: Circ?
    
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
        self.navigationController?.popViewController(animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let idx = self.picker.selectedRow(inComponent: 0)
        self.selectedCircle = self.circles[idx]
        print("Test")
    }
}
