//
//  Auth.swift
//  Drift
//
//  Created by Eoin O'Connell on 29/01/2016.
//  Copyright © 2016 Drift. All rights reserved.
//

///Codable for caching
struct Auth: Codable {
    let accessToken: String
    let endUser: CurrentUser?
}

struct AuthDTO: Codable, DTO {
    typealias DataObject = Auth
        
    var accessToken: String?
    var endUser: CurrentUserDTO?
    
    enum CodingKeys: String, CodingKey {
        case accessToken = "accessToken"
        case endUser = "endUser"
    }
    
    func mapToObject() -> Auth? {
        guard let accessTokenDTO = accessToken, !accessTokenDTO.isEmpty else { return nil }
        return Auth(accessToken: accessTokenDTO, endUser: endUser?.mapToObject())
    }
}
