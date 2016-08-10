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
    var previewItemURL: NSURL
    var previewItemTitle: String?
    
    init(url: NSURL, title: String){
        self.previewItemURL = url
        self.previewItemTitle = title
    }
}

public protocol AttachementSelectedDelegate: class{
    func attachmentSelected(id: Int, sender: AnyObject)
}


class ConversationViewController: SLKTextViewController {
    
    enum ConversationType {
        case CreateConversation(authodId: Int?)
        case ContinueConversation(conversationId: Int)
    }
    
    var conversationType: ConversationType!
    var sections: [[Message]] = []
    var messages: [Message] = []
    var previewItem: DriftPreviewItem?
    var dateFormatter: DriftDateFormatter = DriftDateFormatter()
    
    convenience init(conversationType: ConversationType) {
        self.init(nibName: "ConversationViewController", bundle: NSBundle(forClass: ConversationViewController.classForCoder()))
        self.conversationType = conversationType
    }
    
    class func navigationController(conversationType: ConversationType) -> UINavigationController {
        let vc = ConversationViewController.init(conversationType: conversationType)
        let navVC = UINavigationController.init(rootViewController: vc)
        return navVC
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSlackTextView()
        tableView?.rowHeight = UITableViewAutomaticDimension
        tableView?.estimatedRowHeight = 65
        tableView?.registerNib(UINib.init(nibName: "ConversationMessageTableViewCell", bundle: NSBundle(forClass: ConversationMessageTableViewCell.classForCoder())), forCellReuseIdentifier: "ConversationMessageTableViewCell")
        tableView?.registerNib(UINib.init(nibName: "ConversationImageTableViewCell", bundle: NSBundle(forClass: ConversationImageTableViewCell.classForCoder())), forCellReuseIdentifier: "ConversationImageTableViewCell")
        tableView?.registerNib(UINib.init(nibName: "ConversationAttachmentsTableViewCell", bundle: NSBundle(forClass: ConversationAttachmentsTableViewCell.classForCoder())), forCellReuseIdentifier: "ConversationAttachmentsTableViewCell")
        
