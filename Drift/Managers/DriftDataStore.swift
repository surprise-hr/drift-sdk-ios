//
//  DriftDataStore.swift
//  Drift
//
//  Created by Eoin O'Connell on 28/01/2016.
//  Copyright © 2016 Drift. All rights reserved.
//

///Datastore for caching Embed and Auth object between app opens
class DriftDataStore {

    static let driftAuthCacheString = "DriftSDKAuthDataJSONCache"
    static let driftEmbedCacheString = "DriftSDKEmbedJSONCache"
    static let driftUserIdCacheString = "DriftSDKUserIdCache"
    static let driftUserEmailCacheString = "DriftSDKUserEmailCache"
    static let driftUserJwtCacheString = "DriftSDKUserJWTCache"

    fileprivate (set) var auth: Auth?
    fileprivate (set) var embed: Embed?
    fileprivate (set) var userId: String?
    fileprivate (set) var userEmail: String?
    fileprivate (set) var userJwt: String?

    
    static var sharedInstance: DriftDataStore = {
        let store = DriftDataStore()
        store.loadData()
        return store
    }()
    
    func setAuth(_ auth: Auth) {
        self.auth = auth
        saveData()
    }
    
    func setEmbed(_ embed: Embed) {
        self.embed = embed
        saveData()
    }
    
    func setUserId(_ userId: String) {
        self.userId = userId
        saveData()
    }

    func setEmail(_ email: String?) {
        self.userEmail = email
        saveData()
    }
    
    func setUserJwt(_ userJwt: String?) {
        self.userJwt = userJwt
        saveData()
    }
    
    func loadData(){
        let userDefs = UserDefaults.standard
        let decoder = DriftAPIManager.jsonDecoder()

        if let jsonString = userDefs.string(forKey: DriftDataStore.driftAuthCacheString),
            let data = jsonString.data(using: .utf8),
            let auth = try? decoder.decode(Auth.self, from: data) {
            self.auth = auth
        } else {
            LoggerManager.log("Failed to load auth")
        }
        
        if let jsonString = userDefs.string(forKey: DriftDataStore.driftEmbedCacheString),
            let data = jsonString.data(using: .utf8),
            let embed = try? decoder.decode(Embed.self, from: data) {
            self.embed = embed
        } else {
            LoggerManager.log("Failed to load embed")
        }
                
        if let userId = userDefs.string(forKey: DriftDataStore.driftUserIdCacheString) {
            self.userId = userId
        }
        
        if let userEmail = userDefs.string(forKey: DriftDataStore.driftUserEmailCacheString) {
            self.userEmail = userEmail
        }
        
        self.userJwt = userDefs.string(forKey: DriftDataStore.driftUserJwtCacheString)
    
    }
    
    func saveData(){
        let userDefs = UserDefaults.standard
        let encoder = JSONEncoder()

        if let embed = embed,
            let data = try? encoder.encode(embed),
            let json = String(data: data, encoding: .utf8) {
            userDefs.set(json, forKey: DriftDataStore.driftEmbedCacheString)
        } else {
            LoggerManager.log("Failed to save embed")
        }
            
        if let auth = auth,
            let data = try? encoder.encode(auth),
            let json = String(data: data, encoding: .utf8) {
            userDefs.set(json, forKey: DriftDataStore.driftAuthCacheString)
        }
        
        if let userId = userId {
            userDefs.set(userId, forKey: DriftDataStore.driftUserIdCacheString)
        }
        
        if let userEmail = userEmail {
            userDefs.set(userEmail, forKey: DriftDataStore.driftUserEmailCacheString)
        }
        
        userDefs.set(userJwt, forKey: DriftDataStore.driftUserJwtCacheString)
        
        userDefs.synchronize()
        
        DriftDataStore.sharedInstance = self
    }
    
    func removeData(){
        let userDefs = UserDefaults.standard
        userDefs.removeObject(forKey: DriftDataStore.driftAuthCacheString)
        userDefs.removeObject(forKey: DriftDataStore.driftEmbedCacheString)
        userDefs.removeObject(forKey: DriftDataStore.driftUserJwtCacheString)
        userDefs.synchronize()
        auth = nil
        userId = nil
        userEmail = nil
    }
}

extension DriftDataStore{
    
    func generateBackgroundColor() -> UIColor {
        if let backgroundColor = embed?.backgroundColor {
            return UIColor(hexString: backgroundColor)
        }
        return UIColor(red:0.54, green:0.4, blue:1, alpha:1)
    }
    
    func generateForegroundColor() -> UIColor {
        if let foregroundColor = embed?.foregroundColor {
            return UIColor(hexString: foregroundColor)
        }
        return UIColor(red:0.54, green:0.4, blue:1, alpha:1)
    }
}
