//
//  Embed.swift
//  Drift
//
//  Created by Eoin O'Connell on 22/01/2016.
//  Copyright © 2016 Drift. All rights reserved.
//

import ObjectMapper

enum WidgetStatus: String, Codable{
    case on = "ON"
    case away = "AWAY"
}

enum WidgetMode: String, Codable{
    case manual = "MANUAL"
    case auto   = "AUTO"
}

enum UserListMode: String, Codable{
    case random = "RANDOM"
    case custom   = "CUSTOM"
}

///Embed - The organisation specific data used to customise the SDK for each organization
struct Embed: Codable {
    
    var orgId: Int!
    var embedId: String!
    var configuration: EmbedConfiguration?


    enum CodingKeys: String, CodingKey {
        case orgId          = "orgId"
        case embedId        = "id"
        case configuration  = "configuration"
    }
        
    func isOrgCurrentlyOpen() -> Bool {
        if configuration?.widgetMode == .some(.manual) {
            if configuration?.widgetStatus == .some(.on) {
                return true
            }else{
                return false
            }
        }else{
            //Use open hours
            
            if let timezone = TimeZone(identifier: configuration?.theme?.timeZoneString ?? "") {
                return configuration?.theme?.openHours.areWeCurrentlyOpen(date: Date(), timeZone: timezone) ?? false
            }else{
                return false
            }
        }
    }
    
    func getWelcomeMessageForUser() -> String {
        
        if isOrgCurrentlyOpen() {
            return configuration?.theme?.welcomeMessage ?? "How can we help out? We are here for you!"
        }else {
            return configuration?.theme?.awayMessage ?? "We’re not currently online right now but if you leave a message, we’ll get back to you as soon as possible!"
        }
    }
    
    func getUserForWelcomeMessage() -> User? {
        
        let users = configuration?.users ?? []
        let userListIds = configuration?.theme?.userListIds ?? []
        
        if configuration?.theme?.userListMode == .custom, let teamMember = users.filter({ userListIds.contains($0.userId ?? -1) }).first{
            return teamMember
        }else{
            if users.count > 0 {
                return users[Int(arc4random_uniform(UInt32(users.count)))]
            } else {
                return nil
            }
        }
        
    }
}

struct EmbedConfiguration: Codable {
    
    var inboxId: Int!
    var clientId: String!
    var redirectUri: String!
    var organizationName: String?
    var inboxEmailAddress: String?
    var refreshRate: Int?
    var widgetStatus: WidgetStatus = .on
    var widgetMode: WidgetMode = .manual
    var users: [User] = []
    var theme: EmbedTheme?
            
    enum CodingKeys: String, CodingKey {
        case inboxId            = "inboxId"
        case clientId           = "authClientId"
        case redirectUri        = "redirectUri"
        case organizationName   = "organizationName"
        case inboxEmailAddress  = "inboxEmailAddress"
        case refreshRate        = "refreshRate"
        case widgetStatus       = "widgetStatus"
        case widgetMode         = "widgetMode"
        case users              = "team"
        case theme              = "theme"
    }
}

struct EmbedTheme: Codable {
    
    var backgroundColor: String?
    var foregroundColor: String?
    var welcomeMessage: String?
    var awayMessage: String?
    var timeZoneString: String?
    var openHours: [OpenHours] = []
    var userListMode: UserListMode = .random
    var userListIds: [Int64] = []
    
    enum CodingKeys: String, CodingKey {
            case backgroundColor        = "backgroundColor"
            case foregroundColor        = "foregroundColor"
            case welcomeMessage         = "welcomeMessage"
            case awayMessage            = "awayMessage"
            case timeZoneString         = "timezone"
            case openHours              = "openHours"
            case userListMode           = "userListMode"
            case userListIds            = "userList"
    }
}
