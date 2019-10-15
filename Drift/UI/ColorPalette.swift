//
//  ColourPallette.swift
//  Drift
//
//  Created by Eoin O'Connell on 26/01/2016.
//  Copyright © 2016 Drift. All rights reserved.
//


import UIKit

struct ColorPalette {
    static let titleTextColor: UIColor = {
        
        if #available(iOS 13.0, *) {
            return UIColor.label
        } else {
            return UIColor(red:0.20, green:0.20, blue:0.20, alpha:1.00)
        }
    }()
    
    static let subtitleTextColor: UIColor = {
        if #available(iOS 13.0, *) {
            return UIColor.secondaryLabel
        } else {
            return UIColor(red:0.6, green:0.6, blue:0.6, alpha:1.00)
        }
    }()
    
    static let backgroundColor: UIColor = {
        if #available(iOS 13.0, *) {
            return UIColor.systemBackground
        } else {
            return UIColor.white
        }
    }()
    
    static let placeholderColor: UIColor = {
        if #available(iOS 13.0, *) {
            return UIColor.placeholderText
        } else {
            return UIColor(red:0.6, green:0.6, blue:0.6, alpha:1.00)
        }
    }()
    
    static let navyDark: UIColor = {
        if #available(iOS 13.0, *) {
            return UIColor.label
        } else {
            return UIColor(red:0.46, green:0.58, blue:0.65, alpha:1.00)
        }
       
    }()
    
    static let navyLight: UIColor = {
        if #available(iOS 13.0, *) {
            return UIColor.label
        } else {
            return UIColor(red:0.88, green:0.93, blue:0.96, alpha:1.00)
        }
        
    }()
    
    static let navyMedium: UIColor = {
        if #available(iOS 13.0, *) {
            return UIColor.label
        } else {
            return UIColor(red:0.71, green:0.82, blue:0.88, alpha:1.00)
        }
    }()
    
    static let navyExtraDark: UIColor = {
        if #available(iOS 13.0, *) {
            return UIColor.label
        } else {
            return UIColor(red:0.22, green:0.31, blue:0.35, alpha:1.00)
        }
        
    }()
    
    static let driftBlue = UIColor(red:0.00, green:0.46, blue:1.00, alpha:1.00)
    static let driftGreen = UIColor(red:0.07, green:0.80, blue:0.43, alpha:1.00)
}
