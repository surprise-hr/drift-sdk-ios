//
//  MessagePartData.swift
//  Driftt
//
//  Created by Eoin O'Connell on 22/01/2016.
//  Copyright © 2016 Drift. All rights reserved.
//

import Gloss
class Campaign: Decodable {
    
    /**
        The type of message that the SDK can parse
        - Announcment: Announcment Campaign
        - NPS: NPS Campaign
        - NPS Response: Response to an NPS Campaign - Don't show NPS is conversation contains NPS Response
     */
    enum MessageType: String {
        case Announcement = "ANNOUNCEMENT"
        case NPS = "NPS_QUESTION"
        case NPSResponse = "NPS_RESPONSE"
    }
    
    var orgId: Int?
    var id: Int?
    var uuid: String?
    var messageType: MessageType?
    var createdAt: NSDate?
    var bodyText: String?
    var authorId: Int?
    var conversationId: Int?
    
    var npsAttributes: NPSAttributes?
    var announcmentAttributes: AnnouncmentAttributes?
    var npsResponseAttributes: NPSResponseAttributes? 
    
    required init?(json: JSON) {
        
        self.orgId = "orgId" <~~ json
        self.id = "id" <~~ json
        self.uuid = "uuid" <~~ json
        self.messageType = "type" <~~ json
        self.createdAt = Decoder.decodeDriftDate("createdAt", json: json)
        self.bodyText = "body" <~~ json
        self.authorId = "authorId" <~~ json
        self.conversationId = "conversationId" <~~ json
        
        
        if let messageType = messageType {
            
            switch messageType {
            case .Announcement:
                self.announcmentAttributes = "attributes" <~~ json
            case .NPS:
                self.npsAttributes = "attributes" <~~ json
            case .NPSResponse:
                self.npsResponseAttributes = "attributes" <~~ json
            }   
        }
    }
}
