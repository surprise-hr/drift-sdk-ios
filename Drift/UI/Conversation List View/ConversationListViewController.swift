//
//  ConversationListViewController.swift
//  Drift
//
//  Created by Brian McDonald on 26/07/2016.
//  Copyright © 2016 Drift. All rights reserved.
//

import UIKit

class ConversationListViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var conversations: [Conversation] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.registerNib(UINib(nibName: "ConversationListTableViewCell", bundle:  NSBundle(forClass: ConversationListTableViewCell.classForCoder())), forCellReuseIdentifier: "ConversationListTableViewCell")
        InboxManager.sharedInstance.addConversationSubscription(ConversationSubscription(delegate: self))
        
        APIManager.getConversations(DriftDataStore.sharedInstance.auth!.enduser!.userId!, authToken: DriftDataStore.sharedInstance.auth!.accessToken) { (result) in
            switch result{
            case .Success(let conversations):
                self.conversations = conversations
                self.tableView.reloadData()
            case .Failure(let error):
                LoggerManager.log("Unable to get conversations for endUser:  \(DriftDataStore.sharedInstance.auth!.enduser!.userId!): \(error)")
            }
        }
    }
    
    @IBAction func closeButtonPressed(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}

extension ConversationListViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("ConversationListTableViewCell") as! ConversationListTableViewCell
        let conversation = conversations[indexPath.row]
        cell.nameLabel.text = conversation.subject
        cell.messageLabel.text = conversation.preview
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return conversations.count
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        //do nothing right now
    }
}

extension ConversationListViewController: ConversationDelegate{
    func conversationDidUpdate(conversation: Conversation) {
        if let index = conversations.indexOf(conversation) {
            conversations[index] = conversation
            tableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: index, inSection: 0)], withRowAnimation: .Automatic)
        }else {
            conversations.insert(conversation, atIndex: 0)
            tableView.insertRowsAtIndexPaths([NSIndexPath(forRow: 0, inSection: 0)], withRowAnimation: .Automatic)
        }
    }
    
    func conversationsDidUpdate(conversations: [Conversation]) {
        for conversation in conversations{
            if let index = self.conversations.indexOf(conversation) {
                if conversation.updatedAt.timeIntervalSince1970 > (self.conversations[index].updatedAt.timeIntervalSince1970){
                    self.conversations[index] = conversation
                }
            }else {
                self.conversations.append(conversation)
            }
        }
        tableView.reloadData()
    }
}