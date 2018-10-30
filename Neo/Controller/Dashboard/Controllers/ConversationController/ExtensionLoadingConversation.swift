//
//  ExtensionLoadingConversation.swift
//  Neo
//
//  Created by Thomas Martins on 28/10/2018.
//  Copyright © 2018 Neo. All rights reserved.
//

import Foundation
import SwiftyJSON
import Alamofire

extension ChatLogController {
    
    private func base64Convert(base64String: String?) -> UIImage{
        if (base64String?.isEmpty)! {
            return UIImage()
        }else {
            let temp = base64String?.components(separatedBy: ",")
            let dataDecoded : Data = Data(base64Encoded: temp![1], options: .ignoreUnknownCharacters)!
            let decodedimage = UIImage(data: dataDecoded)
            return decodedimage!
        }
    }
    
    private func retrieveMedia(media: JSON, completion: @escaping(UIImage) -> ()) {
        
        ApiManager.performAlamofireRequest(url: ApiRoute.ROUTE_DOWNLOAD_MEDIA, param: ["token": User.sharedInstance.getParameter(parameter: "token"), "media_id": media["media"]["id"].intValue]).done { (value) in
                completion(self.base64Convert(base64String: JSON(value)["data"].stringValue))
            }.catch { (error) in
                print("[ERROR RETRIEVE MEDIA (\(error)) ]")
        }
    }
    
    private func loadingMediaIntoConversation(data: JSON, index: Int) {
        
        ApiManager.performAlamofireRequest(url: ApiRoute.ROUTE_MEDIA_INFO, param: ["token": User.sharedInstance.getParameter(parameter: "token"), "message_id": data["id"].intValue]).done({ (value) in
            
            let json = JSON(value)
            
            json.forEach({ (name, data) in
                if name.isEqualToString(find: "content") {
                    data.forEach({ (name, data) in
                        if data["media"]["uploaded"].boolValue == true {
                            self.retrieveMedia(media: data, completion: { (image) in
                                self.displayMediaInCollectionView(image: image)
                            })
                        }
                    })
                }
            })
        }).catch({ (error) in
            print("[ERROR: on (func loadingMediaIntoConversation()) | \(error)]")
        })
    }
    
    private func loadImageIntoDataBase(image: UIImage, completion: @escaping () -> ()) {
        ServicesChat.shareInstance.preloadindgMediaServer(conv_id: convId) { (value) in
            value["media_list"].forEach({ (name, data) in
                ApiManager.performAlamofireRequestMedia(id_file: data["id"].intValue, file: data, image: image, completion: {
                        completion()
                })
            })
        }
    }
    
    internal func uploadImageSelectedOnConversation(image: UIImage) {
        
        let newMedia = Message()
        
        newMedia.text = nil
        newMedia.image = nil
        newMedia.isMediaLoading = true
        newMedia.mediaCellCount = (self.mediaCellCount)
        newMedia.isSender = true
        
        DispatchQueue.main.async {
            self.loadImageIntoDataBase(image: image, completion: {
                self.displayMediaInCollectionView(image: image)
                //self.slideOnLastMessage()
            })
        }

        self.messages.append(newMedia)
        self.mediaCellCount += 1
        self.slideOnLastMessage()
    }
    
    private func handleMediaConversation(data: JSON, isSocket: Bool, content: JSON?) -> Message{
        let newMedia = Message()
        
        newMedia.text = nil
        newMedia.image = nil
        newMedia.isMediaLoading = true
        newMedia.mediaCellCount = (self.mediaCellCount)
        
        DispatchQueue.main.async {
            if isSocket {
                self.retrieveMedia(media: data, completion: { (image) in
                    self.displayMediaInCollectionView(image: image)
                })
            }else {
                self.loadingMediaIntoConversation(data: data, index: self.mediaCellCount)
            }
        }
        
        if isSocket {
            if data["sender"]["email"].stringValue == User.sharedInstance.getEmail() {
                newMedia.isSender = true
            } else {
                newMedia.isSender = false
            }
        } else {
            newMedia.isSender = self.detectSenderMessage(link_id: data["link_id"].intValue, links: content!)
        }
        
        return newMedia
    }
    
    private func handleMessageConversation(data: JSON, content: JSON?, isSocket: Bool) -> Message {
        let newMessage = Message()
        
        if isSocket {
            newMessage.text = data["message"]["content"].stringValue
            if data["sender"]["email"].stringValue == User.sharedInstance.getEmail() {
                newMessage.isSender = true
            }else {
                newMessage.isSender = false
            }
        }else {
            newMessage.text = data["content"].stringValue
            newMessage.isSender = self.detectSenderMessage(link_id: data["link_id"].intValue, links: content!)
        }
        newMessage.isMediaLoading = false
        newMessage.image = nil
        newMessage.date = self.returnDateFromString(text: data["sent"].stringValue)
        
        return newMessage
    }
    
    public func loadAllConversation() {
        
        self.messages.removeAll()
        
        ApiManager.performAlamofireRequest(url: ApiRoute.ROUTE_CONVERSATION_INFO, param: ["token": User.sharedInstance.getParameter(parameter: "token"), "conversation_id": convId]).done {
            jsonData in
            
            let content = JSON(jsonData)["content"]
            let messages = content["messages"]
            self.createButtonConversation(nameConversation: content["circle"]["name"].stringValue)
            
            messages.forEach({ (item, data) in
                if data["medias"].boolValue == true {
                    self.messages.append(self.handleMediaConversation(data: data, isSocket: false, content: content["links"]))
                } else {
                    self.messages.append(self.handleMessageConversation(data: data, content: content["links"], isSocket: false))
                }
                self.mediaCellCount += 1
                self.slideOnLastMessage()
            })
            }.catch { error in
                print("[ERROR: on (func LOADALLCONVERSATION()) | \(error)]")
        }
    }
    
    public func loadConversationOnSocket() {
        
        self.loadAllConversation()
        
        SocketManager.sharedInstance.getManager().defaultSocket.emit("join_conversation", JoinConversation(conversation_id: convId))
        
        SocketManager.sharedInstance.getManager().defaultSocket.on("message") { data, ack in
            
            data.forEach({ (item) in
                
                let data = JSON(item)
                
                if data["message"]["medias"].boolValue == true {
                    if (data["status"].stringValue).isEqualToString(find: "done") {
                        self.messages.append(self.handleMediaConversation(data: data, isSocket: true, content: nil))
                    }
                } else {
                    self.messages.append(self.handleMessageConversation(data: data, content: nil, isSocket: true))
                }
            })
            self.mediaCellCount += 1
            self.slideOnLastMessage()
        }
    }
}
