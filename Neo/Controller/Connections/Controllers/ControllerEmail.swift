//
//  ControllerEmail.swift
//  Neo
//
//  Created by Thomas Martins on 24/09/2017.
//  Copyright © 2017 Neo. All rights reserved.
//

import TextFieldEffects
import Alamofire
import UIKit
import SwiftyJSON


class ControllerEmail: UIViewController {
    
    @IBOutlet private weak var _useremail: HoshiTextField!
    @IBOutlet private weak var _nextButton: NextButton!
    private var _colorButton : ColorsButtonOnEditing
    
    required init(coder: NSCoder) {
        _colorButton = ColorsButtonOnEditing()
        super.init(coder: coder)!
    }

    private func handleColorButton(){
        _colorButton.colorsButtonOnEditing(textfields: [_useremail], button: _nextButton)
    }
    
    @IBAction func emailEditingChanged(_ sender: Any) {
        handleColorButton()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        _useremail.becomeFirstResponder()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        _useremail.resignFirstResponder()
        if #available (iOS 11, *) {
            _useremail.textContentType = UITextContentType("")
        }
        _useremail.autocorrectionType = .no
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        _useremail.keyboardType = .emailAddress
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if identifier.isEqualToString(find: "showBirthday"){
            guard let useremail = _useremail.text, !useremail.isEmpty, useremail.isValidEmail() else {
                
                HandleErrors.displayError(message: "Cet email n'est pas valide", controller: self)
                
                return false
            }
            User.sharedInstance.setUserInformations(email: _useremail.text)

           _ = ApiManager.performAlamofireRequest(url: ApiRoute.ROUTE_CHECKEMAIL, param: User.sharedInstance.getEmailParameter()).done {
                result in
            
            if !(JSON(result))["success"].boolValue {
                    HandleErrors.displayError(message: "Cet email est déjà utilisé", controller: self)
                } else {
                    self.performSegue(withIdentifier: "showBirthday", sender: self)
                }
            }
            return false
        }
        return true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard segue.identifier == "showBirthday" else {return}

        if segue.destination as? ControllerBirthday != nil {
            User.sharedInstance.setUserInformations(email: (_useremail.text!).removingWhitespaces())
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.view.endEditing(true);
    }
    
    @IBAction func unwindToEmail( segue:UIStoryboardSegue ){ }
    
    override var prefersStatusBarHidden: Bool{
        return true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
