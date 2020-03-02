//
//  User.swift
//  Drift
//
//  Created by Eoin O'Connell on 25/01/2016.
//  Copyright © 2016 Drift. All rights reserved.
//

///Codable for caching
struct User: Codable, Equatable, UserDisplayable {
    
    let userId: Int64?
    let email: String?
    let name: String?
    let avatarURL: String?
    let bot: Bool

    func getUserName() -> String{
        return name ?? email ?? "No Name Set"
    }
}

class UserDTO: Codable, DTO {
   
    typealias DataObject = User
    
    var userId: Int64?
    var email: String?
    var name: String?
    var avatarURL: String?
    var bot: Bool?

    enum CodingKeys: String, CodingKey {
        case userId = "id"
        case email = "email"
        case name = "name"
        case avatarURL = "avatarUrl"
        case bot = "bot"
    }
 
    func mapToObject() -> User? {
        return User(userId: userId,
                    email: email,
                    name: name,
                    avatarURL: avatarURL,
                    bot: bot ?? false)
    }
}


func ==(lhs: User, rhs: User) -> Bool {
    return lhs.userId == rhs.userId
}
