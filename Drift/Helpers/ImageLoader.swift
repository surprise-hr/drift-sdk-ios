//
//  ImageLoader.swift
//  Drift
//
//  Created by Eoin O'Connell on 04/02/2016.
//  Copyright © 2016 Drift. All rights reserved.
//

import UIKit

extension UIImageView {
    
    /**
     Downloaded url and renders data as a UIImage and sets image value of self
     
     - parameter url: NSURL of image
     
     - parameter mode: UIViewContentMode to apply to image
     
     */
    func downloadedFrom(url:NSURL, contentMode mode: UIViewContentMode) {
        
        if let url = NSURL(string: url.absoluteString.stringByRemovingPercentEncoding ?? "") {
        
            contentMode = mode
            NSURLSession.sharedSession().dataTaskWithURL(url, completionHandler: { (data, response, error) -> Void in
                guard
                    let httpURLResponse = response as? NSHTTPURLResponse where httpURLResponse.statusCode == 200,
                    let mimeType = response?.MIMEType where mimeType.hasPrefix("image"),
                    let data = data where error == nil,
                    let image = UIImage(data: data)
                    else { return }
                dispatch_async(dispatch_get_main_queue()) { () -> Void in
                    self.image = image
                }
            }).resume()
        }
    }
}