//
//  ConversationMessageTableViewCell.swift
//  Drift
//
//  Created by Brian McDonald on 01/08/2016.
//  Copyright © 2016 Drift. All rights reserved.
//

import UIKit
import AlamofireImage

class ConversationMessageTableViewCell: UITableViewCell {

    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var messageTextView: UITextView!
    
    var dateFormatter: DriftDateFormatter = DriftDateFormatter()
    var message: Message? {
        didSet{
            displayMessage()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
    }
    
    func displayMessage() {

        avatarImageView.image = UIImage.init(named: "placeholderAvatar", in: Bundle.init(for: ConversationListTableViewCell.classForCoder()), compatibleWith: nil)
        avatarImageView.layer.cornerRadius = 3
        avatarImageView.layer.masksToBounds = true
        
        messageTextView.text = ""
        messageTextView.textContainerInset = UIEdgeInsets.zero
        messageTextView.text = self.message!.body
        
        if let authorId = message?.authorId{
            getUser(authorId)
        }
        
        nameLabel.textColor = DriftDataStore.primaryFontColor

        timeLabel.textColor = DriftDataStore.secondaryFontColor
        timeLabel.text = self.dateFormatter.createdAtStringFromDate(self.message!.createdAt)
        
        do {
            let htmlStringData = (self.message!.body ?? "").data(using: String.Encoding.utf8)!
            let options: [String: AnyObject] = [NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType as AnyObject,
                                                NSCharacterEncodingDocumentAttribute: String.Encoding.utf8 as AnyObject]
            let attributedHTMLString = try NSMutableAttributedString(data: htmlStringData, options: options, documentAttributes: nil)
            self.messageTextView.text = attributedHTMLString.string
        } catch {
            self.messageTextView.text = ""
        }
    }
    
    func getUser(_ userId: Int) {
        
        if let authorType = message?.authorType , authorType == .User {
            UserManager.sharedInstance.userMetaDataForUserId(userId, completion: { (user) in
                
                if let user = user {
                    if let avatar = user.avatarURL, let url = URL(string: avatar) {
                        self.avatarImageView.af_setImage(withURL: url)
                    }
                    
                    if let creatorName =  user.name {
                        self.nameLabel.text = creatorName
                    }
                }
            })
            
        }else {
            if let endUser = DriftDataStore.sharedInstance.auth?.enduser {
                if let avatar = endUser.avatarURL {
                    self.avatarImageView.af_setImage(withURL: URL.init(string: avatar)!)
                }
                
                if let creatorName = endUser.name {
                    self.nameLabel.text = creatorName
                }
            }
        }
    }
    
}
