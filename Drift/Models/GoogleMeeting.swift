//
//  GoogleMeeting.swift
//  Drift-SDK
//
//  Created by Eoin O'Connell on 07/02/2018.
//  Copyright © 2018 Drift. All rights reserved.
//

struct GoogleMeeting {
    let startTime:Date?
    let endTime:Date?
    let meetingId: String?
    let meetingURL: String?
}

class GoogleMeetingDTO: Codable, DTO {
   
    typealias DataObject = GoogleMeeting
    
    var startTime:Date?
    var endTime:Date?
    var meetingId: String?
    var meetingURL: String?
    
    
    enum CodingKeys: String, CodingKey {
        case startTime     = "start"
        case endTime       = "end"
        case meetingId     = "id"
        case meetingURL    = "url"
    }

    func mapToObject() -> GoogleMeeting? {
        return GoogleMeeting(startTime: startTime,
                             endTime: endTime,
                             meetingId: meetingId,
                             meetingURL: meetingURL)
    }
}
