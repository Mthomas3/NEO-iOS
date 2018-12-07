//
//  ViewControllerInscription.swift
//  Neo
//
//  Created by Thomas Martins on 11/09/2017.
//  Copyright © 2017 Neo. All rights reserved.
//

import TextFieldEffects
import UIKit

class ControllerRegistration: UIViewController {

    @IBOutlet private weak var _username: HoshiTextField!
    @IBOutlet private weak var _familyname: HoshiTextField!
    @IBOutlet weak var _nextButton: NextButton!
    private var _colorButton : ColorsButtonOnEditing
    
    required init(coder: NSCoder) {
        _colorButton = ColorsButtonOnEditing()
        super.init(coder: coder)!
    }
    
    private func handleColorButton(){
        _colorButton.colorsButtonOnEditing(textfields: [_username, _familyname], button: _nextButton)
    }
    
    @IBAction private func usernameEditingChanged(_ sender: Any) {
        handleColorButton()
    }
    
    @IBAction private func familyEditingChanged(_ sender: Any) {
        handleColorButton()
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if identifier.isEqualToString(find: "showEmail"){
            guard let useremail = _username.text, !useremail.isEmpty,
                let familyname = _familyname.text, !familyname.isEmpty else {
                    HandleErrors.displayError(message: "Prénom ou Nom de famille invalide", controller: self)
                    return false
            }
        }
        return true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        guard segue.identifier == "showEmail" else {return}
        
        if segue.destination as? ControllerEmail != nil {
            User.sharedInstance.setUserInformations(fname: (_familyname.text!).removingWhitespaces(), lname: (_username.text!).removingWhitespaces())
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override var prefersStatusBarHidden: Bool{
        return true
    }
    
    @IBAction func unwindToRegistration( segue:UIStoryboardSegue ){
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        _username.becomeFirstResponder()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.view.endEditing(true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        _username.resignFirstResponder()
        _username.autocorrectionType = .no
        _familyname.autocorrectionType = .no
        
        if #available (iOS 11, *) {
            _username.textContentType = UITextContentType("")
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning();
    }
}
