//
//  EnrichedConversation.swift
//  Drift
//
//  Created by Brian McDonald on 08/06/2017.
//  Copyright © 2017 Drift. All rights reserved.
//

struct EnrichedConversation {
    
    let conversation: Conversation
    let unreadMessages: Int
    let lastMessage: Message?
    let lastAgentMessage: Message?
}


class EnrichedConversationDTO: DTO, Codable {
    typealias DataObject = EnrichedConversation
    
    var conversation: ConversationDTO?
    var unreadMessages: Int?
    var lastMessage: MessageDTO?
    var lastAgentMessage: MessageDTO?
    
    enum CodingKeys: String, CodingKey {
        case conversation       = "conversation"
        case unreadMessages     = "unreadMessages"
        case lastMessage        = "lastMessage"
        case lastAgentMessage   = "lastAgentMessage"
    }
    
    func mapToObject() -> EnrichedConversation? {
        guard let conversation = conversation?.mapToObject() else {
            return nil
        }
        
        //Filter out email conversations
        if conversation.type == "EMAIL" {
            return nil
        }
        
        return EnrichedConversation(conversation: conversation,
                                    unreadMessages: unreadMessages ?? 0,
                                    lastMessage: lastMessage?.mapToObject(),
                                    lastAgentMessage: lastAgentMessage?.mapToObject())
        
    }
}
