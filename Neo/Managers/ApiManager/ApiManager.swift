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
import SwiftyJSON

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
    
    static public func performAlamofireRequestMedia(id_file: Int, file: JSON, image: UIImage, completion: @escaping () -> ()) {
        let baseURLserver = ApiRoute.ROUTE_SERVER.concat(string: ApiRoute.ROUTE_MEDIA_UPLOAD.concat(string: "/\(id_file)"))
        
        let headers: HTTPHeaders = [ "Authorization": User.sharedInstance.getParameter(parameter: "token") ]
        let URL = try! URLRequest(url: baseURLserver, method: .post, headers: headers)
        
            Alamofire.upload(multipartFormData: { multipartFormData in
        
                multipartFormData.append(UIImagePNGRepresentation(image)!, withName: "file", fileName: "\(file["identifier"])", mimeType: "image/png")
        
                multipartFormData.append("\(id_file)".data(using: String.Encoding.utf8)!, withName: "media_id")
        
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
}





//private func tryRequest(id: Int, file: JSON, image: UIImage, completion: @escaping () -> ()) {
//
//    let baseURL = ApiRoute.ROUTE_SERVER.concat(string: ApiRoute.ROUTE_MEDIA_UPLOAD.concat(string: "/\(id)"))
//
//    let headers: HTTPHeaders = [ "Authorization": User.sharedInstance.getParameter(parameter: "token") ]
//    let imageTest = UIImage(named: "Logo-png.png")
//    let URL = try! URLRequest(url: baseURL, method: .post, headers: headers)
//
//    Alamofire.upload(multipartFormData: { multipartFormData in
//
//        multipartFormData.append(UIImagePNGRepresentation(image)!, withName: "file", fileName: "\(file["identifier"])", mimeType: "image/png")
//
//        multipartFormData.append("\(id)".data(using: String.Encoding.utf8)!, withName: "media_id")
//
//    }, with: URL, encodingCompletion: {
//        encodingResult in
//        switch encodingResult {
//        case .success(let upload, _, _):
//            upload.responseJSON() { response in
//                debugPrint("SUCCESS RESPONSE: \(response)")
//
//                completion()
//
//            }
//        case .failure(let encodingError):
//            print("ERROR RESPONSE: \(encodingError)")
//        }
//    })
//}
