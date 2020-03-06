//
//  DTO.swift
//  Drift-SDK
//
//  Created by Eoin O'Connell on 26/02/2020.
//  Copyright © 2020 Drift. All rights reserved.
//

protocol DTO {
    associatedtype DataObject

    func mapToObject() -> DataObject?
}
