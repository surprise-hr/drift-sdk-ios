//
//  UserDisplayable.swift
//  Drift-SDK
//
//  Created by Eoin O'Connell on 02/03/2020.
//  Copyright © 2020 Drift. All rights reserved.
//

protocol UserDisplayable {
    var bot: Bool { get }
    var name: String? { get }
    var avatarURL: String? { get }
}
