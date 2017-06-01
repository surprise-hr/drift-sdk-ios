//
//  SocketManager.swift
//  Drift
//
//  Created by Eoin O'Connell on 31/05/2017.
//  Copyright © 2017 Drift. All rights reserved.
//

import UIKit
import Birdsong
import ObjectMapper

public extension Notification.Name {
    
    static let driftOnNewMessageReceived = Notification.Name("drift-sdk-new-message-received")
}

class SocketManager {
    
    static var sharedInstance: SocketManager = SocketManager()
    
    var socket: Socket?
    
    func connectToSocket(socketAuth: SocketAuth) {
        
        if let socket = socket {
            socket.disconnect()
        }
        
        
        socket = Socket(url: URL(string: "wss://chat.api.drift.com/ws/websocket")!, params: ["session_token": socketAuth.sessionToken])
        
        socket!.onConnect =  {

            let channel = self.socket?.channel("user:\(socketAuth.userId)")
            
            channel?.on("change", callback: { (response) in
                print("CHANGE PLACES")
                if let body = response.payload["body"] as? [String: Any], let object = body["object"] as? [String: Any], let data = body["data"] as? [String: Any], let type = object["type"] as? String {
                    
                    switch type {
                    case "MESSAGE":
                        if let message = Mapper<Message>().map(JSON: data){
                            self.didRecieveNewMessage(message: message)
                        }
                    default:
                        LoggerManager.log("Ignoring unknown event type")
                    }
                    
                    
                }else{
                    LoggerManager.log("Ignoring unknown event type")
                }
            })
            
            channel?.join()
        }
        
        socket?.connect()
        
        
    }
    
    
    
    func didRecieveNewMessage(message: Message) {
        NotificationCenter.default.post(name: .driftOnNewMessageReceived, object: self, userInfo: ["message": message])
    }
}
