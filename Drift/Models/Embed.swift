//
//  Embed.swift
//  Drift
//
//  Created by Eoin O'Connell on 22/01/2016.
//  Copyright © 2016 Drift. All rights reserved.
//

import Gloss
///Embed - The organisation specific data used to customise the SDK for each organization
struct Embed: Glossy {
    
    var orgId: Int
    var embedId: String
    var inboxId: Int
    
    var layerAppId: String
    var clientId: String
    var redirectUri: String
    
    var backgroundColor: String?
    var foregroundColor: String?
    
    var organizationName: String?
    
    var inboxEmailAddress: String?
    var refreshRate: String?
    
    init?(json: JSON) {
    
        ///This data is required - Fail Init and don't go further if we don't have these
        guard let
            orgId: Int = "orgId" <~~ json,
            embedId: String = "id" <~~ json,
            inboxId: Int = "configuration.inboxId" <~~ json,
            layerAppId: String = "configuration.layerAppId" <~~ json,
            clientId: String = "configuration.authClientId" <~~ json,
            redirectUri: String = "configuration.redirectUri" <~~ json
            where
            embedId != "" &&
            layerAppId != "" &&
            clientId != "" &&
            redirectUri != ""
            else { return nil }
        
        self.orgId = orgId
        self.embedId = embedId
        self.inboxId = inboxId
        self.layerAppId = layerAppId
        self.clientId = clientId
        self.redirectUri = redirectUri
        

        backgroundColor = "configuration.theme.backgroundColor" <~~ json
        foregroundColor = "configuration.theme.foregroundColor" <~~ json
        organizationName = "configuration.organizationName" <~~ json
        inboxEmailAddress = "configuration.inboxEmailAddress" <~~ json
        refreshRate = "configuration.refreshRate" <~~ json
    }
    

    
    ///Used when caching Embed
    func toJSON() -> JSON? {
        return jsonify([
            "orgId" ~~> self.orgId,
            "id" ~~> self.embedId,
            "configuration.inboxId" ~~> self.inboxId,
            "configuration.layerAppId" ~~> self.layerAppId,
            "configuration.authClientId" ~~> self.clientId,
            "configuration.theme.backgroundColor" ~~> self.backgroundColor,
            "configuration.theme.foregroundColor" ~~> self.foregroundColor,
            "configuration.redirectUri" ~~> self.redirectUri,
            "configuration.organizationName" ~~> self.organizationName,
            "configuration.inboxEmailAddress" ~~> self.inboxEmailAddress,
            "configuration.refreshRate" ~~> self.refreshRate
            ])
    }
    
}
