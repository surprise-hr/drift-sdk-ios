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
    var users: [CampaignOrganizer] = []
    var dateFormatter = DriftDateFormatter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 80
        tableView.registerNib(UINib(nibName: "ConversationListTableViewCell", bundle:  NSBundle(forClass: ConversationListTableViewCell.classForCoder())), forCellReuseIdentifier: "ConversationListTableViewCell")
        InboxManager.sharedInstance.addConversationSubscription(ConversationSubscription(delegate: self))
        
        APIManager.getConversations(DriftDataStore.sharedInstance.auth!.enduser!.userId!, authToken: DriftDataStore.sharedInstance.auth!.accessToken) { (result) in
            switch result{
            case .Success(let conversations):
                self.conversations = conversations
                dispatch_async(dispatch_get_main_queue(), {
                    self.tableView.reloadData()
                })
            case .Failure(let error):
                LoggerManager.log("Unable to get conversations for endUser:  \(DriftDataStore.sharedInstance.auth!.enduser!.userId!): \(error)")
            }
        }
    }
    
    convenience init() {
        self.init(nibName: "ConversationListViewController", bundle: NSBundle(forClass: ConversationListViewController.classForCoder()))
    }
    
    class func navigationController() -> UINavigationController {
        let vc = ConversationListViewController()
        let navVC = UINavigationController.init(rootViewController: vc)
        let leftButton = UIBarButtonItem(title: "Close", style: UIBarButtonItemStyle.Done, target: vc, action: #selector(ConversationListViewController.dismiss))
        vc.navigationItem.leftBarButtonItem  = leftButton
        vc.navigationItem.title = "Chat"
        return navVC
    }
    
    func dismiss(){
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func closeButtonPressed(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}

extension ConversationListViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("ConversationListTableViewCell") as! ConversationListTableViewCell
        let conversation = conversations[indexPath.row]
        if let assigneeId = conversation.assigneeId where assigneeId != 0{
            
            if let index = users.indexOf({$0.userId == assigneeId}){
                let user = users[index]
                if let avatar = user.avatarURL {
                    cell.avatarImageView.downloadedFrom(NSURL.init(string:avatar)!, contentMode: .ScaleAspectFill)
                }
                if let creatorName = user.name {
                    cell.nameLabel.text = creatorName
                }
            }else{
                APIManager.getUser(assigneeId, orgId: DriftDataStore.sharedInstance.embed!.orgId, authToken: DriftDataStore.sharedInstance.auth!.accessToken, completion: { (result) -> () in
                    switch result {
                    case .Success(let users):
                        self.users.appendContentsOf(users)
                        if let avatar = users.first?.avatarURL {
                            cell.avatarImageView.downloadedFrom(NSURL.init(string:avatar)!, contentMode: .ScaleAspectFill)
                        }
                        if let creatorName = users.first?.name {
                            dispatch_async(dispatch_get_main_queue(), {
                                cell.nameLabel.text = creatorName
                            })
                        }
                    case .Failure(_):
                        ()
                    }
                })
            }
        }else{
            cell.avatarImageView.image = UIImage.init(named: "placeholderAvatar", inBundle: NSBundle.init(forClass: ConversationListTableViewCell.classForCoder()), compatibleWithTraitCollection: nil)
            cell.nameLabel.text = "You"
        }
        
        cell.messageLabel.text = conversation.preview
        cell.updatedAtLabel.text = dateFormatter.updatedAtStringFromDate(conversation.updatedAt)
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return conversations.count
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let conversation = conversations[indexPath.row]
        let conversationViewController = ConversationViewController.init(conversationType: .ContinueConversation(conversationId: conversation.id))
        self.navigationController?.showViewController(conversationViewController, sender: self)
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