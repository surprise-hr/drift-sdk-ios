//
//  ConversationViewController.swift
//  Drift
//
//  Created by Brian McDonald on 28/07/2016.
//  Copyright © 2016 Drift. All rights reserved.
//

import UIKit
import SlackTextViewController
import QuickLook
import LayerKit
import ObjectMapper

class DriftPreviewItem: NSObject, QLPreviewItem{
    var previewItemURL: URL?
    var previewItemTitle: String?
    
    init(url: URL, title: String){
        self.previewItemURL = url
        self.previewItemTitle = title
    }
}

public protocol AttachementSelectedDelegate: class{
    func attachmentSelected(_ attachment: Attachment, sender: AnyObject)
}

class ConversationViewController: SLKTextViewController {
    
    enum ConversationType {
        case createConversation(authorId: Int?)
        case continueConversation(conversationId: Int)
    }
    
    let emptyState = ConversationEmptyStateView.fromNib() as! ConversationEmptyStateView
    var sections: [[Message]] = []
    var previewItem: DriftPreviewItem?
    var dateFormatter: DriftDateFormatter = DriftDateFormatter()
    
    var conversationType: ConversationType! {
        didSet{
            if case ConversationType.continueConversation(let conversationId) = conversationType!{
                self.conversationId = conversationId
                InboxManager.sharedInstance.addMessageSubscription(MessageSubscription(delegate: self, conversationId: conversationId))
            }
        }
    }

    var conversationId: Int?{
        didSet{
            leftButton.isEnabled = true
            leftButton.tintColor = DriftDataStore.sharedInstance.generateBackgroundColor()
            leftButton.setImage(UIImage.init(named: "plus-circle", in: Bundle(for: Drift.self), compatibleWith: nil), for: UIControlState())
            textView.placeholder = "Message"
        }
    }
    
    func setConversationType(_ conversationType: ConversationType){
        self.conversationType = conversationType
    }
    
    convenience init(conversationType: ConversationType) {
        self.init(tableViewStyle: UITableViewStyle.grouped)
        setConversationType(conversationType)
    }

    class func navigationController(_ conversationType: ConversationType) -> UINavigationController {
        let vc = ConversationViewController.init(conversationType: conversationType)
        let navVC = UINavigationController.init(rootViewController: vc)
        
        let leftButton = UIBarButtonItem.init(image: UIImage.init(named: "closeIcon", in: Bundle.init(for: ConversationViewController.classForCoder()), compatibleWith: nil), style: UIBarButtonItemStyle.plain, target:vc, action: #selector(ConversationViewController.dismissVC))
        leftButton.tintColor = DriftDataStore.sharedInstance.generateForegroundColor()
        vc.navigationItem.leftBarButtonItem  = leftButton

        return navVC
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSlackTextView()
        
        tableView?.rowHeight = UITableViewAutomaticDimension
        tableView?.estimatedRowHeight = 65
        tableView?.register(UINib.init(nibName: "ConversationMessageTableViewCell", bundle: Bundle(for: ConversationMessageTableViewCell.classForCoder())), forCellReuseIdentifier: "ConversationMessageTableViewCell")
        tableView?.register(UINib.init(nibName: "ConversationImageTableViewCell", bundle: Bundle(for: ConversationImageTableViewCell.classForCoder())), forCellReuseIdentifier: "ConversationImageTableViewCell")
        tableView?.register(UINib.init(nibName: "ConversationAttachmentsTableViewCell", bundle: Bundle(for: ConversationAttachmentsTableViewCell.classForCoder())), forCellReuseIdentifier: "ConversationAttachmentsTableViewCell")
        
        if let navVC = navigationController {
            navVC.navigationBar.barTintColor = DriftDataStore.sharedInstance.generateBackgroundColor()
            navVC.navigationBar.tintColor = DriftDataStore.sharedInstance.generateForegroundColor()
            navVC.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: DriftDataStore.sharedInstance.generateForegroundColor(), NSFontAttributeName: UIFont.init(name: "AvenirNext-Medium", size: 16)!]
            navigationItem.title = "Conversation"
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(ConversationViewController.didOpen), name: NSNotification.Name.UIApplicationWillEnterForeground, object: nil)
        
