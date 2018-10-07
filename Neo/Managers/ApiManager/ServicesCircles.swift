//
//  ServicesCircles.swift
//  Neo
//
//  Created by Thomas Martins on 25/09/2018.
//  Copyright © 2018 Neo. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

public struct ItemCellData {
    var Name: String
    var Date: String
    var Id: Int
}

public struct MemberCellData {
    var FName: String
    var LName: String
    var Email: String
    
}

class ServicesCircle {
    
    static let shareInstance = ServicesCircle()

    public func getCirclesInvites(completion: @escaping ([ItemCellData]) -> ()) {
        
        ApiManager.performAlamofireRequest(url: ApiRoute.ROUTE_ACCOUNT_INFO, param: User.sharedInstance.getTokenParameter()).done {
            json in
            
            let invites = JSON(json)["content"]["invites"]
            var data = [ItemCellData]()
            
                for item in invites.arrayValue {
                    data.append(ItemCellData(Name: item["circle"]["name"].stringValue, Date: item["created"].stringValue, Id: item["id"].intValue))
                }
            completion(data)
            data.removeAll()
            
            } .catch { _ in print("cannot get circle invites in ServicesCircles")}
    }
    
    public func getNumberCircleInvitOnWait(completion: @escaping (Int) -> ()){
        self.getCirclesInvites { (data) in
            completion(data.count)
        }
    }
    
    public func getCirclesInvitesOnSocket(id: Int, token : [String: Any], completion: @escaping (JSON)->()) {
        
        ApiManager.performAlamofireRequest(url: ApiRoute.ROUTE_ACCOUNT_INFO, param: token).done {
            response in
            let invites = JSON(response)["content"]["invites"]
            
            for index in 0...invites.count - 1 {
                if invites[index]["id"].intValue == id {
                    completion(invites[index])
                }
            }
        }.catch { _ in
            print("impossible to get circles invites on socket in ServicesCircles")
        }
    }
    
    public func getCirclesInformations(completion: @escaping ([ItemCellData]) -> ()) {
        
        ApiManager.performAlamofireRequest(url: ApiRoute.ROUTE_CIRCLE_LIST, param: User.sharedInstance.getTokenParameter()).done { data in
            
            var informations = [ItemCellData]()
            
            let contacts = JSON(data)["content"]
                for item in contacts.arrayValue {
                    
                    informations.append(ItemCellData(Name: item["name"].stringValue,
                                                       Date: item["created"].stringValue, Id: item["id"].intValue))
                }
            completion(informations)
            informations.removeAll()
            
            }.catch {_ in}
    }
    
    public func declineCircleInvitationGroup(id: Int, completion: @escaping (JSON) -> ()) {
        
        ApiManager.performAlamofireRequest(url: ApiRoute.ROUTE_FRIEND_NO, param: ["token": User.sharedInstance.getParameter(parameter: "token"), "invite_id": id]).done {
            json in
                completion(JSON(json))
            }.catch
            {_ in}
    }
    
    public func acceptCircleInvitationGroup(id: Int, completion: @escaping (JSON) -> ()) {
        
        ApiManager.performAlamofireRequest(url: ApiRoute.ROUTE_FRIEND_YES, param: ["token": User.sharedInstance.getParameter(parameter: "token"), "invite_id": id]).done {
            json in
                completion(JSON(json))
            }.catch
            {_ in
                
        }
    }
    
    public func getMembersInCircle(circle_id: Int, completion: @escaping ([MemberCellData]) -> ()) {
        ApiManager.performAlamofireRequest(url: ApiRoute.ROUTE_CIRCLE_INFO, param: ["token": User.sharedInstance.getParameter(parameter: "token"), "circle_id": circle_id]).done { members in
            
            var membersInCircle = [MemberCellData]()
            JSON(members)["content"]["users"].forEach({ (idx, item) in
                membersInCircle.append(MemberCellData(FName: item["user"]["first_name"].stringValue, LName: item["user"]["last_name"].stringValue, Email: item["user"]["email"].stringValue))
                
            })
                completion(membersInCircle)
            }.catch {error in print("cannot get members in circle error(\(error)")}
    }

}
