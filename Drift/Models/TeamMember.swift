//
//  TeamMember.swift
//  Drift
//
//  Created by Brian McDonald on 31/08/2017.
//  Copyright © 2017 Drift. All rights reserved.
//

import ObjectMapper

class TeamMember: Mappable {
    var id: Int = 0
    var avatarURL: String!
    var bot: Bool!
    
    required init?(map: Map) {
        if map.JSON["avatarUrl"] as? String == "" || map.JSON["avatarUrl"] as? String == nil{
            return nil
        }
        
        mapping(map: map)
    }
    
    func mapping(map: Map) {
        id          <- map["id"]
        avatarURL   <- map["avatarUrl"]
        bot         <- map["bot"]
    }
}
