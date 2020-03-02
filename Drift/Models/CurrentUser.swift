//
//  CurrentUser.swift
//  Drift-SDK
//
//  Created by Eoin O'Connell on 02/03/2020.
//  Copyright © 2020 Drift. All rights reserved.
//

import Foundation

///Codable for caching
struct CurrentUser: Codable, UserDisplayable {
    
    let userId: Int64?
    let orgId: Int?
    let email: String?
    let name: String?
    let externalId: String?
    let avatarURL: String?
    let bot: Bool = false

    func getUserName() -> String{
        return name ?? email ?? "No Name Set"
    }
}

class CurrentUserDTO: Codable, DTO {
   
    typealias DataObject = CurrentUser
    
    var userId: Int64?
    var orgId: Int?
    var email: String?
    var name: String?
    var externalId: String?
    var avatarURL: String?

    enum CodingKeys: String, CodingKey {
        case userId = "id"
        case email = "email"
        case orgId = "orgId"
        case name = "name"
        case externalId = "externalId"
        case avatarURL = "avatarUrl"
    }
 
    func mapToObject() -> CurrentUser? {
        return CurrentUser(userId: userId,
                    orgId: orgId,
                    email: email,
                    name: name,
                    externalId: externalId,
                    avatarURL: avatarURL)
    }
}
