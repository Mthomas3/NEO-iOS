//
//  CommunMethods.swift
//  NeoUITests
//
//  Created by Thomas Martins on 02/10/2017.
//  Copyright © 2017 Neo. All rights reserved.
//

import Foundation

class CommunMethods {
    
    static func getDictionaryData() -> [String : String]{
        var data = [String : String]()
        
        data[" "] = "here"
        data["here"] = ""
        data["thomas"] = ""
        data["test"] = " "
        
        return data
    }
    
}
