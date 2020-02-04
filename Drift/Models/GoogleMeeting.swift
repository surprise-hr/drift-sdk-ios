//
//  GoogleMeeting.swift
//  Drift-SDK
//
//  Created by Eoin O'Connell on 07/02/2018.
//  Copyright © 2018 Drift. All rights reserved.
//

import UIKit
import ObjectMapper

class GoogleMeeting: Mappable {

    
    var startTime:Date?
    var endTime:Date?
    var meetingId: String?
    var meetingURL: String?
    
    
    
    required convenience init?(map: Map) {
        self.init()
    }
    
    open func mapping(map: Map) {
                
        startTime           <- (map["start"], DriftDateTransformer())
        endTime             <- (map["end"], DriftDateTransformer())
        meetingId           <- map["id"]
        meetingURL          <- map["url"]
    }
    
}
