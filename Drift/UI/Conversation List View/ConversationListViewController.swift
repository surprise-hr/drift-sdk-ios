//
//  ConversationListViewController.swift
//  Drift
//
//  Created by Brian McDonald on 26/07/2016.
//  Copyright © 2016 Drift. All rights reserved.
//

import UIKit
import AlamofireImage

class ConversationListViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var loadingConversationsLabel: UILabel!
   
    @IBOutlet weak var emptyStateView: UIView!
    @IBOutlet weak var emptyStateButton: UIButton!
    
    var conversations: [Conversation] = []
    var users: [CampaignOrganizer] = []
    var dateFormatter = DriftDateFormatter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupEmptyState()
        activityIndicator.startAnimating()
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 90
        tableView.register(UINib(nibName: "ConversationListTableViewCell", bundle:  Bundle(for: ConversationListTableViewCell.classForCoder())), forCellReuseIdentifier: "ConversationListTableViewCell")
        InboxManager.sharedInstance.addConversationSubscription(ConversationSubscription(delegate: self))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        APIManager.getConversations(DriftDataStore.sharedInstance.auth!.enduser!.userId!, authToken: DriftDataStore.sharedInstance.auth!.accessToken) { (result) in
            self.activityIndicator.isHidden = true
            self.loadingConversationsLabel.isHidden = true
            self.activityIndicator.stopAnimating()
            switch result{
            case .success(let conversations):
                self.conversations = conversations
                self.tableView.reloadData()
                if conversations.count == 0{
                    self.emptyStateView.isHidden = false
                }
            case .failure(let error):
                LoggerManager.log("Unable to get conversations for endUser:  \(DriftDataStore.sharedInstance.auth!.enduser!.userId!): \(error)")
            }
        }
    }
    
    convenience init() {
        self.init(nibName: "ConversationListViewController", bundle: Bundle(for: ConversationListViewController.classForCoder()))
    }
    
    
    class func navigationController() -> UINavigationController {
        let vc = ConversationListViewController()
        let navVC = UINavigationController.init(rootViewController: vc)
        let leftButton = UIBarButtonItem(title: "Close", style: UIBarButtonItemStyle.done, target: vc, action: #selector(ConversationListViewController.dismissVC))
        let rightButton = UIBarButtonItem.init(image:  UIImage.init(named: "composeIcon", in: Bundle.init(for: ConversationListViewController.classForCoder()), compatibleWith: nil), style: UIBarButtonItemStyle.plain, target: vc, action: #selector(ConversationListViewController.startNewConversation))
        navVC.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: DriftDataStore.sharedInstance.generateForegroundColor()]
        navVC.navigationBar.barTintColor = DriftDataStore.sharedInstance.generateBackgroundColor()
        navVC.navigationBar.tintColor = DriftDataStore.sharedInstance.generateForegroundColor()
        
        vc.navigationItem.leftBarButtonItem  = leftButton
        vc.navigationItem.rightBarButtonItem = rightButton
        vc.navigationItem.title = "Conversations"
        
        return navVC
    }
    
    
    func dismissVC() {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    func startNewConversation() {
        let conversationViewController = ConversationViewController(conversationType: ConversationViewController.ConversationType.createConversation(authorId: DriftDataStore.sharedInstance.auth!.enduser!.userId!))
        self.navigationController?.show(conversationViewController, sender: self)
    }
    
    
    func setupEmptyState() {
        emptyStateButton.clipsToBounds = true
        emptyStateButton.layer.cornerRadius = 3.0
        emptyStateButton.backgroundColor = DriftDataStore.sharedInstance.generateBackgroundColor()
        emptyStateButton.setTitleColor(DriftDataStore.sharedInstance.generateForegroundColor(), for: UIControlState())
    }
    
    
    @IBAction func emptyStateButtonPressed(_ sender: AnyObject) {
        startNewConversation()
    }
    
}

extension ConversationListViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ConversationListTableViewCell") as! ConversationListTableViewCell
        cell.avatarImageView.image = UIImage.init(named: "placeholderAvatar", in:  Bundle(for: ConversationListViewController.classForCoder()), compatibleWith: nil)
        let conversation = conversations[(indexPath as NSIndexPath).row]

        if let assigneeId = conversation.assigneeId , assigneeId != 0{
            UserManager.sharedInstance.userMetaDataForUserId(assigneeId, completion: { (user) in
            
                if let user = user {
                    if let avatar = user.avatarURL {
                        cell.avatarImageView.af_setImage(withURL: URL.init(string:avatar)!)
                    }
                    if let creatorName = user.name {
                        cell.nameLabel.text = creatorName
                    }
                }
            })
            
        }else{
            cell.nameLabel.text = "You"
            if let endUser = DriftDataStore.sharedInstance.auth?.enduser {
                if let avatar = endUser.avatarURL {
                    cell.avatarImageView.af_setImage(withURL: URL.init(string: avatar)!)
                }
            }
        }
        
        if let string = conversation.preview{
            cell.messageLabel.text = string.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        }

        cell.updatedAtLabel.text = dateFormatter.updatedAtStringFromDate(conversation.updatedAt)
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if conversations.count > 0 {
            self.emptyStateView.isHidden = true
        }
        return conversations.count
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let conversation = conversations[(indexPath as NSIndexPath).row]
        let conversationViewController = ConversationViewController.init(conversationType: .continueConversation(conversationId: conversation.id))
        self.navigationController?.show(conversationViewController, sender: self)
    }
}

extension ConversationListViewController: ConversationDelegate{
    
    func conversationDidUpdate(_ conversation: Conversation) {
        if let index = conversations.index(of: conversation) {
            conversations[index] = conversation
            tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
        }else {
            conversations.insert(conversation, at: 0)
            tableView.insertRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
        }
    }
    
    
    func conversationsDidUpdate(_ conversations: [Conversation]) {
        for conversation in conversations{
            if let index = self.conversations.index(of: conversation) {
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