        didOpen()
    }
    
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    
    func didOpen() {
        switch conversationType! {
        case .continueConversation(let conversationId):
            self.conversationId = conversationId
            getMessages(conversationId)
        case .createConversation(_):
            if let organizationName = DriftDataStore.sharedInstance.embed?.organizationName {
                emptyState.organizationLabel.text = organizationName
            }
        
            emptyState.messageLabel.backgroundColor = DriftDataStore.sharedInstance.generateBackgroundColor()
            emptyState.messageLabel.textColor = DriftDataStore.sharedInstance.generateForegroundColor()

            if let welcomeMessage = DriftDataStore.sharedInstance.embed?.welcomeMessage {
                emptyState.messageLabel.text = welcomeMessage
            }
            
            emptyState.center.x = view.center.x
            emptyState.center.y = view.center.y - UIScreen.main.bounds.height/4
            view.addSubview(emptyState)
        }
    }
    
    
    func setupSlackTextView() {
        tableView?.backgroundColor = UIColor.white
        leftButton.tintColor = UIColor.lightGray
        textInputbar.barTintColor = UIColor.white
        leftButton.isEnabled = false
        leftButton.setImage(UIImage.init(named: "plus-circle", in: Bundle(for: Drift.self), compatibleWith: nil), for: UIControlState())
        isInverted = true
        shouldScrollToBottomAfterKeyboardShows = false
        bounces = true
        tableView?.separatorStyle = .none
        
        if let organizationName = DriftDataStore.sharedInstance.embed?.organizationName {
            textView.placeholder = "Message \(organizationName)"
        }else{
            textView.placeholder = "Message"
        }
    }
    
    
    func dismissVC() {
        resignFirstResponder()
        self.dismiss(animated: true, completion: nil)
    }
    
    
    override func didPressLeftButton(_ sender: Any?) {

        let uploadController = UIAlertController.init(title: nil, message: nil, preferredStyle: .actionSheet)
       
        if UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.pad {
            uploadController.modalPresentationStyle = .popover
            let popover = uploadController.popoverPresentationController
            popover?.sourceView = self.leftButton
            popover?.sourceRect = self.leftButton.bounds
        }
        
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        
        uploadController.addAction(UIAlertAction(title: "Take a Photo", style: .default, handler: { (UIAlertAction) in
            imagePicker.sourceType = .camera
            self.present(imagePicker, animated: true, completion: nil)
        }))
        
        uploadController.addAction(UIAlertAction(title: "Choose From Library", style: .default, handler: { (UIAlertAction) in
            imagePicker.sourceType = .photoLibrary
            self.present(imagePicker, animated: true, completion: nil)
        }))

        uploadController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(uploadController, animated: true, completion: nil)
    }
    
