//
//  ObjectValidator.swift
//  Drift
//
//  Created by Brian McDonald on 25/07/2016.
//  Copyright © 2016 Drift. All rights reserved.
//

import UIKit
import ObjectMapper

private var failures = 0

extension Map{

    func validNotEmpty<T>() -> T? {
        if let value: T = value() {
            if value as? String == ""{
                failures += 1
                return nil
            }
            return value
        }else {
            // Collects failed count
            failures += 1
            return nil
        }
    }
    
    var isValidNotEmpty: Bool{
        return failures == 0
    }
    
}
