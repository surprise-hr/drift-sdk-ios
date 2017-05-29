//
//  AppDelegate.swift
//  SDKExample
//
//  Created by Eoin O'Connell on 29/05/2017.
//  Copyright © 2017 drift. All rights reserved.
//

import UIKit
import Drift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        Drift.setup("teergsg9bb5d")
        
        Drift.debugMode(true)
        Drift.registerUser("1237438", email: "eoin+app@8bytes.is")
        
        return true
    }


}

