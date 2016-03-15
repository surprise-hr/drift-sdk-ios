//
//  CampaignOrganizer.swift
//  Drift
//
//  Created by Eoin O'Connell on 04/02/2016.
//  Copyright © 2016 Drift. All rights reserved.
//


import Gloss
///Data Structure for the Drift user who made the campaign
class CampaignOrganizer: Decodable {
    
    var userId: Int?
    var name: String?
    var avatarURL: NSURL?
    
    required init?(json: JSON) {
        self.userId = "id" <~~ json
        self.name = "name" <~~ json
        self.avatarURL = "avatarUrl" <~~ json
    }
}
