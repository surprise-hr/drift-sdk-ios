//
//  ConversationAttachmentsTableViewCell.swift
//  Drift
//
//  Created by Brian McDonald on 01/08/2016.
//  Copyright © 2016 Drift. All rights reserved.
//

import UIKit
import DriftSDK
import AlamofireImage
import NVActivityIndicatorView
import FLAnimatedImage
import SDWebImage

public protocol ConversationCellDelegate: class {
    func showProfileForRow(indexPath: IndexPath)
}

class ConversationMessageTableViewCell: UITableViewCell, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    @IBOutlet weak var avatarView: AvatarView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var messageTextView: UITextView!
    @IBOutlet weak var attachmentsCollectionView: UICollectionView!
    @IBOutlet weak var loadingContainerView: UIView!
    @IBOutlet weak var loadingView: NVActivityIndicatorView!
    @IBOutlet weak var attachmentImageView: FLAnimatedImageView!

    @IBOutlet weak var attachmentContainerView: UIView!
    @IBOutlet weak var singleAttachmentViewHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var multipleAttachmentViewHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var singleAttachmentView: UIView!
    
    @IBOutlet weak var multipleAttachmentView: UIView!
    
    @IBOutlet weak var headerTitleLabel: UILabel!
    @IBOutlet weak var headerHeightLayoutConstraint: NSLayoutConstraint!
    @IBOutlet weak var headerView: MessageTableHeaderView!
    
    
    enum AttachmentStyle {
        case single
        case multiple
        case loading
        case none
    }
    
    lazy var dateFormatter: DriftDateFormatter = DriftDateFormatter()

    var indexPath: IndexPath?
    var message: Message?
    var configuration: Configuration?
    weak var conversationDelegate: ConversationCellDelegate?
    weak var delegate: AttachementSelectedDelegate?
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        timeLabel.textColor = Style.navyDark
        nameLabel.addGestureRecognizer(UITapGestureRecognizer.init(target:self, action: #selector(ConversationMessageTableViewCell.showProfile)))
        nameLabel.isUserInteractionEnabled = true
        avatarView.delegate = self
        messageTextView.textContainer.lineFragmentPadding = 0
        messageTextView.textContainerInset = UIEdgeInsets.zero
        selectionStyle = .none
        attachmentsCollectionView.register(UINib.init(nibName: "AttachmentCollectionViewCell", bundle: Bundle(for: AttachmentCollectionViewCell.classForCoder())), forCellWithReuseIdentifier: "AttachmentCollectionViewCell")
        attachmentsCollectionView.dataSource = self
        attachmentsCollectionView.delegate = self
        attachmentsCollectionView.backgroundColor = UIColor.white
        
        loadingContainerView.backgroundColor = UIColor(white: 0, alpha: 0.4)
        loadingContainerView.layer.cornerRadius = 6
        loadingContainerView.clipsToBounds = true
        loadingContainerView.alpha = 0
        attachmentImageView.layer.masksToBounds = true
        attachmentImageView.contentMode = .scaleAspectFill
        attachmentImageView.layer.cornerRadius = 3
        attachmentImageView.isUserInteractionEnabled = true
        let gestureRecognizer = UITapGestureRecognizer.init(target:self, action: #selector(ConversationMessageTableViewCell.imagePressed))
        attachmentImageView.addGestureRecognizer(gestureRecognizer)
    }
    
    func setupForMessage(message: Message, showHeader: Bool, configuration: Configuration?){
        self.message = message
        self.configuration = configuration
        setupHeader(message: message, show: showHeader)
        setStyle()
        setupForAttachments(message: message)
        
    }
    
    func setupHeader(message: Message, show: Bool){
        
        if show {
            headerTitleLabel.text = dateFormatter.headerStringFromDate(message.createdAt)
            headerHeightLayoutConstraint.constant = 42
            headerView.isHidden = false
        }else{
            headerHeightLayoutConstraint.constant = 0
            headerView.isHidden = true
        }
    }
    
    func setStyle(){
        avatarView.imageView.image = UIImage(named: "placeholderAvatar")!
        avatarView.delegate = self
        
        if let message = message{
            
            avatarView.imageView.image = UIImage(named: "placeholderAvatar")!
            avatarView.delegate = self
            
            let textColor: UIColor
            
            switch message.sendStatusEnum{
            case .Sent:
                textColor = Style.black
                avatarView.alpha = 1.0
                nameLabel.textColor = Style.black
                timeLabel.textColor = Style.navyDark
                timeLabel.text = dateFormatter.createdAtStringFromDate(date: message.createdAt)
            case .Pending:
                textColor = Style.navyDark
                timeLabel.text = "Sending..."
                timeLabel.textColor = Style.navyDark
                avatarView.alpha = 0.7
                nameLabel.textColor = Style.navyDark
            case .Failed:
                nameLabel.textColor = Style.navyMedium
                textColor = Style.navyMedium
                timeLabel.text = "Failed to send"
                timeLabel.textColor = Style.navyMedium
                avatarView.alpha = 0.7
                nameLabel.textColor = Style.navyDark
            }
            
            messageTextView.textColor = textColor
            
            if let conversationEvent = message.conversationEvent {
                
                let conversationEventText = conversationEvent.getTextForStatus()
                
                let font = UIFont(name: "AvenirNext-Italic", size: 16)!
                let paragraphStyle = NSMutableParagraphStyle()
                paragraphStyle.paragraphSpacing = 0.0
                let attributes = [NSFontAttributeName: font, NSParagraphStyleAttributeName: paragraphStyle, NSForegroundColorAttributeName: Style.navyDark]

                let attributedString = NSAttributedString(string: conversationEventText, attributes: attributes)
                messageTextView.attributedText = attributedString
                
            } else if let formattedString = message.formattedString {
                let finalString: NSMutableAttributedString = formattedString
                finalString.addAttribute(NSForegroundColorAttributeName, value: textColor, range: NSMakeRange(0, finalString.length))
                
                messageTextView.attributedText = finalString
            } else {
                messageTextView.text = message.body ?? " "
            }
            
            if let contentType = message.contentTypeEnum{
                switch contentType{
                    
                case .PrivateNote:
                    backgroundColor = Style.internalNote
                default:
                    backgroundColor = UIColor.white
                }
            }
            
            nameLabel.text = " "
            if message.authorTypeEnum == AuthorType.User{
                if let user = message.user{
                    setUser(name: user.name, email: user.email)
                    if user.bot {
                        avatarView.setupForBot(configuration: configuration)
                    }else{
                        avatarView.setUpForAvatarURL(avatarUrl: user.avatarURL)

                    }
                }
            }else{
                if let endUser = message.endUser{
                    setUser(name: endUser.name, email: endUser.email)
                    avatarView.setUpForAvatarURL(avatarUrl: endUser.avatarURL)
                }
            }
        }
    }
    
    func setupForAttachmentStyle(attachmentStyle: AttachmentStyle){
        
        switch attachmentStyle{
        case .multiple:
            singleAttachmentViewHeightConstraint.constant = 0
            multipleAttachmentViewHeightConstraint.constant = 65
            singleAttachmentView.isHidden = true
            multipleAttachmentView.isHidden = false
        case .single, .loading:
            singleAttachmentViewHeightConstraint.constant = 120
            multipleAttachmentViewHeightConstraint.constant = 0
            singleAttachmentView.isHidden = false
            multipleAttachmentView.isHidden = true
        case .none:
            singleAttachmentViewHeightConstraint.constant = 0
            multipleAttachmentViewHeightConstraint.constant = 0
            singleAttachmentView.isHidden = true
            multipleAttachmentView.isHidden = true
        }
    }
    
    func setupForAttachments(message: Message) {
        
        if message.attachmentIds.isEmpty == .some(true){
            //Hide them all
            setupForAttachmentStyle(attachmentStyle: .none)
        }else {
            if !message.attachments.isEmpty {
                //Attachments are loaded
         
                if message.attachments.count == 1 {
                    //Single Attachments
                    
                    let attachment = message.attachments.first!
                    
                    
                    if attachment.isImage(){
                        setupForAttachmentStyle(attachmentStyle: .single)
                        let url = attachment.generatePublicPreviewURL() ?? attachment.generatePublicURL()
                        self.attachmentImageView.startAnimating()
                        self.attachmentImageView.sd_setImage(with: url, placeholderImage: UIImage(named: "imagePlaceholder"))
                    }else{
                        setupForAttachmentStyle(attachmentStyle: .multiple)
                    }
                    
                } else {
                    //Multiple Attachments
                    setupForAttachmentStyle(attachmentStyle: .multiple)
                }
            } else {
                //Load Attachments let realm reload table for us with the update
                
                if message.attachmentIds.count == 1 {
                    setupForAttachmentStyle(attachmentStyle: .loading)
                }else{
                    setupForAttachmentStyle(attachmentStyle: .multiple)
                }
                
                AttachmentManager.sharedInstance.getAttachmentInfo(message.attachmentIds.map({ $0.value }), messageUUID: message.uuid)
            }
        }
        attachmentsCollectionView.reloadData()
    }
    
    func imagePressed(){
        if let attachment = message?.attachments.first{
            delegate?.attachmentSelected(attachment: attachment, sender: self, message: message)
        }
    }
    
    func showLoadingView(){
        loadingView.startAnimating()
        UIView.animate(withDuration: 0.3) {
            self.loadingContainerView.alpha = 1
        }
    }
    
    func hideLoadingView(){
        UIView.animate(withDuration: 0.3, animations: {
            self.loadingContainerView.alpha = 0
        }) { (done) in
            self.loadingView.stopAnimating()
        }
    }
    
    func setTimeLabel(date: Date) {
        let formatter = DateFormatter()
        formatter.dateFormat = "hh:mm a"
        timeLabel.textColor = Style.navyDark
        timeLabel.text = formatter.string(from: date)
    }
    
    func setUser(name: String?, email: String?){
        if name == nil && email == nil{
            nameLabel.text = "Site Visitor"
        }else{
            nameLabel.text = name == nil ? email : name
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let cell = cell as? AttachmentCollectionViewCell{
            if let attachment = message?.attachments[indexPath.row] {
                let fileName: NSString = attachment.fileName as NSString
                let fileExtension = fileName.pathExtension
                cell.fileNameLabel.text = "\(fileName)"
                cell.fileExtensionLabel.text = "\(fileExtension.uppercased())"
                
                let formatter = ByteCountFormatter()
                formatter.countStyle = .memory
                formatter.string(fromByteCount: Int64(attachment.size))
                formatter.allowsNonnumericFormatting = false
                cell.sizeLabel.text = formatter.string(fromByteCount: Int64(attachment.size))
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = AttachmentCollectionViewCell.reuseCell(collectionView, indexPath: indexPath) as AttachmentCollectionViewCell
        cell.layer.cornerRadius = 3.0
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let count = message?.attachments.count ?? 0
        if count == 1 {
            if message!.attachments[0].isImage(){
                return 0
            }
        }
        return count
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        delegate?.attachmentSelected(attachment: message!.attachments[indexPath.row], sender: self, message: message)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if let attachments = message?.attachments {
            if let attachment = attachments.first, attachments.count == 1, attachment.isImage(){
                return CGSize(width: 0, height: 0)
            }
            return CGSize(width: 200, height: 55)
        }
        return CGSize(width: 0, height: 0)
    }

    func showProfile() {
        if let indexPath = indexPath{
            conversationDelegate?.showProfileForRow(indexPath: indexPath)
        }
    }
}

extension ConversationMessageTableViewCell: AvatarDelegate{
    func avatarPressed() {
        showProfile()
    }
}
