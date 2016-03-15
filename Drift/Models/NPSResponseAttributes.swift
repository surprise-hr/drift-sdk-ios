//
//  NPSResponseAttributes.swift
//  Drift
//
//  Created by Eoin O'Connell on 01/02/2016.
//  Copyright © 2016 Drift. All rights reserved.
//

import Gloss
///NPS Response
class NPSResponseAttributes: Decodable {
    
    var campaignId: Int?
    var dismissed: Bool?
    var numericResponse: Int?
    var textResponse:String?
    
    required init?(json: JSON) {
        campaignId = "campaignId" <~~ json
        dismissed = "dismissed" <~~ json
        textResponse = "textResponse" <~~ json
        numericResponse = "numericResponse" <~~ json
    }

}
