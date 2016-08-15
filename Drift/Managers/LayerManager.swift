//
//  LayerManager.swift
//  Driftt
//
//  Created by Eoin O'Connell on 22/01/2016.
//  Copyright © 2016 Drift. All rights reserved.
//

import Foundation
import LayerKit

///Deals with everything to do with auth and layer
class LayerManager: NSObject, LYRClientDelegate {
    
    static var sharedInstance: LayerManager = LayerManager()
    var layerClient: LYRClient?
    var userId: Int!
    
    ///Completion block passed along auth functions
    var completion: ((success: Bool) -> ())?
    //Refresh timer - ensures all syncing is complete before calling presentation Manager - Allows campaigns to stack
    private var synchronizationTimer: NSTimer?
    
    private override init() {
        super.init()
    }
    
    deinit{
        synchronizationTimer?.invalidate()
    }
    
    class func initialize(appId: String, userId: Int, completion: (success: Bool) -> ()) {
        
        if sharedInstance.layerClient != nil {
            
            sharedInstance.userId = userId
            sharedInstance.completion = completion
            sharedInstance.startLayerConection()
            return
        }
        
        let url = NSURL(string: "layer:///apps/staging/\(appId)")!

        sharedInstance.layerClient = LYRClient(appID: url, delegate: sharedInstance, options: nil)
        sharedInstance.userId = userId
        sharedInstance.completion = completion
        if let connected = sharedInstance.layerClient?.isConnected where connected {
            LoggerManager.log("Layer Logged in - Deauthing")
            sharedInstance.layerClient?.deauthenticateWithCompletion({ (success, error) -> Void in
                if success {
                    LoggerManager.log("Layer Deauth success")
                    sharedInstance.startLayerConection()
                }else{
                    LoggerManager.log("\(error?.localizedDescription)")
                    LoggerManager.log("Layer Deauth Failed")
                    sharedInstance.startLayerConection()
                }
            })
        }else{
            sharedInstance.startLayerConection()
        }   
    }
    
    class func logout(){
        sharedInstance.layerClient?.deauthenticateWithCompletion({ (success, error) -> Void in})
    }
    
    func startLayerConection(){
        LoggerManager.log("Layer Starting connection")
        layerClient?.connectWithCompletion({ (success, error) -> Void in
            if success {
                LoggerManager.log("Connected to Layer")
                self.getNonceFromLayer()
            }else{
                LoggerManager.log("Failed to connect to layer")
            }
        })
    }
    
    func getNonceFromLayer(){
        layerClient?.requestAuthenticationNonceWithCompletion({ (nonce, error) -> Void in
            if let nonce = nonce {
                self.getToken(nonce)
            }else{
                if error?.code == .Some(7005) {
                    self.completion?(success: true)
                }else{
                    LoggerManager.log("Failed to get nonce: \(error)")
                    self.completion?(success: false)
                }
                self.completion = nil
            }
        })
    }
    
    func getToken(nonce: String) {
        
        APIManager.getLayerAccessToken(nonce, userId: "u:\(userId)") { (result) -> () in
            switch result {
            case .Success(let token):
                self.authWithLayer(token)
            case .Failure(let error):
                LoggerManager.log("Failed to get nonce: \(error)")
                self.completion?(success: false)
                self.completion = nil
            }
        }
    }
    
    func authWithLayer(token: String) {
        layerClient?.authenticateWithIdentityToken(token, completion: { (authUserId, error) -> Void in
            
            if let authUserId = authUserId {
                LoggerManager.log("Authed with Layer: \(authUserId)")
                self.completion?(success: true)
                self.completion = nil
            }else{
                if let error = error {
                    LoggerManager.didRecieveError(error)
                }
                LoggerManager.log("Failed to auth with Layer")
            }
        })
    }
    
    ///Layer Client
    
    
    func layerClient(client: LYRClient, didReceiveAuthenticationChallengeWithNonce nonce: String) {
        LoggerManager.log("Auth Challenge with Nonce")
        getToken(nonce)
    }
    
    func layerClientDidConnect(client: LYRClient) {
        LoggerManager.log("Did connect")
    }
    
    ///Make sure we have all changes before we pass off to campaigns manager
    func layerClient(client: LYRClient, objectsDidChange changes: [LYRObjectChange]) {
        synchronizationTimer?.invalidate()
        synchronizationTimer = NSTimer.scheduledTimerWithTimeInterval(2.0, target: self, selector: #selector(LayerManager.didFinishSync), userInfo: nil, repeats: false)
    }
    
    func layerClient(client: LYRClient, didFinishSynchronizationWithChanges changes: [LYRObjectChange]) {        
        synchronizationTimer?.invalidate()
        synchronizationTimer = NSTimer.scheduledTimerWithTimeInterval(2.0, target: self, selector: #selector(LayerManager.didFinishSync), userInfo: nil, repeats: false)
    }
    
    
    func didFinishSync() {
        do {
            try CampaignsManager.checkForCampaigns()
        }catch {
            LoggerManager.log("Failed to check for campaigns")
        }
        
    }
    
    func layerClient(client: LYRClient, didFailSynchronizationWithError error: NSError) {
        LoggerManager.log("Sync Failed: \(error.localizedDescription)")
    }
}
