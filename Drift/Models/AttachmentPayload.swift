//
//  AttachmentPayload.swift
//  Drift-SDK
//
//  Created by Eoin O'Connell on 26/02/2020.
//  Copyright © 2020 Drift. All rights reserved.
//

struct AttachmentPayload {
    let fileName: String
    let data: Data
    let mimeType: String
    let conversationId: Int64
}
