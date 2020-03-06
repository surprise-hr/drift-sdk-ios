//
//  PreMessage.swift
//  Drift-SDK
//
//  Created by Eoin O'Connell on 01/02/2018.
//  Copyright © 2018 Drift. All rights reserved.
//

struct PreMessage {
    let messageBody: String
    let user: User?
}

class PreMessageDTO: Codable, DTO {
    typealias DataObject = PreMessage
    
    var messageBody: String?
    var user: UserDTO?
    
    func mapToObject() -> PreMessage? {
        return PreMessage(messageBody: messageBody ?? "",
                          user: user?.mapToObject())
    }
   
    enum CodingKeys: String, CodingKey {
        case messageBody = "body"
        case user        = "sender"
    }
}
