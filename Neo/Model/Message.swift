//
//  Message.swift
//  Neo
//
//  Created by Nicolas Gascon on 11/04/2018.
//  Copyright © 2018 Neo. All rights reserved.
//

import Foundation
import CoreData

class Message {
    var text: String?
    var date: Date?
    var isSender: Bool = false
    //@NSManaged var friend: Friend?
}

class Circle {
    var name: String?
    var date: Date?
    var id: Int?
    var users: String?
}