    override func didPressRightButton(_ sender: Any?) {
        let message = Message()
        message.body = textView.text
        message.authorId = Int(DriftDataStore.sharedInstance.auth!.enduser!.externalId!)
        self.textView.text = ""
        postMessage(message)
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let message = sections[(indexPath as NSIndexPath).section][(indexPath as NSIndexPath).row]
        
        var cell: UITableViewCell

        switch message.attachments.count{
        case 0:
            cell = tableView.dequeueReusableCell(withIdentifier: "ConversationMessageTableViewCell", for: indexPath) as! ConversationMessageTableViewCell
            if let cell = cell as? ConversationMessageTableViewCell{
                cell.message = message
            }
            
        case 1:
            cell = tableView.dequeueReusableCell(withIdentifier: "ConversationImageTableViewCell", for: indexPath) as! ConversationImageTableViewCell
            APIManager.getAttachmentsMetaData([message.attachments.first!], authToken: (DriftDataStore.sharedInstance.auth?.accessToken)!, completion: { (result) in
                switch result{
                case .success(let attachments):
                    let fileName: NSString = attachments.first!.fileName as NSString
                    let fileExtension = fileName.pathExtension
                    if fileExtension == "jpg" || fileExtension == "png" || fileExtension == "gif"{
                        if let cell = cell as? ConversationImageTableViewCell{
                            cell.delegate = self
                            cell.message = message
                            cell.attachment = attachments.first
                        }
                    }else{
                        cell = tableView.dequeueReusableCell(withIdentifier: "ConversationAttachmentsTableViewCell", for: indexPath) as! ConversationAttachmentsTableViewCell
                        if let cell = cell as? ConversationAttachmentsTableViewCell{
                            cell.delegate = self
                            cell.message = message
                        }
                    }
                    
                case .failure:
                    LoggerManager.log("Failed to get attachment metadata for id: \(message.attachments.first)")
                }
            })
            
        default:
            cell = tableView.dequeueReusableCell(withIdentifier: "ConversationAttachmentsTableViewCell", for: indexPath) as! ConversationAttachmentsTableViewCell
            if let cell = cell as? ConversationAttachmentsTableViewCell{
                cell.delegate = self
                cell.message = message
            }
        }
        
        cell.transform = tableView.transform
        return cell
    }
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if sections[section].count > 0{
            emptyState.isHidden = true
        }
        return sections[section].count
    }

    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let headerView: MessageTableHeaderView =  MessageTableHeaderView.fromNib("MessageTableHeaderView") as! MessageTableHeaderView
        
        //This handles the fact we need to have a header on the last (top when inverted) section.
        if section == 0{
            return nil
        }else if sections[section-1].count == 0 {
            headerView.headerLabel.text = "Today"
        }else {
            let message = sections[section-1][0]
            headerView.headerLabel.text = dateFormatter.headerStringFromDate(message.createdAt)
        }
        
        headerView.transform = tableView.transform
        return headerView
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0{
            return CGFloat.leastNormalMagnitude
        }else{
            return 42
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }
    
    func addMessageToConversation(_ message: Message){
        if sections.count > 0 && (Calendar.current as NSCalendar).component(.day, from: (sections[0].first?.createdAt)! as Date) ==  (Calendar.current as NSCalendar).component(.day, from: Date()){
            self.sections[0].insert(message, at: 0)
            tableView!.insertRows(at: [IndexPath(row: 0, section: 0)], with: .bottom)
        }else{
            self.sections.insert([message], at: 0)
            tableView?.insertSections(IndexSet.init(integer: 0), with: .bottom)
        }
    }
    
    
    func getSections(_ messages: [Message]) -> [[Message]]{
        let messagesReverse = messages.sorted(by: { $0.createdAt.compare($1.createdAt as Date) == .orderedDescending})
        
        var sections: [[Message]] = []
        var section: [Message] = []
        
        for message in messagesReverse{
            if section.count == 0{
                section.append(message)
            }else{
                let anchorMessage = section[0]
                if  (Calendar.current as NSCalendar).component(.day, from: message.createdAt as Date) !=  (Calendar.current as NSCalendar).component(.day, from: anchorMessage.createdAt as Date) ||  (Calendar.current as NSCalendar).component(.month, from: message.createdAt as Date) !=  (Calendar.current as NSCalendar).component(.month, from: anchorMessage.createdAt as Date) ||  (Calendar.current as NSCalendar).component(.year, from: message.createdAt as Date) !=  (Calendar.current as NSCalendar).component(.year, from: anchorMessage.createdAt as Date){
                    sections.append(section)
                    section = []
                }
                section.append(message)
                
                if messages.count-1 == messagesReverse.index(of: message){
                    sections.append(section)
                }
            }
        }
        
        if sections.count == 0 && section.count > 0{
            sections.append(section)
        }
        
        //Append an empty section to ensure we have a header on the top section
        sections.append([])
        
        return sections
    }

    
    func getMessages(_ conversationId: Int){
        APIManager.getMessages(conversationId, authToken: DriftDataStore.sharedInstance.auth!.accessToken) { (result) in
            switch result{
            case .success(let messages):
                let sorted = messages.sorted(by: { $0.createdAt.compare($1.createdAt as Date) == .orderedAscending})
                    self.sections = self.getSections(sorted)
                    self.tableView?.reloadData()
            case .failure:
                LoggerManager.log("Unable to get messages for conversationId: \(conversationId)")
            }
        }
    }
    
    
    func postMessage(_ messageRequest: Message){
        messageRequest.requestId = Date().timeIntervalSince1970
        messageRequest.type = Type.Chat
        addMessageToConversation(messageRequest)
        
        switch conversationType! {
        case .createConversation(let authodId):
            createConversationWithMessage(messageRequest, authorId: authodId)
        case .continueConversation(let conversationId):
            postMessageToConversation(conversationId, messageRequest: messageRequest)
        }
    }
    
    
    func postMessageToConversation(_ conversationId: Int, messageRequest: Message) {
        InboxManager.sharedInstance.postMessage(messageRequest, conversationId: conversationId) { (message, requestId) in
            if let index = self.sections[0].index(where: { (message1) -> Bool in
                if message1.requestId == messageRequest.requestId{
                    return true
                }
                return false
            }){
                if let message = message{
                    message.sendStatus = .Sent
                    self.sections[0][index] = message
                    
                }else{
                    let message = Message()
                    message.authorId = DriftDataStore.sharedInstance.auth?.enduser?.userId
                    message.body = messageRequest.body
                    message.requestId = messageRequest.requestId
                    message.sendStatus = .Failed
                    self.sections[0][index] = message
                }
            }
        }
    }
    
    
    func createConversationWithMessage(_ messageRequest: Message, authorId: Int?) {
        InboxManager.sharedInstance.createConversation(messageRequest, authorId: authorId) { (message, requestId) in
            if let index = self.sections[0].index(where: { (message1) -> Bool in
                if message1.requestId == messageRequest.requestId{
                    return true
                }
                return false
            }){
                if let message = message{
                    self.conversationType = ConversationType.continueConversation(conversationId: message.conversationId)
                    message.sendStatus = .Sent
                    self.sections[0][index] = message
                    self.conversationId = message.conversationId
                }else{
                    let message = Message()
                    message.authorId = DriftDataStore.sharedInstance.auth?.enduser?.userId
                    message.body = messageRequest.body
                    message.requestId = messageRequest.requestId
                    message.sendStatus = .Failed
                    self.sections[0][index] = message
                }
                
                self.tableView!.reloadRows(at: [IndexPath(row:0, section: 0)], with: .none)
                self.tableView?.scrollToRow(at: IndexPath(row:0, section: 0), at: .bottom, animated: true)
            }
        }
    }
}

