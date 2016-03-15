//
//  User.swift
//  Drift
//
//  Created by Eoin O'Connell on 25/01/2016.
//  Copyright © 2016 Drift. All rights reserved.
//

import Gloss
///User obect - Attached to Auth and used to make sure user has not changed during app close
class User: Glossy {
    
    var userId: Int?
    var orgId: Int?
    var email: String?
    var name: String?
    var externalId: String?
    var attributes: [String: AnyObject]?

    required init?(json: JSON) {
        userId = "id" <~~ json
        email = "email" <~~ json
        orgId = "orgId" <~~ json
        name = "name" <~~ json
        attributes = "attributes" <~~ json
        externalId = "externalId" <~~ json
    }
    
    func toJSON() -> JSON? {
        return jsonify(
            [
                "id" ~~> self.userId,
                "email" ~~> self.email,
                "orgId" ~~> self.orgId,
                "name" ~~> self.name,
                "externalId" ~~> self.externalId,
                "attributes" ~~> self.attributes
            ]
        )
    }
}
