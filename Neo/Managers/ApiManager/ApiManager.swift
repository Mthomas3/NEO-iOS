//
//  ApiNeo.swift
//  Neo
//
//  Created by Thomas Martins on 05/03/2018.
//  Copyright © 2018 Neo. All rights reserved.
//

import PromiseKit
import Alamofire
import CoreData

final class ApiManager {
    
    // MARK: need to fix response statuscode
    
    /// `performAlamofireRequest` perform a request to the server
    /// - Parameter : url: String -> root to the server, param: [String: Any] -> param associated to the request
    /// - Returns: Promise
    static public func performAlamofireRequest(url: String, param: [String: Any]) -> Promise<[String: Any]>{
        
        return Promise {seal in Alamofire.request(ApiRoute.ROUTE_SERVER.concat(string: url), method: .post, parameters: param, encoding: JSONEncoding.default).responseJSON {
                response in
                if response.response == nil {
                    seal.reject(PMKError.invalidCallingConvention)
                    return
                }
                if (200...299).contains(response.response!.statusCode) {
                    if let json = response.result.value as? [String: Any] {
                        seal.resolve(json, nil)
                    }
                    else {
                        print(response.result.value as! String)
                        print("*** Route \(url) not working status code -> \(response.response!.statusCode) first if")
                        seal.reject(PMKError.invalidCallingConvention)
                    }
                } else {
                        print(response.result.value as? [String: Any])
                        print("*** Route \(url) not working status code -> \(response.response!.statusCode) second if")
                        seal.reject(PMKError.invalidCallingConvention)
                }
            }
        }
    }
}
