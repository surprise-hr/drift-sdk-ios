//
//  MessageRequest.swift
//  Drift-SDK
//
//  Created by Eoin O'Connell on 06/02/2018.
//  Copyright © 2018 Drift. All rights reserved.
//

class MessageRequest {

    var body: String = ""
    var type:ContentType = .Chat
    var attachments: [Int64] = []
    var requestId: Double = Date().timeIntervalSince1970

    var googleMeeting: GoogleMeeting?
    var userAvailability: UserAvailability?
    var conversationId: Int64?
    var meetingUserId: Int64?
    var meetingTimeSlot:Date?
    
    init (body: String, contentType: ContentType = .Chat, attachmentIds: [Int64] = []) {
        self.body = TextHelper.wrapTextInHTML(text: body)
        self.type = contentType
        self.attachments = attachmentIds
    }
    
    init(googleMeeting: GoogleMeeting, userAvailability: UserAvailability, meetingUserId: Int64, conversationId: Int64, timeSlot: Date) {
        self.body = ""
        self.type = .Chat
        self.googleMeeting = googleMeeting
        self.userAvailability = userAvailability
        self.conversationId = conversationId
        self.meetingUserId = meetingUserId
        self.meetingTimeSlot = timeSlot
    }
    
    func getContextUserAgent() -> String {

        var userAgent = "Mobile App / \(UIDevice.current.drift_modelName) / \(UIDevice.current.systemName) \(UIDevice.current.systemVersion)"
        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] {
            userAgent.append(" / App Version: \(version)")
        }
        return userAgent
    }
    
  
    func toJSON() -> [String: Any]{
        
        var json:[String : Any] = [
            "body": body,
            "type": type.rawValue,
            "attachments": attachments,
            "context": ["userAgent": getContextUserAgent()]
        ]
        
        if let googleMeetingId = googleMeeting?.meetingId,
            let googleMeetingURL = googleMeeting?.meetingURL,
            let meetingDuration = userAvailability?.duration,
            let meetingUserId = meetingUserId,
            let meetingTimeSlot = meetingTimeSlot,
            let conversationId = conversationId,
            let agentTimeZone = userAvailability?.timezone{
            
            let apointment: [String: Any] = [
                "id":googleMeetingId,
                "url": googleMeetingURL,
                "availabilitySlot": meetingTimeSlot.timeIntervalSince1970*1000,
                "slotDuration": meetingDuration,
                "agentId": meetingUserId,
                "conversationId": conversationId,
                "endUserTimeZone": TimeZone.current.identifier,
                "agentTimeZone": agentTimeZone
            ]
            
            let attributes: [String: Any] = [
                "scheduleMeetingFlow": true,
                "scheduleMeetingWith":meetingUserId,
                "appointmentInfo":apointment]
            json["attributes"] = attributes
        }
        
        return json
    }
    
    func generateFakeMessage(conversationId:Int64, userId: Int64) -> Message {
        
        
        let message = Message(uuid: UUID().uuidString,
                body: body,
                contentType: type,
                createdAt: Date(),
                authorId: userId,
                authorType: .EndUser,
                conversationId: conversationId,
                requestId: requestId,
                fakeMessage: true)

        message.formattedBody = TextHelper.attributedTextForString(text: body)
        message.sendStatus = .Pending
        return message
    }
    
}
