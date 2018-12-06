//
//  SocketManager.swift
//  Neo
//
//  Created by Thomas Martins on 14/07/2018.
//  Copyright © 2018 Neo. All rights reserved.
//

import Foundation
import SocketIO

final class SocketManager {
    
    static let sharedInstance = SocketManager()
    
    private var manager: SocketIO.SocketManager?
    
    private var isConnected: Bool = false
    
    private var socket: SocketIOClient?
    
    init() {
    
    }
    
    deinit {
        
    }
    
    func IsConnected() -> Bool {
        return isConnected
    }
    
    func getSocket() -> SocketIOClient {
        return socket!
    }
    
    func getManager() -> SocketIO.SocketManager {
        return manager!
    }
    
    func connect() {
        
        if (IsConnected()) {
            return
        }
        
        manager = SocketIO.SocketManager(socketURL: URL(string: "https://api.neo.ovh:443")!)
        
        self.socket = manager?.defaultSocket
        
        socket?.on(clientEvent: .connect) { data, ack in
            print("socket connected")
            self.manager?.defaultSocket.emit("authenticate", TokenData(token: User.sharedInstance.getParameter(parameter: "token")))
        }
        
        socket?.on("authenticate") { data, ack in
            print("Event")
            print(data)
        }
        
        socket?.on("error") { data, ack in
            print("error")
            print(data)
            self.isConnected = false
            
        }
        
        socket?.on("success") { data, ack in
            print("success")
            print(data)
        }
        
        socket?.connect()
        
        isConnected = true
    }
}
