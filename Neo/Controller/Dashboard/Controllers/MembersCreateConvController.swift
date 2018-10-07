//
//  MembersCreateConvController.swift
//  Neo
//
//  Created by Nicolas Gascon on 09/07/2018.
//  Copyright © 2018 Neo. All rights reserved.
//

import UIKit

struct Member {
    var email: String = ""
    var fname: String = ""
    var lname: String = ""
    
    init(email: String, fname: String, lname: String) {
        self.email = email
        self.fname = fname
        self.lname = lname
    }
}

class MembersCreateConvController: ViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    var circleId: Int?
    var members: [Member] = []
    var cells: [MemberCreateConvCell] = []

    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        
        //Add borders to collectionView
        
        loadMembers()
    }

    @IBAction func backAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func nextAction(_ sender: Any) {
        var count: Int = 0
        
        for idx in 0..<self.cells.count {
            if self.cells[idx].isChecked {
                count = count + 1
            }
        }
        
        if count == 0 {
            HandleErrors.displayError(message: "Vous devez sélectionner au moins un membre.", controller: self)
        } else {
            self.performSegue(withIdentifier: "showConvName", sender: self)
        }
    }
    
    func loadMembers() {
        /*let count = self.navigationController?.viewControllers.count;
        let controller =  self.navigationController?.viewControllers[count! - 2] as! CreateConvCirclesController
        
        circleId = controller.selectedCircle?.id
        
        ApiManager.performAlamofireRequest(url: ApiRoute.ROUTE_CIRCLE_INFO, param: ["token": User.sharedInstance.getParameter(parameter: "token"), "circle_id": circleId!]).done {
            json in
                let content = json["content"] as! [String: Any]
                let users = content["users"] as! [[String: Any]]
            
                for idx in 0..<users.count {
                    let user = users[idx]["user"] as! [String: Any]
                    let m = Member(email: user["email"] as! String, fname: user["first_name"] as! String, lname: user["last_name"] as! String)
                    if m.email != User.sharedInstance.getEmail() {
                        self.members.append(m)
                    }
                }
            self.collectionView.reloadData()
            
        }*/
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.members.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = self.collectionView.dequeueReusableCell(withReuseIdentifier: "memberCell", for: indexPath) as! MemberCreateConvCell
        cell.setName = self.members[indexPath.row].fname + " " + self.members[indexPath.row].lname
        cell.email = self.members[indexPath.row].email
        self.cells.append(cell)
        return cell
    }
    
    //Add continue to check if one member is selected
}
