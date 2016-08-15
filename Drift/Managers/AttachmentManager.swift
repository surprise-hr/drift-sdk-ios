//
//  AttachmentManager.swift
//  Drift
//
//  Created by Brian McDonald on 29/07/2016.
//  Copyright © 2016 Drift. All rights reserved.
//

import Foundation

public class AttachmentManager{
    let fileManager = NSFileManager.defaultManager()
    public static let sharedInstance: AttachmentManager = AttachmentManager()
    
    public func getAttachmentFile(attachment: Attachment, completion: (NSURL?)->()){
        let documentPath: NSString = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true).first!
        let filePath = documentPath.stringByAppendingPathComponent("\(attachment.id).\(attachment.fileName.componentsSeparatedByString(".").last!)")
        if fileManager.fileExistsAtPath(filePath){
            completion(NSURL.init(string: filePath))
        }else{
            var localPath: NSURL?
            let pathComponent = "\(attachment.id).\(attachment.fileName.componentsSeparatedByString(".").last!)"
            let directoryURL = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)[0]
            localPath = directoryURL.URLByAppendingPathComponent(pathComponent)
//            APIManager.sharedManager.download(ConversationRouter.GetAttachmentFile(id: attachment.id),
//                destination: { (temporaryURL, response) in
//                    return localPath!
//            })
//                .response { (request, response, _, error) in
//                    completion(NSURL.init(string: filePath))
//            }
        }
    }
    
    public func getAttachmentInfo(id: Int, completion:(Attachment?) -> ()){

//        APIManager.getAttachmentsMetaData(id, authToken:)
//        APIManager.getAttachment(id) { (result) in
//            switch result{
//            case .Success(let attachment):
//                
//                completion(attachment)
//            case .Failure:
//                print("Unable to get attachment for id: \(id)")
//                completion(nil)
//            }
//        }
        
    }
}