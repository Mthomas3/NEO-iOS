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

class ServicesCircle {
    
    static let shareInstance = ServicesCircle()

    public func getCirclesInvites(completion: @escaping (JSON) -> (), token: [String: Any]) {
        
        ApiManager.performAlamofireRequest(url: ApiRoute.ROUTE_ACCOUNT_INFO, param: token).done {
            response in
            completion(JSON(response))
            }.catch {
                response in
            print("impossible to get circles invites, errors -> \(response)")
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
}
