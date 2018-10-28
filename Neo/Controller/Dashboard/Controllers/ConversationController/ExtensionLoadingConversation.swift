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
    
    internal func uploadImageSelectedOnConversation(image: UIImage) {
        
        ServicesChat.shareInstance.preloadindgMediaServer(conv_id: convId) { (value) in
            value["media_list"].forEach({ (name, data) in
                self.tryRequest(id: data["id"].intValue, file: data, image: image, completion: {
                    let i = Message()
                    i.image = image
                    self.messages.append(i)
                    self.collectionView?.reloadData()
                })
            })
        }
        print("***... uploading the picture ...***")
    }
    
    private func handleMediaConversation(data: JSON, isSocket: Bool) -> Message{
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
                    self.messages.append(self.handleMediaConversation(data: data, isSocket: false))
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
                        self.messages.append(self.handleMediaConversation(data: data, isSocket: true))
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
