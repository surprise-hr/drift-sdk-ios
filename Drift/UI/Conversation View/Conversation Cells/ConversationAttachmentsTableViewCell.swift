//
//  ConversationAttachmentsTableViewCell.swift
//  Drift
//
//  Created by Brian McDonald on 01/08/2016.
//  Copyright © 2016 Drift. All rights reserved.
//

import UIKit

class ConversationAttachmentsTableViewCell: UITableViewCell, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var messageTextView: UITextView!
    @IBOutlet weak var attachmentsCollectionView: UICollectionView!
    
    var dateFormatter: DriftDateFormatter = DriftDateFormatter()
    var attachments: [Attachment] = []
    var message: Message? {
        didSet{
            displayMessage()
            getAttachmentsMetaData()
        }
    }
    weak var delegate: AttachementSelectedDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        attachmentsCollectionView.register(UINib.init(nibName: "AttachmentCollectionViewCell", bundle: Bundle(for: AttachmentCollectionViewCell.classForCoder())), forCellWithReuseIdentifier: "AttachmentCollectionViewCell")
        attachmentsCollectionView.dataSource = self
        attachmentsCollectionView.delegate = self
        attachmentsCollectionView.backgroundColor = UIColor.white
    }
    
    
    func displayMessage() {
  
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
    
    
    func getUser(_ userId: Int){
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
    
    
    func getAttachmentsMetaData() {
        if let message = message{
            APIManager.getAttachmentsMetaData(message.attachments, authToken: (DriftDataStore.sharedInstance.auth?.accessToken)!, completion: { (result) in
                switch result{
                    
                case .success(let attachments):
                    self.attachments = attachments
                    self.attachmentsCollectionView.reloadData()
                    
                case .failure(let error):
                    LoggerManager.log("Unable to get attachments: \(error)")
                }
            })
        }
    }
    
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let cell = cell as? AttachmentCollectionViewCell {
            let attachment = self.attachments[(indexPath as NSIndexPath).row]
            let fileName: NSString = attachment.fileName as NSString
            let fileExtension = fileName.pathExtension
            cell.fileNameLabel.text = "\(fileName)"
            cell.fileExtensionLabel.text = "\(fileExtension.uppercased())"
            
            let formatter = ByteCountFormatter()
            formatter.string(fromByteCount: Int64(attachment.size))
            formatter.allowsNonnumericFormatting = false
            cell.sizeLabel.text = formatter.string(fromByteCount: Int64(attachment.size))
        }
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AttachmentCollectionViewCell", for: indexPath) as! AttachmentCollectionViewCell
        cell.layer.cornerRadius = 3.0
        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return attachments.count
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if delegate != nil{
            delegate?.attachmentSelected(attachments[(indexPath as NSIndexPath).row], sender: self)
        }
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 200, height: 55)
    }
    

}
