//
//  User.swift
//  Drift
//
//  Created by Eoin O'Connell on 25/01/2016.
//  Copyright © 2016 Drift. All rights reserved.
//

///User obect - Attached to Auth and used to make sure user has not changed during app close
///Codable for caching
struct User: Codable, Equatable {
    
    let userId: Int64?
    let orgId: Int?
    let email: String?
    let name: String?
    let externalId: String?
    let avatarURL: String?
    let bot: Bool

    func getUserName() -> String{
        return name ?? email ?? "No Name Set"
    }
}

class UserDTO: Codable, DTO {
   
    typealias DataObject = User
    
    var userId: Int64?
    var orgId: Int?
    var email: String?
    var name: String?
    var externalId: String?
    var avatarURL: String?
    var bot: Bool?

    enum CodingKeys: String, CodingKey {
        case userId = "id"
        case email = "email"
        case orgId = "orgId"
        case name = "name"
        case externalId = "externalId"
        case avatarURL = "avatarUrl"
        case bot = "bot"
    }
 
    func mapToObject() -> User? {
        return User(userId: userId,
                    orgId: orgId,
                    email: email,
                    name: name,
                    externalId: externalId,
                    avatarURL: avatarURL,
                    bot: bot ?? false)
    }
}


func ==(lhs: User, rhs: User) -> Bool {
    return lhs.userId == rhs.userId
}
