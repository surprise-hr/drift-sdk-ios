//
//  AppointmentInformation.swift
//  Drift-SDK
//
//  Created by Eoin O'Connell on 07/02/2018.
//  Copyright © 2018 Drift. All rights reserved.
//

struct AppointmentInformation{
    let availabilitySlot: Date
    let slotDuration: Int
    let agentId: Int64
    let conversationId: Int64
    let endUserTimeZone: String?
    let agentTimeZone: String?
}

class AppointmentInformationDTO: Codable, DTO {
    typealias DataObject = AppointmentInformation
    
    var availabilitySlot: Date?
    var slotDuration: Int?
    var agentId: Int64?
    var conversationId: Int64?
    var endUserTimeZone: String?
    var agentTimeZone: String?
        
    enum CodingKeys: String, CodingKey {
        case availabilitySlot   = "availabilitySlot"
        case slotDuration       = "slotDuration"
        case agentId            = "agentId"
        case conversationId     = "conversationId"
        case endUserTimeZone    = "endUserTimeZone"
        case agentTimeZone      = "agentTimeZone"
    }
    
    func mapToObject() -> AppointmentInformation? {
        return AppointmentInformation(availabilitySlot: availabilitySlot ?? Date(),
                                      slotDuration: slotDuration ?? -1,
                                      agentId: agentId ?? -1,
                                      conversationId: conversationId ?? -1,
                                      endUserTimeZone: endUserTimeZone,
                                      agentTimeZone: agentTimeZone)
    }
    
}