extension ConversationViewController: MessageDelegate {
    
    func messagesDidUpdate(_ messages: [Message]) {
        let sorted = messages.sorted(by: { $0.createdAt.compare($1.createdAt as Date) == .orderedAscending})
        self.sections = self.getSections(sorted)
        self.tableView?.reloadData()
    }
    
    
    func newMessage(_ message: Message) {
        if let uuid = message.uuid{
            CampaignsManager.markConversationAsRead(uuid)
        }
        if message.authorId != DriftDataStore.sharedInstance.auth?.enduser?.userId{
            if let index = checkSectionsForMessages(message){
                    sections[(index as NSIndexPath).section][(index as NSIndexPath).row] = message
                    tableView!.reloadRows(at: [index], with: .bottom)
            }else{
                if (Calendar.current as NSCalendar).component(.day, from: (sections[0].first?.createdAt)! as Date) ==  (Calendar.current as NSCalendar).component(.day, from: Date()){
                    self.sections[0].insert(message, at: 0)
                    tableView!.insertRows(at: [IndexPath(row: 0, section: 0)], with: .bottom)
                }else{
                    self.sections.insert([message], at: 0)
                    tableView?.insertSections(IndexSet.init(integer: 0), with: .bottom)
                }
            }
        }
    }
    
    
    func checkSectionsForMessages(_ message: Message) -> IndexPath? {
        if let section = sections.index(where: { $0.contains(message) }) {
            if let row = sections[section].index(of: message) {
                return IndexPath(row: row, section: section)
            }
        }
        return nil
    }
    
}

extension ConversationViewController: AttachementSelectedDelegate {
    
    func attachmentSelected(_ attachment: Attachment, sender: AnyObject) {
        APIManager.downloadAttachmentFile(attachment, authToken: (DriftDataStore.sharedInstance.auth?.accessToken)!) { (result) in
            switch result{
            case .success(let tempFileURL):

                if sender.classForCoder == ConversationImageTableViewCell.classForCoder(){
                    self.previewItem = DriftPreviewItem(url: tempFileURL, title: attachment.fileName)
                    let qlController = QLPreviewController()
                    qlController.dataSource = self
                    self.present(qlController, animated: true, completion: nil)
                }else{
                    let interactionController = UIDocumentInteractionController()
                    interactionController.url = tempFileURL
                    interactionController.name = attachment.fileName
                    interactionController.presentOptionsMenu(from: CGRect.zero, in: self.view, animated: true)
                }
            case .failure:
                let alert = UIAlertController.init(title: "Unable to preview file", message: "This file cannot be previewed", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction.init(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                LoggerManager.log("Unable to preview file with mimeType: \(attachment.mimeType)")
            }
        }
    }
}

extension ConversationViewController: QLPreviewControllerDataSource {
    
    func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
        return 1
    }
    
    func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
        if let previewItem = previewItem{
            return previewItem
        }
        return DriftPreviewItem.init(url: URLComponents().url!, title: "")
    }
}

extension ConversationViewController: UIDocumentInteractionControllerDelegate{
    
    func documentInteractionControllerViewControllerForPreview(_ controller: UIDocumentInteractionController) -> UIViewController {
        return self
    }
    
    func documentInteractionControllerViewForPreview(_ controller: UIDocumentInteractionController) -> UIView? {
        return self.view
    }
    
    func documentInteractionControllerRectForPreview(_ controller: UIDocumentInteractionController) -> CGRect {
        return self.view.frame
    }
}


extension ConversationViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingImage image: UIImage!, editingInfo: [AnyHashable: Any]!) {
        picker.dismiss(animated: true, completion: nil)
        if let imageRep = UIImageJPEGRepresentation(image, 0.2){
            let newAttachment = Attachment()
            newAttachment.data = imageRep
            newAttachment.conversationId = conversationId!
            newAttachment.mimeType = "image/jpeg"
            newAttachment.fileName = "image.jpg"
            
            APIManager.postAttachment(newAttachment,authToken: DriftDataStore.sharedInstance.auth!.accessToken) { (result) in
                switch result{
                case .success(let attachment):
                    let messageRequest = Message()
                    messageRequest.attachments.append(attachment.id)
                    self.postMessage(messageRequest)
                case .failure:
                    let alert = UIAlertController.init(title: "Unable to upload file", message: nil, preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction.init(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                    LoggerManager.log("Unable to upload file with mimeType: \(newAttachment.mimeType)")

                }
            }
        }
    }
    
}
