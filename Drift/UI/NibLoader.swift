//
//  NibLoader.swift
//  Drift
//
//  Created by Eoin O'Connell on 26/01/2016.
//  Copyright © 2016 Drift. All rights reserved.
//

import UIKit

extension UIView {
    /**
     Helper Method to load a UIView from a Nib
     
     - parameter nibNameOrNil: - NibName or nil - If nil the Class name of self is used instead
     - returns: Instance of the class or nil
     */
    class func drift_fromNib<T : UIView>(_ nibNameOrNil: String? = nil) -> T? {
        var view: T?
        let name: String
        if let nibName = nibNameOrNil {
            name = nibName
        } else {
            // Most nibs are demangled by practice, if not, just declare string explicitly
            name = "\(self)".components(separatedBy: ".").last!
        }
        
        let nibViews = Bundle.drift_getResourcesBundle()!.loadNibNamed(name, owner: nil, options: nil)
        
        return nibViews?.first as! T
    }
    
}

extension Bundle {
   static func drift_getResourcesBundle() -> Bundle? {
    let bundle = Bundle(for: Drift.self)
      guard let resourcesBundleUrl = bundle.resourceURL?.appendingPathComponent("DriftResources.bundle") else {
         return nil
      }
      return Bundle(url: resourcesBundleUrl)
   }
}
