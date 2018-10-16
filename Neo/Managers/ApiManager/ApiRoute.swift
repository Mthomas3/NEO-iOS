//
//  ApiRoute.swift
//  Neo
//
//  Created by Thomas Martins on 10/03/2018.
//  Copyright © 2018 Neo. All rights reserved.
//

import Foundation

/// `ApiRoot` StatusCode (200 = success, 400 = client error, 500 = server error)
/// - Returns: String as root of the server
public enum ApiRoute  {

    /// `ROOT_SERVER`
    /// - Returns: String as root of the server
    public static let ROUTE_SERVER = "https://api.neo.ovh/"

    /// `ROOT_LOGIN` Login to account
    /// - Parameter : {"email": "test@test.com", "password": "VerySecurePassword"}
    /// - Returns: StatusCode
    public static let ROUTE_LOGIN = "account/login"
    
    /// `ROOT_LOGOUT` Logout from account
    /// - Parameter : {"token": "token"}
    /// - Returns: StatusCode
    public static let ROUTE_LOGOUT = "account/logout"

    /// `ROOT_INFORMATION` Account informations
    /// - Parameter : {"token": "token"}
    /// - Returns: StatusCode
    static let ROUTE_INFORMATION = "user/info"
    
    /// `ROOT_MODIFY` Modify account informations
    /// - Parameter : {"token": "myToken","email": "New email","last_name": "New Last Name","first_name": "New First Name","birthday": "1990-12-25"}
    /// - Returns: StatusCode
    static let ROUTE_MODIFY = "account/modify"
    
    /// `ROOT_CREATE` Create new account
    /// - Parameter : {"token": "myToken","email": "New email","last_name": "New Last Name","first_name": "New First Name","birthday": "1990-12-25"}
    /// - Returns: StatusCode
    static let ROUTE_CREATE = "account/create"
    
    /// `ROUTE_CONTACT_LIST` Get contact list
    /// - Parameter : {"token": "myToken","email": "New email","last_name": "New Last Name","first_name": "New First Name","birthday": "1990-12-25"}
    /// - Returns: StatusCode
    static let ROUTE_CONTACT_LIST = "account/contact/list"
    
    /// `ROUTE_CONTACT_ADD` Add a contact
    /// - Parameter : {"token": "myToken","email": "New email","last_name": "New Last Name","first_name": "New First Name","birthday": "1990-12-25"}
    /// - Returns: StatusCode
    static let ROUTE_CONTACT_ADD = "account/contact/add"
    
    /// `ROUTE_CONTACT_DEL` Add a contact
    /// - Parameter : {"token": "myToken","email": "New email","last_name": "New Last Name","first_name": "New First Name","birthday": "1990-12-25"}
    /// - Returns: StatusCode
    static let ROUTE_CONTACT_DEL = "account/contact/delete"
    
    /// `ROOT_CREATE` Check if an email is already taken
    /// - Parameter : {"email": "test@test.com"}
    /// - Returns: Success/False
    static let ROUTE_CHECKEMAIL = "email/available"
    
    static let ROUTE_CHANGE_PASSWORD = "account/modify/password"
    
    static let ROUTE_CIRCLE_LIST = "circle/list"
    static let ROUTE_CIRCLE_INFO = "circle/info"
    static let ROUTE_CIRCLE_CREATE = "circle/create"
    static let ROUTE_ACCOUNT_INFO = "user/info"
    static let ROUTE_CONVERSATION_INFO = "conversation/info"
    static let ROUTE_MESSAGE_SEND = "message/send"
    static let ROUTE_CIRCLE_INVITE = "circle/invite"
    static let ROUTE_CONVERSATION_LIST = "conversation/list"
    static let ROUTE_CONVERSATION_CREATE = "message/first-message"
    static let ROUTE_CONVERSATION_INVITE = "conversation/invite"
    static let ROUTE_CONVERSATION_QUIT = "conversation/quit"
    static let ROUTE_CONVERSATION_UPDATE = "conversation/update"
    static let ROUTE_CONVERSATION_NEO_ADD = "conversation/device/add"
    static let ROUTE_CONVERSATION_NEO_REMOVE = "conversation/device/remove"
    static let ROUTE_MESSAGE_INFO = "message/info"
    
    static let ROUTE_FRIEND_YES = "circle/join"
    static let ROUTE_FRIEND_NO = "circle/reject"
    static let ROUTE_CIRCLE_QUIT = "circle/quit"
    
    static let ROUTE_MEDIA_UPLOAD = "media/upload"
    static let ROUTE_DOWNLOAD_MEDIA = "media/retrieve"
    
}
