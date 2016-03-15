//
//  NPSAttributes.swift
//  Driftt
//
//  Created by Eoin O'Connell on 22/01/2016.
//  Copyright © 2016 Drift. All rights reserved.
//

import Gloss
///Attributes used for NPS
class NPSAttributes: Decodable {
    
    var cta: CTA?
    var followUpQuestion: String?
    var campaignId: Int?
    
    required init?(json: JSON) {
        cta = "cta" <~~ json
        followUpQuestion = "followUpMessage" <~~ json
        campaignId = "campaignId" <~~ json
    }
}
