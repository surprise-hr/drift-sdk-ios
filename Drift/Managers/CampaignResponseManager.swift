//
//  CampaignResponseManager.swift
//  Drift
//
//  Created by Eoin O'Connell on 03/02/2016.
//  Copyright © 2016 Drift. All rights reserved.
//

enum CampaignResponse{
    case nps(NPSResponse)
    case announcement(AnnouncementResponse)
}

enum NPSResponse {
    case dismissed
    case numeric(Int)
    case textAndNumeric(Int, String)
}

enum AnnouncementResponse: String {
    case Opened = "OPENED"
    case Dismissed = "DISMISSED"
    case Clicked = "CLICKED"
}

class CampaignResponseManager {
    
    class func recordAnnouncementResponse(_ campaign: Campaign, response: AnnouncementResponse){
        
        LoggerManager.log("Recording Announcement Response:\(response) \(String(describing: campaign.conversationId)) ")

        guard let auth = DriftDataStore.sharedInstance.auth?.accessToken else {
            LoggerManager.log("No Auth Token for Recording")
            return
        }
        
        guard let conversationId = campaign.conversationId else{
            LoggerManager.log("No Conversation Id in campaign")
            return
        }
        
        if let id = campaign.id, !DriftManager.sharedInstance.debug{
            CampaignsManager.markCampaignAsRead(id)
        }
        
        if !DriftManager.sharedInstance.debug {
            DriftAPIManager.recordAnnouncement(conversationId, authToken: auth, response: response)
        }
    }
    
    class func recordNPSResponse(_ campaign: Campaign, response: NPSResponse){

        LoggerManager.log("Recording NPS Response:\(response) \(String(describing: campaign.conversationId)) ")
        
        guard let auth = DriftDataStore.sharedInstance.auth?.accessToken else {
            LoggerManager.log("No Auth Token for Recording")
            return
        }
        
        guard let conversationId = campaign.conversationId else{
            LoggerManager.log("No Conversation Id in campaign")
            return
        }
        
        if let id = campaign.id, !DriftManager.sharedInstance.debug{
            CampaignsManager.markCampaignAsRead(id)
        }
        
        if !DriftManager.sharedInstance.debug {
            DriftAPIManager.recordNPS(conversationId, authToken: auth, response: response)
        }
    }
    
}
