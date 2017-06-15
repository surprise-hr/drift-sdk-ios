//
//  Configuration.swift
//  Drift
//
//  Created by Brian McDonald on 09/11/2016.
//  Copyright © 2016 Drift. All rights reserved.
//

import ObjectMapper

public enum WidgetStatus: String{
    case on = "ON"
    case away = "AWAY"
}


public enum WidgetMode: String{
    case manual = "MANUAL"
    case auto   = "AUTO"
}

open class Configuration: Mappable{
    var id = ""
    var widgetStatus: WidgetStatus?{
        get{
            return WidgetStatus(rawValue: widgetStatusRaw)
        }
    }
    var widgetStatusRaw = WidgetStatus.on.rawValue
    
    var widgetMode: WidgetMode?{
        get{
            return WidgetMode(rawValue: widgetModeRaw)
        }
    }
    var widgetModeRaw = WidgetMode.manual.rawValue
    
    var openHours: [OpenHours] = []
    var timeZoneString: String?
    var backgroundColorString: String?

    required public convenience init?(map: Map) {
        self.init()
    }
    
    open func mapping(map: Map) {
        id                      <- map["id"]
        widgetStatusRaw         <- map["configuration.widgetStatus"]
        widgetModeRaw           <- map["configuration.widgetMode"]
        timeZoneString          <- map["configuration.theme.timezone"]
        backgroundColorString   <- map["configuration.theme.backgroundColor"]
        openHours               <- map["configuration.theme.openHours"]
    }
    
    open func isOrgCurrentlyOpen() -> Bool {
    
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
}
