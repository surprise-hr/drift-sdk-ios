//
//  AnnouncmentAttributes.swift
//  Driftt
//
//  Created by Eoin O'Connell on 22/01/2016.
//  Copyright © 2016 Drift. All rights reserved.
//

import Gloss

class AnnouncmentAttributes: Decodable {
    
    var cta: CTA?
    var title: String?
    var campaignId: Int?
    
    required init?(json: JSON) {
        self.cta = "cta" <~~ json
        self.title = "title" <~~ json
        self.campaignId = "campaignId" <~~ json
    }
}
