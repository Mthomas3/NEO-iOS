//
//  ControllerPassword.swift
//  Neo
//
//  Created by Thomas Martins on 24/09/2017.
//  Copyright © 2017 Neo. All rights reserved.
//

import UIKit
import TextFieldEffects
import Alamofire
import CoreData

import TransitionButton

class ControllerPassword: UIViewController {
    
    @IBOutlet private weak var _password: HoshiTextField!
    @IBOutlet private weak var _passwordConfirmation: HoshiTextField!
    @IBOutlet private weak var _confirmationButton: NextButton!
    private var _colorButton : ColorsButtonOnEditing

    private lazy var _registrationButton: TransitionButton = {
        let button = TransitionButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = CommonFunc.hexStringToUIColor(hex: "#CBCBCB")
        button.setTitle(NSLocalizedString("Connexion", comment: ""), for: .normal)
        button.cornerRadius = 20
        button.spinnerColor = .white
        button.addTarget(self, action: #selector(registrationAction), for: .touchUpInside)
        button.heightAnchor.constraint(equalToConstant: 49).isActive = true
        button.widthAnchor.constraint(equalToConstant: 247).isActive = true
        return button
    }()
    
    required init(coder: NSCoder) {
        _colorButton = ColorsButtonOnEditing()
        super.init(coder: coder)!
    }
    
    override func viewWillAppear(_ animated: Bool) {
        _password.resignFirstResponder()
        
        if #available (iOS 11, *) {
            _password.textContentType = UITextContentType("")
            _passwordConfirmation.textContentType = UITextContentType("")
        }
        _password.autocorrectionType = .no
    }
    
    override func viewDidAppear(_ animated: Bool) {
        _password.becomeFirstResponder()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(_registrationButton)
        _password.becomeFirstResponder()
        
        _registrationButton.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        _registrationButton.centerYAnchor.constraint(equalTo: self.view.centerYAnchor, constant: 70).isActive = true
        
    }
    
    @IBAction func performRegistration(_ sender: NextButton) {
    }
    
    private func handleColorButton(){
        _colorButton.colorsButtonOnEditing(textfields: [_password, _passwordConfirmation], button: _registrationButton)
    }
    
    
    @IBAction func passwordEditingChanged(_ sender: Any) {
        handleColorButton()
    }
    
    
    @IBAction func passwordConfirmationEditingChanged(_ sender: Any) {
        handleColorButton()
    }
    
    
    private func checkInformations() -> Bool {
        guard let password = _password.text, !password.isEmpty, let passwordConfirm = _passwordConfirmation.text, !passwordConfirm.isEmpty else {
            return false
        }
        return password.isEqualToString(find: passwordConfirm)
    }
    
    private func performRegistration() {
        
        if checkInformations() {
           User.sharedInstance.setUserInformations(password: _password.text!);
        } else {
            HandleErrors.displayError(message: "Une erreur est survenue", controller: self)
        }
        
        _ = ApiManager.performAlamofireRequest(url: ApiRoute.ROUTE_CREATE, param: User.sharedInstance.getRegistrationParameters()).done{
            _ in
            ApiManager.performAlamofireRequest(url: ApiRoute.ROUTE_LOGIN, param: User.sharedInstance.getLoginParameters()).done {
                loginResponse in
                User.sharedInstance.setUserInformations(token: loginResponse["token"] as? String)
                
                self._registrationButton.stopAnimation()
                
                self.performSegue(withIdentifier: "segueRegistration", sender: self)
                
                }.catch {_ in
                    HandleErrors.displayError(message: "Le mot de passe ou email est invalide", controller: self)
            }
            }.catch {_ in
                HandleErrors.displayError(message: "Le mot de passe ou email est invalide", controller: self)
        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
    }
    
    override var prefersStatusBarHidden: Bool{
        return true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func registrationAction(_ button: TransitionButton) {
        button.startAnimation()
        
        let qualityOfServiceClass = DispatchQoS.QoSClass.background
        let backgroundQueue = DispatchQueue.global(qos: qualityOfServiceClass)
        backgroundQueue.async(execute: {
            
            var _currentState = false
            
            DispatchQueue.main.async(execute: { () -> Void in
                
                _currentState = self.checkInformations()
                
                if (_currentState) {
                    self.performRegistration()
                    _currentState = true
                } else {
                    button.stopAnimation(animationStyle: .shake, completion: { })
                }
            })
            
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) {
                if (!_currentState) {
                    HandleErrors.displayError(message: "Le mot de passe ou email est invalide", controller: self)
                }
            }
        })
    }
}
