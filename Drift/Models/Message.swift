//
//  Message.swift
//  Drift
//
//  Created by Brian McDonald on 25/07/2016.
//  Copyright © 2016 Drift. All rights reserved.
//


enum ContentType: String, Codable{
    case Chat = "CHAT"
    case Annoucement = "ANNOUNCEMENT"
    case Edit = "EDIT"
}
enum AuthorType: String, Codable{
    case User = "USER"
    case EndUser = "END_USER"
}

enum SendStatus: String, Codable{
    case Sent = "SENT"
    case Pending = "PENDING"
    case Failed = "FAILED"
}

class Message: Equatable {
    let id: Int64
    var uuid: String?
    let inboxId: Int
    var body: String?
    var attachmentIds: [Int64] = []
    var attachments: [Attachment] = []
    let contentType: ContentType
    var createdAt = Date()
    var authorId: Int64
    var authorType: AuthorType
    
    let conversationId: Int64
    var sendStatus: SendStatus = SendStatus.Sent
    var formattedBody: NSAttributedString?
    var appointmentInformation: AppointmentInformation?

    var presentSchedule: Int64?
    var scheduleMeetingFlow: Bool = false
    var offerSchedule: Int64 = -1
    
    var preMessages: [PreMessage] = []
    var requestId: Double = 0
    var fakeMessage = false
    var preMessage = false

    init(id: Int64,
    uuid: String?,
    inboxId: Int,
    body: String?,
    attachmentIds: [Int64],
    attachments: [Attachment],
    contentType:ContentType,
    createdAt: Date,
    authorId: Int64,
    authorType: AuthorType,
    conversationId: Int64,
    appointmentInformation: AppointmentInformation?,
    presentSchedule: Int64?,
    scheduleMeetingFlow: Bool = false,
    offerSchedule: Int64 = -1,
    preMessages: [PreMessage]) {
        
    }
    
    func formatHTMLBody() {
        if formattedBody == nil {
            formattedBody = TextHelper.attributedTextForString(text: body ?? "")
        }
    }
}

class MessageDTO: Codable, DTO {
    typealias DataObject = Message
    
    var id: Int64?
    var uuid: String?
    var inboxId: Int?
    var body: String?
    var attachmentIds: [Int64]?
    var attachments: [AttachmentDTO]?
    var contentType:ContentType?
    var createdAt: Date?
    var authorId: Int64?
    var authorType: AuthorType?
    
    var conversationId: Int64?
    
    var attributes: MessageAttributesDTO?
        
    func mapToObject() -> Message? {
        
        guard let contentType = contentType else { return nil }
        
        return Message(
    }
    
    enum CodingKeys: String, CodingKey {
        case id             = "id"
        case uuid           = "uuid"
        case inboxId        = "inboxId"
        case body           = "body"
        case attachmentIds  = "attachments"
        case contentType    = "contentType"
        case createdAt      = "createdAt"
        case authorId       = "authorId"
        case authorType     = "authorType"
        case conversationId = "conversationId"
        case attributes     = "attributes"
    }
}

class MessageAttributesDTO: Codable{
    var appointmentInformation: AppointmentInformationDTO?
    var presentSchedule: Int64?
    var scheduleMeetingFlow: Bool?
    var offerSchedule: Int64?
    var preMessages: [PreMessageDTO]?
    
    enum CodingKeys: String, CodingKey {
        case appointmentInformation     = "appointmentInfo"
        case presentSchedule            = "presentSchedule"
        case scheduleMeetingFlow        = "scheduleMeetingFlow"
        case offerSchedule              = "offerSchedule"
        case preMessages                = "preMessages"
    }
}

extension Array where Iterator.Element == Message
{
    
    func sortMessagesForConversation() -> Array<Message> {
        
        var output:[Message] = []
        
        let sorted = self.sorted(by: { $0.createdAt.compare($1.createdAt) == .orderedAscending})
        
        for message in sorted {
            
            if message.preMessage {
                //Ignore pre messages, we will recreate them
                continue
            }
            
            if !message.preMessages.isEmpty {
                output.append(contentsOf: getMessagesFromPreMessages(message: message, preMessages: message.preMessages))
            }
            
            if message.offerSchedule != -1 {
                continue
            }
            
            if let _ = message.appointmentInformation {
                //Go backwards and remove the most recent message asking for an apointment
                
                output = output.map({
                    
                    if let _ = $0.presentSchedule {
                        $0.presentSchedule = nil
                    }
                    return $0
                })
                
            }
            
            output.append(message)
        }
        
        return output.sorted(by: { $0.createdAt.compare($1.createdAt) == .orderedDescending})
    }
    
    private func getMessagesFromPreMessages(message: Message, preMessages: [PreMessage]) -> [Message] {
        
        let date = message.createdAt
        var output: [Message] = []
        for (index, preMessage) in preMessages.enumerated() {
            let fakeMessage = Message()
            
            fakeMessage.createdAt = date.addingTimeInterval(TimeInterval(-(index + 1)))
            fakeMessage.conversationId = message.conversationId
            fakeMessage.body = preMessage.messageBody
            fakeMessage.fakeMessage = true
            fakeMessage.preMessage = true
            fakeMessage.uuid = UUID().uuidString
            
            fakeMessage.sendStatus = .Sent
            fakeMessage.contentType = ContentType.Chat
            fakeMessage.authorType = AuthorType.User
            
            if let sender = preMessage.user {
                fakeMessage.authorId = sender.userId
                output.append(fakeMessage)
            }
        }
        
        return output
    }
    
}


func ==(lhs: Message, rhs: Message) -> Bool {
    return lhs.uuid == rhs.uuid
}

