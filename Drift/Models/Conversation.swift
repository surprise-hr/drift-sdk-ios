//
//  Conversation.swift
//  Drift
//
//  Created by Brian McDonald on 25/07/2016.
//  Copyright © 2016 Drift. All rights reserved.
//

import ObjectMapper

enum ConversationStatus: String{
    case Open = "OPEN"
    case Closed = "CLOSED"
    case Pending = "PENDING"
}

class Conversation: Mappable{
    var id: Int64!
    var status: ConversationStatus?
    var preview: String?
    var updatedAt = Date()
        
    required convenience init?(map: Map) {
        self.init()
    }
    
    func mapping(map: Map) {
        id          <- map["id"]
        preview     <- map["preview"]
        updatedAt   <- (map["updatedAt"], DriftDateTransformer())
        status      <- (map["status"], EnumTransform<ConversationStatus>())
    }
}
