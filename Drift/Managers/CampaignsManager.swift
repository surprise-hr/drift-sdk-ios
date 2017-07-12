//
//  AlertManager.swift
//  Drift
//
//  Created by Eoin O'Connell on 22/01/2016.
//  Copyright © 2016 Drift. All rights reserved.
//

import Foundation

class CampaignsManager {

    class func checkForCampaigns(userId: Int) {
        DriftAPIManager.getCampaigns(userId) { (result) in
            switch result {
            case .success(let campaignWrappers):
                var campaigns: [Campaign] = []
                for campaignWrapper in campaignWrappers {
                    campaigns.append(contentsOf: campaignWrapper.campaigns)
                }
                let filteredCampaigns = filtercampaigns(campaigns)
                PresentationManager.sharedInstance.didRecieveCampaigns(filteredCampaigns.nps + filteredCampaigns.announcements)
            case .failure(let error):
                LoggerManager.didRecieveError(error)
            }
        }
    }
    
    /**
        This is responsible for filtering an array of campaigns into NPS and Announcements
        This will also filter out non presentable campaigns
        - parameter campaign: Array of non filtered campaigns
        - returns: Tuple of NPS and Announcement Type Campaigns that are presentable in SDK
    */
    class func filtercampaigns(_ campaigns: [Campaign]) -> (nps: [Campaign], announcements: [Campaign]){
        ///GET NPS or NPS_RESPONSE
        
        ///DO Priority - Announcements before NPS, Latest first
        
        var npsResponse: [Campaign] = []
        var nps: [Campaign] = []
        var announcements: [Campaign] = []
        
        for campaign in campaigns {
            
            if campaign.viewerRecipientStatus != .Read {
                switch campaign.messageType {
                    
                case .some(.NPS):
                    nps.append(campaign)
                case .some(.NPSResponse):
                    npsResponse.append(campaign)
                case .some(.Announcement):
                    //Only show chat response announcements if we have an email
                    if let ctaType = campaign.announcementAttributes?.cta?.ctaType , ctaType == .ChatResponse{
                        if let email = DriftDataStore.sharedInstance.embed?.inboxEmailAddress , email != ""{
                            announcements.append(campaign)
                        }else{
                            LoggerManager.log("Did remove chat announcement as we dont have an email")
                        }
                    }else{
                        announcements.append(campaign)
                    }
                default:
                    ()
                }
            }
        }
        
        let npsResponseIds = npsResponse.flatMap { $0.conversationId }
        
        nps = nps.filter {
            if let conversationId = $0.conversationId {
                return !npsResponseIds.contains(conversationId)
            }
            return false
        }
        
        return (nps, announcements)
    }
    
    class func markCampaignAsRead(_ messageId: Int) {
        DriftAPIManager.markMessageAsRead(messageId: messageId) { (result) in
            switch result {
            case .success:
                LoggerManager.log("Successfully marked Campaign Read: \(messageId)")
            case .failure(let error):
                LoggerManager.didRecieveError(error)
            }
        }
    }
    
}
