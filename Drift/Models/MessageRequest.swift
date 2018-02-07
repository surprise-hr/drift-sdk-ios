//
//  MessageRequest.swift
//  Drift-SDK
//
//  Created by Eoin O'Connell on 06/02/2018.
//  Copyright © 2018 Drift. All rights reserved.
//

import UIKit
import ObjectMapper

class MessageRequest {

    var body: String = ""
    var type:ContentType = .Chat
    var attachments: [Int] = []
    var requestId: Double = Date().timeIntervalSince1970

    init (body: String, contentType: ContentType = .Chat, attachmentIds: [Int] = []) {
        self.body = TextHelper.wrapTextInHTML(text: body)
        self.type = contentType
        self.attachments = attachmentIds
    }
    
    func getContextUserAgent() -> String {

        var userAgent = "Mobile App / \(UIDevice.current.modelName) / \(UIDevice.current.systemName) \(UIDevice.current.systemVersion)"
        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] {
            userAgent.append(" / App Version: \(version)")
        }
        return userAgent
    }
    
  
    func toJSON() -> [String: Any]{
        
        var json:[String : Any] = [
            "body": body ?? "",
            "type": type.rawValue,
            "attachments": attachments,
            "context": ["userAgent": getContextUserAgent()]
        ]
        
        return json
    }
    
    func generateFakeMessage(conversationId:Int, userId: Int) -> Message {
        
        let message = Message()
        message.authorId = userId
        message.body = body
        message.uuid = UUID().uuidString
        message.contentType = type
        
        message.sendStatus = .Pending
        message.conversationId = conversationId
        message.createdAt = Date()
        message.authorType = .User
        message.requestId = requestId
        return message
    }
    
}
