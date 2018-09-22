//
//  ControllerPasswordTableView.swift
//  Neo
//
//  Created by Thomas Martins on 09/02/2018.
//  Copyright © 2018 Neo. All rights reserved.
//

import UIKit



class ControllerPasswordTableView: UITableViewController {
    
    @IBOutlet private weak var _oldPasswordField: UITextField!
    private var _uibarbutton : UIBarButtons!
    
    override init(style: UITableViewStyle) {

        super.init(style: style)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        title = "Mot de Passe"
        _uibarbutton = UIBarButtons(navigationItem: navigationItem)
        self.navigationItem.largeTitleDisplayMode = .never
        super.viewDidLoad()
    }
        
    @IBAction func passwordEditingDidBegin(_ sender: Any) {
        
        _uibarbutton.setUpUIBarButtonItemSettings(titleLeft: "Done", titleRight: "Cancel", selectorLeft: #selector(self.tapCancel), selectorRight: (#selector(self.tapDone)), sender: self)
        
    }
    
    @objc func tapCancel() {
        print("cancel")
    }
    
    @objc func tapDone() {
        print("done")
    }
    
    @IBAction func forgotPasswordTriggered(_ sender: Any) {
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
