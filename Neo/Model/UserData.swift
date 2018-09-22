//
//  UserData.swift
//  Neo
//
//  Created by Thomas Martins on 12/09/2017.
//  Copyright © 2017 Neo. All rights reserved.
//

import Foundation

class User {
    static let sharedInstance = User()
    
    private var email: String?
    private var password: String?
    private var fname: String?
    private var lname: String?
    private var token: String?
    private var birthday: String?
    private var id: Int?
    
    init(email: String? = nil, password: String? = nil) {
        self.email = email
        self.password = password
    }
    
    /*
        Set a user parameter
        Parameter values : String? -> name by the parameter we want to change
        no return value
     */
    
    func setUserInformations(email: String? = nil, password: String? = nil, fname: String? = nil, lname: String? = nil, token: String? = nil, birthday: String? = nil, id: Int? = nil) {
        if (email != nil) {
            self.email = email!
        }
        if (password != nil) {
            self.password = password!
        }
        if (fname != nil) {
            self.fname = fname
        }
        if (lname != nil) {
            self.lname = lname
        }
        if (token != nil) {
            self.token = token
        }
        if (birthday != nil) {
            self.birthday = birthday
        }
        if (id != nil) {
            self.id = id
        }
    }
    
    func setUserInformations(newValue :  [String:String]) {
        for (key, value) in newValue {
            print("key = \(key), value=\(value)")
            switch key {
            case "email" :
                self.email = value
            case "fname":
                self.fname = value
            case "lname":
                self.lname = value
            default:
                break
            }
        }
    }

    /*
     no parameters
     Return dictionary values with email and password
     */
    
    func getLoginParameters() -> [String: Any] {
        return [
            "email": self.email!,
            "password": self.password!
        ]
    }
    
    func getTokenParameter() -> [String: Any] {
        return [
            "token": self.token!
        ]
    }
    
    func getEmailParameter() -> [String: Any] {
        return [
            "email": self.email!
        ]
    }
    
    /*
     return all the paramaters for the account registration as dictionary
     */
    
    func getRegistrationParameters() -> [String: Any] {
        return [
            "email": self.email!,
            "last_name": self.lname!,
            "password": self.password!,
            "first_name": self.fname!,
            "birthday": self.birthday!
        ]
    }
    
    func getUserInformation() -> [String: Any] {
        return [
            "token" : self.token!,
            "email" : self.email!,
            "last_name" : self.lname!,
            "first_name" : self.fname!,
            "birthday" : self.birthday!
        ]
    }
    
    /*
     Parameter value -> String! with the parameter needed
     Return -> String! 
    */
    
    func getParameter(parameter: String) -> String {
        switch parameter {
            case "email":
                return self.email!
            case "fname":
                return self.fname!
            case "lname":
                return self.lname!
            case "password":
                return self.password!
            case "token":
                return self.token!
            default:
                return ""
        }
    }
    
    func getName() -> String {
        return self.fname! + " " + self.lname!;
    }
    
    func getEmail() -> String {
        return self.email!
    }
    
    func getId() -> Int {
        return self.id!
    }
}

