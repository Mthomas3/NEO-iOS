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

    var _circleData: String? = nil
    var _circleId: Int = 0
    var _dataDisplay = [""]
    @IBOutlet var _tableviewcontact: UITableView!
    
    let cellId = "cellId"
    
    var people: [String]? = nil
    
    private func returnRequestInformation() -> [String: Any]{
        var _data = User.sharedInstance.getTokenParameter()
        _data["circle_id"] = self._circleId
        
        return _data
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self._dataDisplay.removeAll()
        ApiManager.performAlamofireRequest(url: ApiRoute.ROUTE_CIRCLE_INFO, param: self.returnRequestInformation()).done {
            data in
            
            let JSONdata = JSON(data)
            print("CIRCLE_INFO = \(JSONdata)")
        
            var _content = JSONdata["content"]
            var _user = _content["users"]
            
            for index in 0..._user.count - 1 {
                var _tmp = _user[index]["user"]
                var final = _tmp["email"]
                print("fianl string is \(final)")
                self._dataDisplay.append(final.string!)
            }
            self.tableView?.reloadData()
            }.catch {
                _ in
            HandleErrors.displayError(message: "something went wrong", controller: self)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "Contacts du cercle"
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellId)
        
        tableView.allowsSelection = false
        
        let rightLeaveCircle:UIBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.done, target: self, action: #selector(self.leaveCircle))
        rightLeaveCircle.setTitleTextAttributes([NSAttributedStringKey.font: UIFont(name: "Font Awesome 5 Pro", size: 17)!], for: .normal)
        
        let rightAddPeople:UIBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.done, target: self, action: #selector(self.addPeopleToCircle))
        rightAddPeople.setTitleTextAttributes([NSAttributedStringKey.font: UIFont(name: "Font Awesome 5 Pro", size: 17)!], for: .normal)
        
        self.navigationItem.setRightBarButtonItems([rightLeaveCircle, rightAddPeople], animated: true)
        
        tableView.tableFooterView = UIView(frame: CGRect.zero)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "addSomeoneToCircle" {
            let _tmpview = segue.destination as? ControllerAddSomeoneToCircle
            
            _tmpview?.setIdCircle(id: self.getCircleId())
            //loadCircleView?.setCircleData(circleData: self.dataArray[(indexPath?.row)!][0] as! String)
            //loadCircleView?.setCircleId(id: self.dataArray[(indexPath?.row)!][2] as! Int)
        }
    }
    
    @objc private func addPeopleToCircle() {
        self.performSegue(withIdentifier: "addSomeoneToCircle", sender: self)
    }
    
    private func performLeavingCircle() {
        print("leaving the circle ***")
        
        ApiManager.performAlamofireRequest(url: ApiRoute.ROUTE_CIRCLE_QUIT, param: ["token": User.sharedInstance.getParameter(parameter: "token"), "circle_id": self.getCircleId()]).done {
            response in
            print("the response of leaving a circle is \(response)")
            
            self.performSegue(withIdentifier: "unwindToCircles", sender: self)
            
            
            }.catch {_ in
                HandleErrors.displayError(message: "something went wrong", controller: self)
        }
    }
    
    @objc private func leaveCircle() {
        
        self.performUIAlert(title: "Êtes-vous sûr de vouloir quitter ce cercle?", message: nil, actionTitles: ["Non", "Oui"], actions:
            [{ _ in }, {_ in self.performLeavingCircle()}])
    }

    public func setCircleData(circleData: String) {
        _circleData = circleData
        print("Cell selected data is = \(String(describing: _circleData))")
    }
    
    public func getCircleId() -> Int {
        return _circleId
    }
    
    public func setCircleId(id : Int) {
        _circleId = id
        print("Cell selected ID is = \(String(describing: _circleId))")
    }
    
    public func getCircleData() -> String {
        return _circleData!
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        _circleData?.removeAll()
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self._dataDisplay.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath)
        
        let name = self._dataDisplay[indexPath.row]
        
        cell.textLabel?.text = name
        
        return cell
    }
}
