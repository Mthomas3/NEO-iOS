//
//  ManagePeopleInCircles.swift
//  Neo
//
//  Created by Thomas Martins on 16/09/2018.
//  Copyright © 2018 Neo. All rights reserved.
//

import UIKit
import SwiftyJSON


class ManagePeopleInCircles: UITableViewController {

    private var circleData : ItemCellData? = nil
    private var peopleInCircle = [""]
    @IBOutlet private var _tableviewcontact: UITableView!
    private let cellId = "cellId"
    private var people: [String]? = nil
    
    public func setCircleData(circleItems: ItemCellData) {
        self.circleData = circleItems
    }
    
    public func getCircleData() -> ItemCellData{ return self.circleData! }
    
    override func viewWillAppear(_ animated: Bool) {
        self.peopleInCircle.removeAll()
        ApiManager.performAlamofireRequest(url: ApiRoute.ROUTE_CIRCLE_INFO, param: ["token": User.sharedInstance.getParameter(parameter: "token"), "circle_id": self.getCircleData().Id]).done {
            data in
            
            let users = JSON(data)["content"]["users"]

            for index in 0...users.count - 1 {
                self.peopleInCircle.append(users[index]["user"]["email"].stringValue)
            }
            self.tableView?.reloadData()
            }.catch {
                _ in
            HandleErrors.displayError(message: "Impossible de charger les contacts", controller: self)
        }
    }
    
    private func setNavigationBarOnTop() {
        
        let rightLeaveCircle:UIBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.done, target: self, action: #selector(self.leaveCircle))
        rightLeaveCircle.setTitleTextAttributes([NSAttributedStringKey.font: UIFont(name: "Font Awesome 5 Pro", size: 17)!], for: .normal)
        
        let rightAddPeople:UIBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.done, target: self, action: #selector(self.addPeopleToCircle))
        rightAddPeople.setTitleTextAttributes([NSAttributedStringKey.font: UIFont(name: "Font Awesome 5 Pro", size: 17)!], for: .normal)
        
        self.navigationItem.setRightBarButtonItems([rightLeaveCircle, rightAddPeople], animated: true)
        
        tableView.tableFooterView = UIView(frame: CGRect.zero)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "Contacts du cercle"
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellId)
        
        tableView.allowsSelection = false
        
        setNavigationBarOnTop()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "addSomeoneToCircle" {
            let lc = segue.destination as? ControllerAddSomeoneToCircle
            lc?.setIdCircle(id: self.getCircleData().Id)
        }
    }
    
    @objc private func addPeopleToCircle() {
        self.performSegue(withIdentifier: "addSomeoneToCircle", sender: self)
    }
    
    private func performLeavingCircle() {
        print("leaving the circle ***")
        
        ApiManager.performAlamofireRequest(url: ApiRoute.ROUTE_CIRCLE_QUIT, param: ["token": User.sharedInstance.getParameter(parameter: "token"), "circle_id": self.getCircleData().Id]).done {
            response in
            self.performSegue(withIdentifier: "unwindToCircles", sender: self)
            }.catch {_ in
                HandleErrors.displayError(message: "something went wrong", controller: self)
        }
    }
    
    @objc private func leaveCircle() {
        
        self.performUIAlert(title: "Êtes-vous sûr de vouloir quitter ce cercle?", message: nil, actionTitles: ["Non", "Oui"], actions:
            [{ _ in }, {_ in self.performLeavingCircle()}])
    }
    
    override func viewWillDisappear(_ animated: Bool) {
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.peopleInCircle.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath)
        
        cell.textLabel?.text = self.peopleInCircle[indexPath.row]
        
        return cell
    }
}
