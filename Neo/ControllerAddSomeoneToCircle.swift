//
//  ControllerAddSomeoneToCircle.swift
//  Neo
//
//  Created by Thomas Martins on 17/09/2018.
//  Copyright © 2018 Neo. All rights reserved.
//

import UIKit
import TextFieldEffects

class ControllerAddSomeoneToCircle: UIViewController {

    @IBOutlet private weak var _email: HoshiTextField!
    @IBOutlet private weak var _confirmButton: NextButton!
    private var _idCircle = Int()
    
    private var _colorButton : ColorsButtonOnEditing
    
    required init(coder: NSCoder) {
        _colorButton = ColorsButtonOnEditing()
        super.init(coder: coder)!
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        _email.becomeFirstResponder()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        _email.resignFirstResponder()
        _email.autocorrectionType = .no
    }
    
    public func setIdCircle(id: Int) {
        self._idCircle = id
    }
    
    public func getIdCircle() -> Int{
        return self._idCircle
    }
    
    private func handleColorButton(){
        _colorButton.colorsButtonOnEditing(textfields: [_email], button: _confirmButton)
    }
    
    @IBAction func emailEditingChanged(_ sender: Any) {
        handleColorButton()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.view.endEditing(true)
    }
    
    private func endProcessAdding() {
        
       ApiManager.performAlamofireRequest(url: ApiRoute.ROUTE_CIRCLE_INVITE, param: ["token": User.sharedInstance.getParameter(parameter: "token"), "email": _email.text!, "circle_id": self.getIdCircle()]).done {
            jsonData in

            self.performUIAlert(title: "La personne a été ajouté", message: nil, actionTitles: ["Terminer"], actions: [{_ in}])
        
            self.performSegue(withIdentifier: "unwindToCircle", sender: self)
        
            }.catch { _ in
                HandleErrors.displayError(message: "L'email de la personne est introuvable", controller: self)
        }
        
    }
    
    @IBAction func endProcessAddingUser(_ sender: Any) {
        
        guard let user = _email.text, !user.isEmpty else {
            HandleErrors.displayError(message: "Something went wrong", controller: self)
            return
        }
        
        self.endProcessAdding()
        
    }
}
