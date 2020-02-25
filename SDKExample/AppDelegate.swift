//
//  AppDelegate.swift
//  SDKExample
//
//  Created by Eoin O'Connell on 24/02/2020.
//  Copyright © 2020 Drift. All rights reserved.
//

import UIKit
import Drift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        Drift.setup("teergsg9bb5d")
        
        Drift.debugMode(true)
        Drift.registerUser("123743810", email: "eoin+app@8bytes.ie")
        
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
}

