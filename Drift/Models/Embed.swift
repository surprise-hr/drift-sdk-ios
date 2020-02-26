//
//  Embed.swift
//  Drift
//
//  Created by Eoin O'Connell on 22/01/2016.
//  Copyright © 2016 Drift. All rights reserved.
//

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
///Codable for caching
struct Embed: Codable {
    
    let orgId: Int
    let embedId: String

    let inboxId: Int
    let clientId: String
    let redirectUri: String
    let organizationName: String?
    let inboxEmailAddress: String?
    let refreshRate: Int?
    let widgetStatus: WidgetStatus
    let widgetMode: WidgetMode
    let users: [User]
    
    let backgroundColor: String?
    let foregroundColor: String?
    let welcomeMessage: String?
    let awayMessage: String?
    let timeZoneString: String?
    let openHours: [OpenHours]
    let userListMode: UserListMode
    let userListIds: [Int64]
        
    func isOrgCurrentlyOpen() -> Bool {
        if widgetMode == .some(.manual) {
            if widgetStatus == .some(.on) {
                return true
            }else{
                return false
            }
        }else{
            //Use open hours
            
            if let timezone = TimeZone(identifier: timeZoneString ?? "") {
                return openHours.areWeCurrentlyOpen(date: Date(), timeZone: timezone)
            }else{
                return false
            }
        }
    }
    
    func getWelcomeMessageForUser() -> String {
        
        if isOrgCurrentlyOpen() {
            return welcomeMessage ?? "How can we help out? We are here for you!"
        }else {
            return awayMessage ?? "We’re not currently online right now but if you leave a message, we’ll get back to you as soon as possible!"
        }
    }
    
    func getUserForWelcomeMessage() -> User? {
        
        
        if userListMode == .custom, let teamMember = users.filter({ userListIds.contains($0.userId ?? -1) }).first{
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

///Embed - The organisation specific data used to customise the SDK for each organization
struct EmbedDTO: Codable, DTO {
    
    typealias DataObject = Embed
    
    var orgId: Int?
    var embedId: String?
    var configuration: EmbedConfiguration?


    enum CodingKeys: String, CodingKey {
        case orgId          = "orgId"
        case embedId        = "id"
        case configuration  = "configuration"
    }
 
    func mapToObject() -> Embed? {
        guard let orgId = orgId,
            let id = embedId,
            let inboxId = configuration?.inboxId,
            let authClientId = configuration?.clientId,
            let redirectURI = configuration?.redirectUri else {
                return nil
        }
        
        
        return Embed(orgId: orgId,
                     embedId: id,
                     inboxId: inboxId,
                     clientId: authClientId,
                     redirectUri: redirectURI,
                     organizationName: configuration?.organizationName,
                     inboxEmailAddress: configuration?.inboxEmailAddress,
                     refreshRate: configuration?.refreshRate,
                     widgetStatus: configuration?.widgetStatus ?? .on,
                     widgetMode: configuration?.widgetMode ?? .manual,
                     users: configuration?.users?.compactMap({ $0.mapToObject() }) ?? [],
                     backgroundColor: configuration?.theme?.backgroundColor,
                     foregroundColor: configuration?.theme?.foregroundColor,
                     welcomeMessage: configuration?.theme?.welcomeMessage,
                     awayMessage: configuration?.theme?.awayMessage,
                     timeZoneString: configuration?.theme?.timeZoneString,
                     openHours: configuration?.theme?.openHours ?? [],
                     userListMode: configuration?.theme?.userListMode ?? .random,
                     userListIds: configuration?.theme?.userListIds ?? [])
        
    }
    
}

struct EmbedConfiguration: Codable {
    
    var inboxId: Int?
    var clientId: String?
    var redirectUri: String?
    var organizationName: String?
    var inboxEmailAddress: String?
    var refreshRate: Int?
    var widgetStatus: WidgetStatus?
    var widgetMode: WidgetMode?
    var users: [UserDTO]?
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
    var openHours: [OpenHours]?
    var userListMode: UserListMode?
    var userListIds: [Int64]?
    
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
