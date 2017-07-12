//
//  MessageSubscription.swift
//  Drift
//
//  Created by Brian McDonald on 25/07/2016.
//  Copyright © 2016 Drift. All rights reserved.
//

protocol MessageDelegate: class{
    func messagesDidUpdate(_ messages: [Message])
    func newMessage(_ message: Message)
}

class MessageSubscription {
    
    convenience init(delegate: MessageDelegate, conversationId: Int) {
        self.init()
        self.delegate = delegate
        self.conversationId = conversationId
    }
    
    weak var delegate: MessageDelegate?
    var conversationId: Int!
}
