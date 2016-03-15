//
//  AlertManager.swift
//  Drift
//
//  Created by Eoin O'Connell on 22/01/2016.
//  Copyright © 2016 Drift. All rights reserved.
//

import Foundation
import LayerKit

class CampaignsManager {
    /**
        Checks Layer for conversations
        Calls Presentation Manager to present any Campaigns to be shown
     */
    class func checkForCampaigns() throws{
        
        do {
            let convo = LYRQuery(queryableClass: LYRConversation.self)
            convo.predicate = LYRPredicate(property: "hasUnreadMessages", predicateOperator: LYRPredicateOperator.IsEqualTo, value: true)
            let conversationController = try LayerManager.sharedInstance.layerClient?.queryControllerWithQuery(convo)
            try conversationController?.execute()
            var announcments:[Campaign] = []
            if let countUInt = conversationController?.numberOfObjectsInSection(0) {
                let count = Int(countUInt)
                for index: Int in 0..<count {
                    if let conversation = conversationController?.objectAtIndexPath(NSIndexPath(forRow: index, inSection: 0)) as? LYRConversation {
                        LoggerManager.log("Conversation hasunread: \(conversation.hasUnreadMessages)")
                        LoggerManager.log("Conversation Id: \(conversation.identifier)")
                        let newAnnouncments = try getMessages(conversation)
                        announcments = announcments + newAnnouncments
                    }
                }
            }
            
            let filtered = filtercampaigns(announcments)
            PresentationManager.sharedInstance.didRecieveCampaigns(filtered.nps + filtered.announcments)
        } catch {
            LoggerManager.log("Error in checking conversations")
        }
    }
    
    
    /**
        Given a conversation get an array of campaigns for that conversation
        
        This will itterate through messages in a conversation and then its message parts searching for MimeType JSON and parse that into a campaign.
     
        - parameter conversation: Layer Conversation to traverse for campaigns
        - returns: All campaigns in a conversation - These are not SDK dependant - Should be parsed later for non presentable campaigns
     */
    class func getMessages(conversation: LYRConversation) throws -> [Campaign] {
                
        let messagesQuery:LYRQuery = LYRQuery(queryableClass: LYRMessage.self)
        messagesQuery.predicate = LYRPredicate(property: "conversation", predicateOperator: LYRPredicateOperator.IsEqualTo, value: conversation)
        messagesQuery.sortDescriptors = [NSSortDescriptor(key:"position", ascending:true)]
        let queryController = try LayerManager.sharedInstance.layerClient?.queryControllerWithQuery(messagesQuery)
        try queryController?.execute()
        
        var announcments:[Campaign] = []
        if let countUInt = queryController?.numberOfObjectsInSection(0) {
            let count = Int(countUInt)
            for index: Int in 0..<count {
                if let message = queryController?.objectAtIndexPath(NSIndexPath(forRow: index, inSection: 0)) as? LYRMessage {
                    
                    
                    for part in message.parts {
                        switch part.MIMEType {
//                        case "text/plain":
                        case "application/json":
                            
                            if let data = part.data, json = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments) as? [String: AnyObject] {
                                if let newAnnouncment = Campaign(json: json) where newAnnouncment.messageType != nil{
                                    announcments.append(newAnnouncment)
                                }
                            }
                            
                        default:
                            LoggerManager.log("Ignored MimeType")
                        }
                    }
                }
            }
        }
        return announcments
    }
    
    /**
        This is responsible for filtering an array of campaigns into NPS and Announcments
        This will also filter out non presentable campaigns
        - parameter campaign: Array of non filtered campaigns
        - returns: Tuple of NPS and Announcment Type Campaigns that are presentable in SDK
    */
    class func filtercampaigns(campaigns: [Campaign]) -> (nps: [Campaign], announcments: [Campaign]){
        
        ///GET NPS or NPS_RESPONSE
        
        ///DO Priority - Announcements before NPS Latest first
        
        var npsResponse: [Campaign] = []
        var nps: [Campaign] = []
        var announcments: [Campaign] = []
        
        for campaign in campaigns {
            
            switch campaign.messageType {
                
            case .Some(.NPS):
                nps.append(campaign)
            case .Some(.NPSResponse):
                npsResponse.append(campaign)
            case .Some(.Announcement):
                //Only show chat response announcments if we have an email
                if let ctaType = campaign.announcmentAttributes?.cta?.ctaType where ctaType == .ChatResponse{
                    if let email = DriftDataStore.sharedInstance.embed?.inboxEmailAddress where email != ""{
                        announcments.append(campaign)
                    }else{
                        LoggerManager.log("Did remove chat announcment as we dont have an email")
                    }
                }else{
                    announcments.append(campaign)
                }
            default:
                ()
            }
        }
        
        let npsResponseIds = npsResponse.flatMap { $0.conversationId }
        
    
        nps = nps.filter {
            if let conversationId = $0.conversationId {
                return !npsResponseIds.contains(conversationId)
            }
            return false
        }
        
        return (nps, announcments)
    }
    
    
    /**
     Given a message ID this function marks it as read in Layer
    
     - parameter messageId:
     */
    class func markConversationAsRead(messageId: String) {
        guard let messageId = NSURL(string: "layer:///messages/\(messageId)") else{
            return
        }
        
        do {
            let messagesQuery:LYRQuery = LYRQuery(queryableClass: LYRMessage.self)

            messagesQuery.predicate = LYRPredicate(property: "identifier", predicateOperator: LYRPredicateOperator.IsEqualTo, value: messageId)
            let queryController = try LayerManager.sharedInstance.layerClient?.queryControllerWithQuery(messagesQuery)
            try queryController?.execute()
            if let countUInt = queryController?.numberOfObjectsInSection(0) {
                let count = Int(countUInt)
                for index: Int in 0..<count {
                    if let message = queryController?.objectAtIndexPath(NSIndexPath(forRow: index, inSection: 0)) as? LYRMessage {
                        LoggerManager.log("Marking as Read: \(messageId)")
                        try message.markAsRead()
                    }
                }
            }
        } catch let error as NSError {
            LoggerManager.didRecieveError(error)
        }
    }
}