//
//  Attachment.swift
//  Drift
//
//  Created by Brian McDonald on 29/07/2016.
//  Copyright © 2016 Drift. All rights reserved.
//

import Alamofire

struct Attachment {
    let id: Int64
    let fileName: String
    let size: Int
    let mimeType: String
    let conversationId: Int64
    let publicId: String
    let publicPreviewURL: String?
    
    
    func isImage() -> Bool {
        return (mimeType.lowercased() ==  "image/jpeg") || (mimeType.lowercased() ==  "image/png") || (mimeType.lowercased() ==  "image/gif") || (mimeType.lowercased() ==  "image/jpg")
    }
    
    func getAttachmentURL(accessToken: String?) -> URLRequest? {
        let headers: HTTPHeaders = [
            "Authorization": "bearer \(accessToken ?? "")"
        ]
        return try? URLRequest(url: URL(string: "https://conversation.api.drift.com/attachments/\(id)/data")!, method: .get, headers: headers)
    }
    
}

func ==(lhs: Attachment, rhs: Attachment) -> Bool {
    return lhs.id == rhs.id
}


class AttachmentDTO: Codable, DTO {
    typealias DataObject = Attachment
    
    var id: Int64?
    var fileName: String?
    var size: Int?
    var mimeType: String?
    var conversationId: Int64?
    var publicId: String?
    var publicPreviewURL: String?
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case fileName = "fileName"
        case size = "size"
        case mimeType = "mimeType"
        case conversationId = "conversationId"
        case publicId = "publicId"
        case publicPreviewURL = "publicPreviewUrl"
    }
    
    func mapToObject() -> Attachment? {
        return Attachment(id: id ?? 0,
                          fileName: fileName ?? "",
                          size: size ?? 0,
                          mimeType: mimeType ?? "",
                          conversationId: conversationId ?? 0,
                          publicId: publicId ?? "",
                          publicPreviewURL: publicPreviewURL)
    }
}
