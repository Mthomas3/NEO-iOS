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
    
    private func tryRequest(id: Int, file: JSON, image: UIImage, completion: @escaping () -> ()) {
        
        let baseURL = ApiRoute.ROUTE_SERVER.concat(string: ApiRoute.ROUTE_MEDIA_UPLOAD.concat(string: "/\(id)"))
        
        let headers: HTTPHeaders = [ "Authorization": User.sharedInstance.getParameter(parameter: "token") ]
        let imageTest = UIImage(named: "Logo-png.png")
        let URL = try! URLRequest(url: baseURL, method: .post, headers: headers)
        
        Alamofire.upload(multipartFormData: { multipartFormData in
            
            multipartFormData.append(UIImagePNGRepresentation(image)!, withName: "file", fileName: "\(file["identifier"])", mimeType: "image/png")
            
            multipartFormData.append("\(id)".data(using: String.Encoding.utf8)!, withName: "media_id")
            
        }, with: URL, encodingCompletion: {
            encodingResult in
            switch encodingResult {
            case .success(let upload, _, _):
                upload.responseJSON() { response in
                    debugPrint("SUCCESS RESPONSE: \(response)")
                    
                    completion()
                    
                }
            case .failure(let encodingError):
                print("ERROR RESPONSE: \(encodingError)")
            }
        })
        
    }
    
    internal func uploadImageToDataBase(image: UIImage) {
        
        ApiManager.performAlamofireRequest(url: ApiRoute.ROUTE_MESSAGE_SEND, param: ["token": User.sharedInstance.getParameter(parameter: "token"), "conversation_id": convId, "files": [NSUUID().uuidString.split(separator: "-")]]).done { (value) in
            
            JSON(value)["media_list"].forEach({ (name, data) in
                self.tryRequest(id: data["id"].intValue, file: data, image: image, completion: {
                    let i = Message()
                    i.image = image
                    self.messages.append(i)
                    self.collectionView?.reloadData()
                    
                })
            })
            
            }.catch { (error) in
                print("[ERROR UPLOADING IMAGE DATA BASE  \(error) ]")
        }
        print("***... uploading the picture ...***")
    }
    
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
    
    
    internal func launchTimer() {
        
        DispatchQueue.main.async {
            self.loadConv()
        }
        
        SocketManager.sharedInstance.getManager().defaultSocket.emit("join_conversation", JoinConversation(conversation_id: convId))
        SocketManager.sharedInstance.getManager().defaultSocket.on("message") { data, ack in
            
            data.forEach({ (item) in
                let data = JSON(item)
                
                if data["message"]["medias"].boolValue == true {
                    if (data["status"].stringValue).isEqualToString(find: "done"){
                        self.retrieveMedia(media: data, completion: { (image) in
                            let i = Message()
                            i.image = image
                            self.messages.append(i)
                            self.collectionView?.reloadData()
                        })
                    }
                    
                } else {
                    self.handleMessage(message: data)
                }
            })
            self.slideOnLastMessage()
        }
        
    }
    
    
}
