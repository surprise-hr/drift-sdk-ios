//
//  Auth.swift
//  Drift
//
//  Created by Eoin O'Connell on 29/01/2016.
//  Copyright © 2016 Drift. All rights reserved.
//

struct Auth: Codable {
    
    var accessToken: String
    var endUser: User?
    
    enum CodingKeys: String, CodingKey {
        case accessToken = "accessToken"
        case endUser = "endUser"
    }
}
