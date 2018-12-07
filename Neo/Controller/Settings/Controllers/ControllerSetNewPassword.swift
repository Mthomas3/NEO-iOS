//
//  ControllerSetNewPassword.swift
//  Neo
//
//  Created by Thomas Martins on 17/07/2018.
//  Copyright © 2018 Neo. All rights reserved.
//

import UIKit
import TextFieldEffects

class ControllerSetNewPassword: UIViewController {

    @IBOutlet private weak var _fPassword: HoshiTextField!
    @IBOutlet private weak var _sPassword: HoshiTextField!
    @IBOutlet private weak var _nextButton: NextButton!
    private var _colorButton : ColorsButtonOnEditing
    var oldPassword:String = ""

    
    required init(coder: NSCoder) {
        _colorButton = ColorsButtonOnEditing()
        super.init(coder: coder)!
    }
    
    private func handleColorButton(){
        _colorButton.colorsButtonOnEditing(textfields: [_fPassword, _sPassword], button: _nextButton)
    }
    
    @IBAction func fPasswordEditingChanged(_ sender: Any) {
        handleColorButton()
    }
    
    @IBAction func sPasswordEditingChanged(_ sender: Any) {
        handleColorButton()
    }

    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        
        print("ARE WE INSIDE 1")
        
        guard let password = _fPassword.text, !password.isEmpty,
            let passwordConfirm = _sPassword.text, !passwordConfirm.isEmpty else {
                HandleErrors.displayError(message: "You must confirm your password", controller: self)
                print("ARE WE INSIDE 2")
                return false
        }

        if (!password.isEqualToString(find: passwordConfirm)) {
            HandleErrors.displayError(message: "Your password is not equal to the confirmation", controller: self)
            print("ARE WE INSIDE 3")
            return false
        }
        
        var data = ["token": User.sharedInstance.getParameter(parameter: "token"), "email": User.sharedInstance.getEmail(),
                    "previous_password": oldPassword, "new_password": _fPassword.text] as [String : Any]

        ApiManager.performAlamofireRequest(url: ApiRoute.ROUTE_CHANGE_PASSWORD, param: data).done {
            respond in
            print("ARE WE INSIDE 4")
            }.catch {_ in

        }
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.largeTitleDisplayMode = .never
        
        
        print("old password is : \(oldPassword) ")
        
    }
    override func viewDidAppear(_ animated: Bool) {
        _fPassword.becomeFirstResponder()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        _fPassword.resignFirstResponder()
        if #available (iOS 11, *) {
            _fPassword.textContentType = UITextContentType("")
        }
        _fPassword.autocorrectionType = .no
        
    }
}
