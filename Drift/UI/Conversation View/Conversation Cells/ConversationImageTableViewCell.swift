//
//  ConversationImageTableViewCell.swift
//  Drift
//
//  Created by Brian McDonald on 01/08/2016.
//  Copyright © 2016 Drift. All rights reserved.
//

import UIKit

class ConversationImageTableViewCell: UITableViewCell {

    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var messageTextView: UITextView!
    @IBOutlet weak var attachmentImageView: UIImageView!
    
    weak var delegate: AttachementSelectedDelegate?{
        didSet{
            let gestureRecognizer = UITapGestureRecognizer.init(target:self, action: #selector(ConversationImageTableViewCell.imagePressed))
            attachmentImageView.addGestureRecognizer(gestureRecognizer)
        }
    }
    var dateFormatter: DriftDateFormatter = DriftDateFormatter()
    var message: Message? {
        didSet{
            displayMessage()
        }
    }
    
    var attachment: Attachment? {
        didSet{
            displayAttachment()
        }
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
    }
    
    
    func imagePressed() {
        if let attachment = attachment{
            delegate?.attachmentSelected(attachment, sender: self)
        }
    }
    
    func displayMessage(){
    
        avatarImageView.image = UIImage.init(named: "placeholderAvatar", in: Bundle.init(for: ConversationListTableViewCell.classForCoder()), compatibleWith: nil)
        avatarImageView.layer.masksToBounds = true
        avatarImageView.contentMode = .scaleAspectFill
        avatarImageView.layer.cornerRadius = 3
    
        if let authorId = message?.authorId{
            getUser(authorId)
        }
        
        messageTextView.text = ""
        messageTextView.textContainerInset = UIEdgeInsets.zero
        messageTextView.text = self.message!.body
        
        attachmentImageView.layer.masksToBounds = true
        attachmentImageView.contentMode = .scaleAspectFill
        attachmentImageView.layer.cornerRadius = 3
        
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
    
    
    func displayAttachment() {
        if let attachment = attachment{
            if let previewString = attachment.publicPreviewURL, let imageURL = URL(string: previewString){
                attachmentImageView!.af_setImage(withURL: imageURL, placeholderImage: nil, filter: nil, progress: nil, progressQueue: DispatchQueue.main, imageTransition: .crossDissolve(0.5), runImageTransitionIfCached: true, completion:nil)
            }
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