        if let navVC = navigationController {
            navVC.navigationBar.barTintColor = DriftDataStore.sharedInstance.generateBackgroundColor()
            navVC.navigationBar.tintColor = DriftDataStore.sharedInstance.generateForegroundColor()
            navVC.navigationBar.translucent = false
            let leftButton = UIBarButtonItem(title: "Close", style: UIBarButtonItemStyle.Done, target: self, action: #selector(ConversationViewController.dismiss))
            navigationItem.leftBarButtonItem  = leftButton
            navigationItem.title = "Conversation"
        }
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ConversationViewController.didOpen), name: UIApplicationWillEnterForegroundNotification, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ConversationViewController.didUpdateMessages(_:)), name: LYRClientObjectsDidChangeNotification, object: nil)

        didOpen()
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    func didOpen(){
        switch conversationType! {
        case .ContinueConversation(let conversationId):
            getMessages(conversationId)
        case .CreateConversation(_):
            ()
            ///TODO: Show empty State
        }
    }
    
    func didUpdateMessages(notification : NSNotification ) {
        print("🤘🤘Did Update Message🤘🤘")
        if case ConversationType.ContinueConversation(let conversationId) = conversationType!{
            
            if let changes = notification.userInfo?[LYRClientObjectChangesUserInfoKey] as? [LYRObjectChange] {
                for change in changes {
                    if let message = change.object as? LYRMessage {
                        if change.type == .Create {
                            for part in message.parts {
                                switch part.MIMEType {
                                //                        case "text/plain":
                                case "application/json":
                                    LoggerManager.log("Mapping Mime Type")
                                    do {
                                        if let data = part.data, json = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments) as? [String: AnyObject] {
                                            if let newMessage = Mapper<Message>().map(json) {
                                                if newMessage.conversationId == conversationId {
                                                    self.newMessage(newMessage)
                                                }
                                            }
                                        }
                                    }catch {
                                        LoggerManager.log("JSON Map Failure")

                                    }
                                    
                                default:
                                    LoggerManager.log("Ignored MimeType")
                                }
                            }

                        }
                    }
                }
            }
        }
    }
    
    func setupSlackTextView(){
        leftButton.tintColor = UIColor.lightGrayColor()
        leftButton.setImage(UIImage.init(named: "plus-circle", inBundle: NSBundle(forClass: Drift.self), compatibleWithTraitCollection: nil), forState: .Normal)
        inverted = true
        shouldScrollToBottomAfterKeyboardShows = false
        bounces = true
        tableView?.separatorStyle = .None
        textView.placeholder = "Message"
    }
    
    override class func tableViewStyleForCoder(decoder: NSCoder) -> UITableViewStyle {
        return .Plain
    }
    
    func dismiss(){
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func didPressLeftButton(sender: AnyObject?) {

        let uploadController = UIAlertController.init(title: nil, message: nil, preferredStyle: .ActionSheet)
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        uploadController.addAction(UIAlertAction(title: "Take a Photo", style: .Default, handler: { (UIAlertAction) in
            imagePicker.sourceType = .Camera
            self.presentViewController(imagePicker, animated: true, completion: nil)
        }))
        uploadController.addAction(UIAlertAction(title: "Choose From Library", style: .Default, handler: { (UIAlertAction) in
            imagePicker.sourceType = .PhotoLibrary
            self.presentViewController(imagePicker, animated: true, completion: nil)
        }))
//        uploadController.addAction(UIAlertAction(title: "Import File From...", style: .Default, handler: { (UIAlertAction) in
//            let documentPicker = UIDocumentMenuViewController.init(documentTypes: ["public.data"], inMode: .Import)
//            documentPicker.delegate = self
//            documentPicker.modalPresentationStyle = .FormSheet
//            self.presentViewController(documentPicker, animated: true, completion: nil)
//        }))
        uploadController.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
        presentViewController(uploadController, animated: true, completion: nil)
    }
    
    override func didPressRightButton(sender: AnyObject?) {
        let message = Message()
        message.body = textView.text
        message.authorId = Int(DriftDataStore.sharedInstance.auth!.enduser!.externalId!)
        self.textView.text = ""
        postMessage(message)
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let message = sections[indexPath.section].reverse()[indexPath.row]
        let cell: UITableViewCell
        
        if message.attachments.count > 0{
            cell = tableView.dequeueReusableCellWithIdentifier("ConversationAttachmentsTableViewCell", forIndexPath: indexPath) as! ConversationAttachmentsTableViewCell
        }else{
            cell = tableView.dequeueReusableCellWithIdentifier("ConversationMessageTableViewCell", forIndexPath: indexPath) as! ConversationMessageTableViewCell
            if let cell = cell as? ConversationMessageTableViewCell{
                cell.message = message
            }
        }
        
        cell.transform = tableView.transform
        return cell
    }
    
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        let message = sections[indexPath.section].reverse()[indexPath.row]
        if let cell = cell as? ConversationMessageTableViewCell{
            cell.message = message
        }

    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].count
    }

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return sections.count
    }
    
    override func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let headerView: MessageTableHeaderView =  MessageTableHeaderView.fromNib("MessageTableHeaderView") as! MessageTableHeaderView
        let message = sections[section][0]
        headerView.headerLabel.text = dateFormatter.headerStringFromDate(message.createdAt)
        headerView.transform = tableView.transform
        return headerView
    }
    
    
    override func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 42
    }
    
    
    func addMessageToConversation(message: Message){
        if sections.count > 0 && NSCalendar.currentCalendar().component(.Day, fromDate: (sections[0].first?.createdAt)!) ==  NSCalendar.currentCalendar().component(.Day, fromDate: NSDate()){
            self.sections[0].append(message)
            tableView!.insertRowsAtIndexPaths([NSIndexPath(forRow: 0, inSection: 0)], withRowAnimation: .Bottom)
        }else{
            self.sections.insert([message], atIndex: 0)
            tableView?.insertSections(NSIndexSet.init(index: 0), withRowAnimation: .Bottom)
        }
    }
    
    
    func getSections() -> [[Message]]{
        var sections: [[Message]] = []
        var section: [Message] = []
        let messagesReverse: [Message] = messages.reverse()
        
        for message in messagesReverse{
            if section.count == 0{
                section.append(message)
            }else{
                let anchorMessage = section[0]
                if  NSCalendar.currentCalendar().component(.Day, fromDate: message.createdAt) !=  NSCalendar.currentCalendar().component(.Day, fromDate: anchorMessage.createdAt) ||  NSCalendar.currentCalendar().component(.Month, fromDate: message.createdAt) !=  NSCalendar.currentCalendar().component(.Month, fromDate: anchorMessage.createdAt) ||  NSCalendar.currentCalendar().component(.Year, fromDate: message.createdAt) !=  NSCalendar.currentCalendar().component(.Year, fromDate: anchorMessage.createdAt){
                    sections.insert(section, atIndex: 0)
                    section = []
                }
                section.append(message)
                
                if messages.count-1 == messagesReverse.indexOf(message){
                    sections.insert(section, atIndex: 0)
                }
            }
        }
        
        if sections.count == 0 && section.count > 0{
            sections.insert(section, atIndex: 0)
        }
        
        return sections
    }
    

    func getMessages(conversationId: Int){
    
        APIManager.getMessages(conversationId, authToken: DriftDataStore.sharedInstance.auth!.accessToken) { (result) in
            switch result{
            case .Success(let messages):
                
                let sorted = Set(messages.sort({ $0.createdAt.compare($1.createdAt) == .OrderedAscending}))
                
                let newMessages = sorted.subtract(self.messages)
                
                dispatch_async(dispatch_get_main_queue(), { 
                   self.didRecieveMessages(Array(newMessages))
                })
            case .Failure:
                LoggerManager.log("Unable to get messages for conversationId: \(conversationId)")
            }
        }
    }
    
    func didRecieveMessages(messages: [Message]){
        if self.messages.isEmpty{
            self.messages = messages
            self.sections = self.getSections()
            self.tableView?.reloadData()
        }else{
            for message in messages {
                newMessage(message)
            }
        }
    }
    
    func postMessage(messageRequest: Message){
        messageRequest.requestId = NSDate().timeIntervalSince1970
        addMessageToConversation(messageRequest)
        
        switch conversationType! {
        case .CreateConversation(let authodId):
            createConversationWithMessage(messageRequest, authorId: authodId)
        case .ContinueConversation(let conversationId):
            postMessageToConversation(conversationId, messageRequest: messageRequest)
        }
    }
    
    func postMessageToConversation(conversationId: Int, messageRequest: Message) {
        InboxManager.sharedInstance.postMessage(messageRequest, conversationId: conversationId) { (message, requestId) in
            if let index = self.sections[0].indexOf({ (message1) -> Bool in
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
    
    func createConversationWithMessage(messageRequest: Message, authorId: Int?) {
        InboxManager.sharedInstance.createConversation(messageRequest, authorId: authorId) { (message, requestId) in
            
            if let index = self.sections[0].indexOf({ (message1) -> Bool in
                if message1.requestId == messageRequest.requestId{
                    return true
                }
                return false
            }){
                if let message = message{
                    self.conversationType = ConversationType.ContinueConversation(conversationId: message.conversationId)
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
}

extension ConversationViewController: MessageDelegate{
    func messagesDidUpdate(messages: [Message]) {
        if messages.count > self.messages.count{
            self.messages = messages
            tableView?.reloadData()
        }
    }
    
    func newMessage(message: Message) {
        if message.authorId != DriftDataStore.sharedInstance.auth?.enduser?.userId{
            if let index = messages.indexOf(message){
                if message.attachments.count > 0{
                    AttachmentManager.sharedInstance.getAttachmentInfo(message.attachments.first!, completion: { (attachment) in
                        self.messages[index] = message
                        self.tableView!.reloadRowsAtIndexPaths([NSIndexPath(forRow: index, inSection: 0)], withRowAnimation: .Bottom)
                    })
                }else{
                    messages[index] = message
                    tableView!.reloadRowsAtIndexPaths([NSIndexPath(forRow: index, inSection: 0)], withRowAnimation: .Bottom)
                }
            }else{
                if  NSCalendar.currentCalendar().component(.Day, fromDate: (sections[0].first?.createdAt)!) ==  NSCalendar.currentCalendar().component(.Day, fromDate: NSDate()){
                    if message.attachments.count > 0{
                        AttachmentManager.sharedInstance.getAttachmentInfo(message.attachments.first!, completion: { (attachment) in
                            self.sections[0].append(message)
                            self.tableView!.insertRowsAtIndexPaths([NSIndexPath(forRow: 0, inSection: 0)], withRowAnimation: .Bottom)
                        })
                    }else{
                        self.sections[0].append(message)
                        tableView!.insertRowsAtIndexPaths([NSIndexPath(forRow: 0, inSection: 0)], withRowAnimation: .Bottom)
                    }
                }else{
                    if message.attachments.count > 0{
                        AttachmentManager.sharedInstance.getAttachmentInfo(message.attachments.first!, completion: { (attachment) in
                            self.sections.insert([message], atIndex: 0)
                            self.tableView?.insertSections(NSIndexSet.init(index: 0), withRowAnimation: .Bottom)
                        })
                    }else{
                        self.sections.insert([message], atIndex: 0)
                        tableView?.insertSections(NSIndexSet.init(index: 0), withRowAnimation: .Bottom)
                    }
                }
            }
        }
    }
}

extension ConversationViewController: AttachementSelectedDelegate{
    func attachmentSelected(id: Int, sender: AnyObject) {
                
        AttachmentManager.sharedInstance.getAttachmentInfo(id) { (attachment) in
            if let attachment = attachment{
                AttachmentManager.sharedInstance.getAttachmentFile(attachment, completion: { (fileUrl) in
                    if let fileUrl = fileUrl{
                        if sender.classForCoder == ConversationImageTableViewCell.classForCoder(){
                            self.previewItem = DriftPreviewItem(url:NSURL.fileURLWithPath((fileUrl.absoluteString)), title: attachment.fileName)
                            let qlController = QLPreviewController()
                            qlController.dataSource = self
                            self.presentViewController(qlController, animated: true, completion: nil)
                                
                        }else{
                            let interactionController = UIDocumentInteractionController()
                            interactionController.URL = NSURL.fileURLWithPath((fileUrl.absoluteString))
                            interactionController.name = attachment.fileName
                            interactionController.presentOptionsMenuFromRect(CGRectZero, inView: self.view, animated: true)
                        }
                        
                    }else{
//                        self.showAlert("Unable to preview file", message: "\(attachment.fileName) cannot be previewed")
                    }
                })
            }
        }
    }
}

extension ConversationViewController: QLPreviewControllerDataSource{
    func numberOfPreviewItemsInPreviewController(controller: QLPreviewController) -> Int {
        return 1
    }
    
    func previewController(controller: QLPreviewController, previewItemAtIndex index: Int) -> QLPreviewItem{
        if let previewItem = previewItem{
            return previewItem
        }
        return NSURL()
    }
}

extension ConversationViewController: UIDocumentInteractionControllerDelegate{
    func documentInteractionControllerViewControllerForPreview(controller: UIDocumentInteractionController) -> UIViewController {
        return self
    }
    
    func documentInteractionControllerViewForPreview(controller: UIDocumentInteractionController) -> UIView? {
        return self.view
    }
    
    func documentInteractionControllerRectForPreview(controller: UIDocumentInteractionController) -> CGRect {
        return self.view.frame
    }
}


extension ConversationViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        picker.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage!, editingInfo: [NSObject : AnyObject]!) {
        picker.dismissViewControllerAnimated(true, completion: nil)
        let newAttachment = Attachment()
        if let imageRep = UIImageJPEGRepresentation(image, 0.2){
            newAttachment.data = imageRep
//            newAttachment.conversationId = conversationId
            newAttachment.mimeType = "image/jpeg"
            newAttachment.fileName = "image.jpg"
            APIManager.postAttachment(newAttachment) { (result) in
                switch result{
                case .Success(let attachment):
                    let messageRequest = Message()
                    messageRequest.attachments.append(attachment.id)
                    self.postMessage(messageRequest)
                case .Failure:
                    print("Failed to upload attachment file")
                }
            }

        }
    }
}