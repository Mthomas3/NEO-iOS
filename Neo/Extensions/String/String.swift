//
//  String.swift
//  Neo
//
//  Created by Thomas Martins on 24/09/2017.
//  Copyright © 2017 Neo. All rights reserved.
//

import Foundation

extension String{
    
    func isEqualToString(find: String) -> Bool{
        return String(format: self) == find
    }
    
    func isValidEmail() -> Bool {
        let regex = try! NSRegularExpression(pattern: "^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$", options: .caseInsensitive)
        return regex.firstMatch(in: self, options: [], range: NSRange(location: 0, length: characters.count)) != nil
    }
    
    func removingWhitespaces() -> String {
        return components(separatedBy: .whitespaces).joined()
    }
    
    func concat(string: String) -> String{
        return "\(self)\(string)"
    }
}
