//
//  ControllerTableViewAccount.swift
//  Neo
//
//  Created by Thomas Martins on 03/02/2018.
//  Copyright © 2018 Neo. All rights reserved.
//

import UIKit

class ControllerTableViewAccount: UITableViewController {

    @IBOutlet private weak var FirstName: UITextField!
    @IBOutlet private weak var LastName: UITextField!
    @IBOutlet private weak var Email: UITextField!
    
    private var _uiBarButton : UIBarButtons!
    
    override func viewDidLoad() {
        title = "Compte"
        _uiBarButton = UIBarButtons(navigationItem: navigationItem)
        self.navigationItem.largeTitleDisplayMode = .never
        self.clearsSelectionOnViewWillAppear = false
        super.viewDidLoad()
    }
    
    @IBAction func UserNameEditingBegin(_ sender: Any) {
        _uiBarButton.setUpUIBarButtonItemSettings(titleLeft: "Cancel", titleRight: "Done", selectorLeft: #selector(tapCancel), selectorRight: #selector(tapDone), sender: self)
    }
    
    @IBAction func LastNameEditingBegin(_ sender: Any) {
        _uiBarButton.setUpUIBarButtonItemSettings(titleLeft: "Cancel", titleRight: "Done", selectorLeft: #selector(tapCancel), selectorRight: #selector(tapDone), sender: self)
    }
    
    @IBAction func EmailEditingBegin(_ sender: Any) {
       _uiBarButton.setUpUIBarButtonItemSettings(titleLeft: "Cancel", titleRight: "Done", selectorLeft: #selector(tapCancel), selectorRight: #selector(tapDone), sender: self)
    }
    
    private func fieldEdited() -> [String: String] {
        if (LastName?.text != User.sharedInstance.getParameter(parameter: "lname")) {
            return ["lname" : LastName.text!]
        }
        else if (FirstName?.text != User.sharedInstance.getParameter(parameter: "fname")) {
            return ["fname": FirstName.text!]
        }
        else if (Email?.text != User.sharedInstance.getParameter(parameter: "email")) {
            return ["email" : Email.text!]
        }
        return ["":""]
    }

    
    @objc func tapCancel () {
        
        resetUIBarButton()
    }
    
    
    @objc func tapDone() {
        
        let fieldUpdated = fieldEdited()
        
        if (!fieldUpdated.values.isEmpty) {
            
            print("the dic got is =\(User.sharedInstance.getUserInformation())")
            User.sharedInstance.setUserInformations(newValue: fieldUpdated)
            ApiManager.performAlamofireRequest(url: ApiRoute.ROUTE_MODIFY, param: User.sharedInstance.getUserInformation()).done {
                _ in
                }.catch { _ in
                    HandleErrors.displayError(message: "Une erreur est survenue", controller: self)
            }
        }
        resetUIBarButton()
    }
    
    private func resetUIBarButton(){
        LastName.endEditing(true)
        FirstName.endEditing(true)
        Email.endEditing(true)
        navigationItem.leftBarButtonItem = nil
        navigationItem.rightBarButtonItem = nil
    }
    
    override func viewWillAppear(_ animated: Bool) {
        FirstName.text = User.sharedInstance.getParameter(parameter: "fname")
        LastName.text = User.sharedInstance.getParameter(parameter: "lname")
        Email.text = User.sharedInstance.getParameter(parameter: "email")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}
