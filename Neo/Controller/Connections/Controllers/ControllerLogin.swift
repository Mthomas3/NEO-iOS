//
//  ViewControllerConnection.swift
//  Neo
//
//  Created by Thomas Martins on 10/09/2017.
//  Copyright © 2017 Neo. All rights reserved.
//

import UIKit
import TextFieldEffects
import Alamofire
import CoreData

import PromiseKit
import TransitionButton

class ControllerLogin: UIViewController {
    
    let __DEVELOPPEMENT__ = false
    
    @IBOutlet private weak var _username: HoshiTextField!
    @IBOutlet private weak var _password: HoshiTextField!
    private var _colorButton : ColorsButtonOnEditing

    private lazy var loginButton: TransitionButton = {
        let button = TransitionButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = CommonFunc.hexStringToUIColor(hex: "#CBCBCB")
        button.setTitle(NSLocalizedString("Connexion", comment: ""), for: .normal)
        button.cornerRadius = 20
        button.spinnerColor = .white
        button.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
        button.heightAnchor.constraint(equalToConstant: 49).isActive = true
        button.widthAnchor.constraint(equalToConstant: 247).isActive = true
        return button
    }()
    
    required init(coder: NSCoder) {
        _colorButton = ColorsButtonOnEditing()
        super.init(coder: coder)!
    }
    
    private func handleColorButton(){
        _colorButton.colorsButtonOnEditing(textfields: [_username, _password], button: loginButton)
    }
    
    @IBAction private func usernameEditingChanged(_ sender: Any) {
        handleColorButton()
    }
    
    @IBAction func passwordEditingChanged(_ sender: Any) {
        handleColorButton()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard segue.identifier == "segueLogin" else {return}
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(loginButton)
        loginButton.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        loginButton.centerYAnchor.constraint(equalTo: self.view.centerYAnchor, constant: 70).isActive = true
    }
    
    override var prefersStatusBarHidden: Bool{
        return true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.view.endEditing(true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.view.addSubview(loginButton)
        _username.becomeFirstResponder()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        _username.resignFirstResponder()
        if #available (iOS 11, *) {
            _password.textContentType = UITextContentType("")
        }
        _username.autocorrectionType = .no
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func unwindToLogin( segue:UIStoryboardSegue ){
    }
    
    private func __SETUPDEVELOPPEMENTINFORMATION__() {
        if (UIDevice.current.name).isEqualToString(find: "Thomas's iPhone") {
            User.sharedInstance.setUserInformations(email: "j@j.com", password: "test")
        } else {
            User.sharedInstance.setUserInformations(email: "ok@o.com", password: "test")
        }
    }
    
    private func checkParametersLogin() -> Bool{
        if (UIDevice.current.name).isEqualToString(find: "Thomas's iPhone") {
            print("YES")
        } else {
            print("NON")
        }
        print("CHECK DEVICE -> \(UIDevice.current.name)")
        if (!__DEVELOPPEMENT__) {
            guard let username = _username.text, !username.isEmpty,
                let password = _password.text, !password.isEmpty else {
                    return false
            }
            User.sharedInstance.setUserInformations(email: username.removingWhitespaces(), password: password.removingWhitespaces())
            return true
        }
        __SETUPDEVELOPPEMENTINFORMATION__()
        return true
    }
    
    private func performLogin(){
        
        print("\(User.sharedInstance.getLoginParameters()) IS DEV == \(__DEVELOPPEMENT__)")
        
        ApiManager.performAlamofireRequest(url: ApiRoute.ROUTE_LOGIN, param: User.sharedInstance.getLoginParameters()).done {
            loginResponse in
            _ = DataBaseManager.saveDataToBase(appDelegate: UIApplication.shared.delegate as! AppDelegate)
            
            User.sharedInstance.setUserInformations(token: loginResponse["token"] as? String)
            
            _ = ApiManager.performAlamofireRequest(url: ApiRoute.ROUTE_INFORMATION, param: User.sharedInstance.getTokenParameter()).done {
                informationResponse in

                let content = informationResponse["content"] as! [String: Any]
                User.sharedInstance.setUserInformations(fname: content["first_name"] as? String, lname: content["last_name"] as? String, birthday: content["birthday"] as? String, id: content["id"] as? Int)
                self.performSegue(withIdentifier: "segueLogin", sender: self)
                    self.loginButton.stopAnimation()
                }.catch {test in
                    print(test)
                    HandleErrors.displayError(message: "Either the password or email is invalid 1", controller: self)
            }
            }.catch {
                _ in
                
                HandleErrors.displayError(message: "Either the password or email is invalid 2", controller: self)
                
        }
    }
    
    @IBAction func buttonAction(_ button: TransitionButton) {
        
        button.startAnimation()
        
        let qualityOfServiceClass = DispatchQoS.QoSClass.background
        let backgroundQueue = DispatchQueue.global(qos: qualityOfServiceClass)
        backgroundQueue.async(execute: {
            
            var _currentState = false
            
            DispatchQueue.main.async(execute: { () -> Void in
                
                _currentState = self.checkParametersLogin()
                
                if (_currentState) {
                    self.performLogin()
                    _currentState = true
                }else {
                    button.stopAnimation(animationStyle: .shake, completion: { })
                }
            })
            
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) {
                if (!_currentState) {
                    HandleErrors.displayError(message: "Either the password or email is invalid 1", controller: self)
                }
            }
        })
    }
    
}
