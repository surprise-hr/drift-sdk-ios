//
//  Auth.swift
//  Drift
//
//  Created by Eoin O'Connell on 29/01/2016.
//  Copyright © 2016 Drift. All rights reserved.
//

import UIKit
import Gloss

struct Auth: Glossy {
    
    var accessToken: String
    var enduser: User?

    init?(json: JSON) {
        guard let
            aToken: String = "accessToken" <~~ json
            where aToken != ""
            else {
                LoggerManager.log("Auth Serialisation Failed")
                return nil
        }
        
        self.accessToken = aToken
        self.enduser = "endUser" <~~ json
    }
    
    func toJSON() -> JSON? {
        return jsonify([
            "accessToken" ~~> self.accessToken,
            "endUser" ~~> self.enduser
            ])
    }
    
}
