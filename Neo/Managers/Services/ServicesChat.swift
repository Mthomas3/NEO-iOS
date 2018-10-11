//
//  ServicesChat.swift
//  Neo
//
//  Created by Thomas Martins on 10/10/2018.
//  Copyright © 2018 Neo. All rights reserved.
//

import Foundation
import SwiftyJSON

class ServicesChat {
    
    static let shareInstance = ServicesChat()
    
    public func createConversation(circle_id: Int, email: String, completion: @escaping (JSON) -> ()) {
        
        ApiManager.performAlamofireRequest(url: ApiRoute.ROUTE_CONVERSATION_CREATE, param: ["token": User.sharedInstance.getParameter(parameter: "token"), "circle_id": circle_id, "email": email]).done { response in
                completion(JSON(response))
            }.catch {
                error in
                print("createConversation error -> (\(error))")
        }
    }
    
    public func getConversationId(conv_id: Int, conv_name: String, completion: @escaping(JSON) -> ()) {
        ApiManager.performAlamofireRequest(url: ApiRoute.ROUTE_CONVERSATION_UPDATE, param: ["token": User.sharedInstance.getParameter(parameter: "token"), "conversation_id": conv_id, "conversation_name": conv_name]).done {
                response in
                completion(JSON(response))
            }.catch {
                error in
                print("getConversationID -> \(error)")
        }
    }
    
    public func addIntoConversation(convId: Int, email: String, completion: @escaping (JSON) -> ()) {
       /* ApiManager.performAlamofireRequest(url: ApiRoute.ROUTE_CONVERSATION_INVITE, param: ["token": User.sharedInstance.getParameter(parameter: "token"), "conversation_id": convId, "email": checkedCells[idx].email!]).done { json in*/
        
        ApiManager.performAlamofireRequest(url: ApiRoute.ROUTE_CONVERSATION_INVITE, param: ["token": User.sharedInstance.getParameter(parameter: "token"), "conversation_id": convId, "email": email]).done {
            response in
            completion(JSON(response))
            }.catch {
                error in
                print("addIntoconversation error )> \(error)")
        }
            
    }
}
