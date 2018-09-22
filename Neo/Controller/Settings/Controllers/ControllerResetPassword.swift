//
//  ControllerResetPassword.swift
//  Neo
//
//  Created by Thomas Martins on 16/07/2018.
//  Copyright © 2018 Neo. All rights reserved.
//

import UIKit
import TextFieldEffects

class ControllerResetPassword: UIViewController {

    private var _colorButton : ColorsButtonOnEditing
    @IBOutlet private weak var _password: HoshiTextField!
    @IBOutlet private weak var _nextButton: NextButton!
    
    @IBAction func PasswordEditingChanged(_ sender: Any) {
        handleColorButton()
    }
    
    required init(coder: NSCoder) {
        _colorButton = ColorsButtonOnEditing()
        super.init(coder: coder)!
    }
    
    private func handleColorButton(){
        _colorButton.colorsButtonOnEditing(textfields: [_password], button: _nextButton)
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.largeTitleDisplayMode = .never
    }
    
    override func viewDidAppear(_ animated: Bool) {
        _password.becomeFirstResponder()
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        
        guard let password = _password.text, !password.isEmpty else {
                HandleErrors.displayError(message: "Le password que vous avez saisi est invalide", controller: self)
                return false
        }
        
        ApiManager.performAlamofireRequest(url: ApiRoute.ROUTE_LOGIN, param: ["email" : User.sharedInstance.getEmail(), "password": _password.text!] as [String : String]).done
            { response in
                print(response)
                
                self.performSegue(withIdentifier: "segueSetNewPassword", sender: self)
            
            }.catch {_ in
                HandleErrors.displayError(message: "Le mot de passe que vous venez de saisir est invalide", controller: self)
        }
        return false
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.destination is ControllerSetNewPassword {
            let vc = segue.destination as? ControllerSetNewPassword
            vc?.oldPassword = _password.text!
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        _password.resignFirstResponder()
        if #available (iOS 11, *) {
            _password.textContentType = UITextContentType("")
        }
        _password.autocorrectionType = .no
        
    }
    
}
