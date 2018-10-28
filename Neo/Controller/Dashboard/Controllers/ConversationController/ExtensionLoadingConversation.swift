//
//  ExtensionLoadingConversation.swift
//  Neo
//
//  Created by Thomas Martins on 28/10/2018.
//  Copyright © 2018 Neo. All rights reserved.
//

import Foundation
import SwiftyJSON

extension ChatLogController {
    
    internal func loadConv() {
        
        self.messages.removeAll()
        
        ApiManager.performAlamofireRequest(url: ApiRoute.ROUTE_CONVERSATION_INFO, param: ["token": User.sharedInstance.getParameter(parameter: "token"), "conversation_id": convId]).done {
            jsonData in
            let content = JSON(jsonData)["content"]
            let messages = content["messages"]
            self.createButtonConversation(nameConversation: content["circle"]["name"].stringValue)
            self.messages.removeAll()
            
            messages.forEach({ (item, data) in
                let newMessage = Message()
                if data["medias"].boolValue == true {
                    
                    newMessage.text = nil
                    newMessage.image = nil
                    newMessage.isMediaLoading = true
                    newMessage.mediaCellCount = (self.mediaCellCount)
                    
                    DispatchQueue.main.async {
                        
                        self.loadingMediaIntoConv(data: data, index: self.mediaCellCount)
                    }
                    
                } else {
                    newMessage.text = data["content"].stringValue
                    newMessage.isMediaLoading = false
                    newMessage.date = self.returnDateFromString(text: data["sent"].stringValue)
                    newMessage.isSender = self.detectSenderMessage(link_id: data["link_id"].intValue, links: content["links"])
                }
                
                self.messages.append(newMessage)
                self.mediaCellCount += 1
                
                self.slideOnLastMessage()
            })
            }.catch { error in
                print("[Error on loadConv: (\(error))]")
        }
    }
    
}
