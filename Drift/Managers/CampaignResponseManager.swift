//
//  CampaignResponseManager.swift
//  Drift
//
//  Created by Eoin O'Connell on 03/02/2016.
//  Copyright © 2016 Drift. All rights reserved.
//

enum CampaignResponse{
    case NPS(NPSResponse)
    case Announcment(AnnouncmentResponse)
}

enum NPSResponse {
    case Dismissed
    case Numeric(Int)
    case TextAndNumeric(Int, String)
}

enum AnnouncmentResponse: String {
    case Opened = "OPENED"
    case Dismissed = "DISMISSED"
    case Clicked = "CLICKED"
}

class CampaignResponseManager {
    
    class func recordAnnouncmentResponse(campaign: Campaign, response: AnnouncmentResponse){
        
        LoggerManager.log("Recording Announcment Response:\(response) \(campaign.conversationId) ")
        
        guard let auth = DriftDataStore.sharedInstance.auth?.accessToken else {
            LoggerManager.log("No Auth Token for Recording")
            return
        }
        
        guard let conversationId = campaign.conversationId else{
            LoggerManager.log("No Conversation Id in campaign")
            return
        }
        if let uuid = campaign.uuid where !DriftManager.sharedInstance.debug{
            CampaignsManager.markConversationAsRead(uuid)
        }
        
        if !DriftManager.sharedInstance.debug {
            APIManager.recordAnnouncment(conversationId, authToken: auth, response: response)
        }
    }
    
    class func recordNPSResponse(campaign: Campaign, response: NPSResponse){
        LoggerManager.log("Recording NPS Response:\(response) \(campaign.conversationId) ")
        
        
        guard let auth = DriftDataStore.sharedInstance.auth?.accessToken else {
            LoggerManager.log("No Auth Token for Recording")
            return
        }
        
        guard let conversationId = campaign.conversationId else{
            LoggerManager.log("No Conversation Id in campaign")
            return
        }
        
        if let uuid = campaign.uuid where !DriftManager.sharedInstance.debug{
            CampaignsManager.markConversationAsRead(uuid)
        }
        
        if !DriftManager.sharedInstance.debug {
            APIManager.recordNPS(conversationId, authToken: auth, response: response)
        }
        
    }
    
}
