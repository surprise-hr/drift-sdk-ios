//
//  InboxSubscription.swift
//  Drift
//
//  Created by Brian McDonald on 25/07/2016.
//  Copyright © 2016 Drift. All rights reserved.
//

protocol InboxDelegate: class{
    func inboxesDidUpdate(_ inboxes: [Inbox])
    func didSelectInbox(_ inbox: Inbox)
}

class InboxSubscription {
    
    convenience init(delegate: InboxDelegate) {
        self.init()
        self.delegate = delegate
    }
    
    weak var delegate: InboxDelegate?
}

