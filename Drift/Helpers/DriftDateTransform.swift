//
//  DriftDateTransform.swift
//  Drift
//
//  Created by Eoin O'Connell on 03/02/2016.
//  Copyright © 2016 Drift. All rights reserved.
//

import Foundation
import Gloss

extension Decoder {
    
    static func decodeDriftDate(key: String, json: JSON) -> NSDate? {
        
        if let dateInt = json.valueForKeyPath(key) as? Int {
            return NSDate(timeIntervalSince1970: (Double(dateInt) / 1000))
        }
        
        return nil
    }
    
}