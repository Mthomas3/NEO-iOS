//
//  ControllerAddNewCercle.swift
//  Neo
//
//  Created by Thomas Martins on 16/09/2018.
//  Copyright © 2018 Neo. All rights reserved.
//

import UIKit
import TextFieldEffects

class ControllerAddNewCercle: UIViewController {

    @IBOutlet private weak var _nameCircle: HoshiTextField!
    @IBOutlet private weak var _confirmButton: NextButton!
    private var _uibarbutton : UIBarButtons!

    
    private var _colorButton : ColorsButtonOnEditing
    
    required init(coder: NSCoder) {
        _colorButton = ColorsButtonOnEditing()
        super.init(coder: coder)!
    }
    
    @IBAction func nameCircleEditingChanged(_ sender: Any) {
        handleColorButton()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        _nameCircle.becomeFirstResponder()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.view.endEditing(true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        _nameCircle.resignFirstResponder()
        _nameCircle.autocorrectionType = .no
    }
    
    private func handleColorButton(){
        _colorButton.colorsButtonOnEditing(textfields: [_nameCircle], button: _confirmButton)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    private func endProcessCreationCercle() {
        
        ApiManager.performAlamofireRequest(url: ApiRoute.ROUTE_CIRCLE_CREATE, param: ["token": User.sharedInstance.getParameter(parameter: "token"), "name": _nameCircle.text!]).done {
                jsonData in
                self.performSegue(withIdentifier: "unwindToCircles", sender: self)
            }.catch { _ in
            HandleErrors.displayError(message: "Something went wrong", controller: self)
        }
        
    }
    
    @IBAction func endProcessCreatingNewCircle(_ sender: Any) {
        
        guard let user = _nameCircle.text, !user.isEmpty, user.count > 2 else {
            
            HandleErrors.displayError(message: "An error occured", controller: self)
            
            return
        }
        
        self.performUIAlert(title: "Nouveau cercle créer", message: nil, actionTitles: ["Terminer"], actions:
            [{ _ in self.endProcessCreationCercle()}])
        
        return
    }
    
}
