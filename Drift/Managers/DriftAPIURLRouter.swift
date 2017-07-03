//
//  DriftAPIURLRouter.swift
//  Pods
//
//  Created by Eoin O'Connell on 29/05/2017.
//
//

import Alamofire

enum APIBase: String {
    case Customer = "https://customer.api.drift.com/"
    case Conversation = "https://conversation.api.drift.com/"
    case Conversation2 = "https://conversation2.api.drift.com/"
}


enum DriftRouter: URLRequestConvertible {
    
    case getEmbed(embedId: String, refreshRate: Int?)
    case postIdentify(params: [String: Any])
    case getSocketData(accessToken: String)
    
    var request: (method: Alamofire.HTTPMethod, url: URL, parameters: [String: Any]?, encoding: ParameterEncoding){
        switch self {
        case .getEmbed(let embedId, let refreshRate):
            
            let refreshString = Int(Date().timeIntervalSince1970.truncatingRemainder(dividingBy: Double((refreshRate ?? 30000))))

            return (.get, URL(string:"https://js.drift.com/embeds/\(refreshString)/\(embedId).json")!, nil, URLEncoding.default)
            
        case .postIdentify(let params):
            return (.post, URL(string: "https://event.api.drift.com/identify")!, params, JSONEncoding.default)
        case .getSocketData(let accessToken):
            return (.post, URL(string:"https://chat.api.drift.com/api/auth")!, ["access_token": accessToken], JSONEncoding.default)
            
        }
    }
    
    func asURLRequest() throws -> URLRequest {
        var urlRequest = URLRequest(url: request.url)
        urlRequest.httpMethod = request.method.rawValue
        let encoding = request.encoding
        var req = try encoding.encode(urlRequest, with: request.parameters)
        
        req.url = URL(string: (req.url?.absoluteString.replacingOccurrences(of: "%5B%5D=", with: "="))!)
        
        let mutableReq = (req.urlRequest! as NSURLRequest).mutableCopy() as! NSMutableURLRequest
        
        return mutableReq as URLRequest
    }
    
}

enum DriftCustomerRouter: URLRequestConvertible {
    
    case getLayerToken(data: [String: Any])
    case getAuth(email: String, userId: String, redirectURL: String, orgId: Int, clientId: String)
    case getUser(orgId: Int, userId: Int)
    case getEndUser(endUserId: Int)
    
    var request: (method: Alamofire.HTTPMethod, path: String, parameters: [String: Any]?, encoding: ParameterEncoding){
        switch self {
        case .getLayerToken(let data):
            return (.post, "layer/token", data, JSONEncoding.default)
        case .getAuth(let email, let userId, let redirectURL, let orgId, let clientId):
            
            let params: [String : Any] = [
                
                "email": email ,
                "org_id": orgId,
                "user_id": userId,
                "grant_type": "sdk",
                "redirect_uri":redirectURL,
                "client_id": clientId
            ]
            
            return (.post, "oauth/token", params, URLEncoding.default)
        case .getUser(let orgId, let userId):
            
            let params: [String: Any] =
                [   "avatar_w": 102,
                    "avatar_h": 102,
                    "avatar_fit": "1",
                    "userId": userId
            ]
            
            return (.get, "organizations/\(orgId)/users", params, URLEncoding.default)
        case .getEndUser(let endUserId):
            return (.get, "end_users/\(endUserId)", nil, URLEncoding.default)
        }
    }
    
    func asURLRequest() throws -> URLRequest {
        var components = URLComponents(string: APIBase.Customer.rawValue)
        
        if let accessToken = DriftDataStore.sharedInstance.auth?.accessToken{
            let authItem = URLQueryItem(name: "access_token", value: accessToken)
            components?.queryItems = [authItem]
        }
        
        var urlRequest = URLRequest(url: (components?.url!.appendingPathComponent(request.path))!)
        urlRequest.httpMethod = request.method.rawValue
        let encoding = request.encoding
        var req = try encoding.encode(urlRequest, with: request.parameters)
        
        req.url = URL(string: (req.url?.absoluteString.replacingOccurrences(of: "%5B%5D=", with: "="))!)
        
        let mutableReq = (req.urlRequest! as NSURLRequest).mutableCopy() as! NSMutableURLRequest
        
        return mutableReq as URLRequest
    }
    
}

enum DriftConversationRouter: URLRequestConvertible {
    
    case getCampaignsForEndUser(endUserId: Int)
    
    case getEnrichedConversationsForEndUser(endUserId: Int)
    case getConversationsForEndUser(endUserId: Int)
    case getMessagesForConversation(conversationId: Int)
    case postMessageToConversation(conversationId: Int, data: [String: Any])
    case createConversation(body: String)
    
    case recordAnnouncement(conversationId: Int, json: [String: Any])
    case recordNPS(conversationId: Int, json: [String: Any])
    
    var request: (method: Alamofire.HTTPMethod, path: String, parameters: [String: Any]?, encoding: ParameterEncoding){
        switch self {
        case .getCampaignsForEndUser(endUserId: let endUserId):
            return (.get, "conversations/end_users/\(endUserId)/campaigns", nil, URLEncoding.default)
        case .getEnrichedConversationsForEndUser(let endUserId):
            return (.get, "conversations/end_users/\(endUserId)/extra", nil, URLEncoding.default)
        case .getConversationsForEndUser(let endUserId):
            return (.get, "conversations/end_users/\(endUserId)", nil, URLEncoding.default)
        case .getMessagesForConversation(let conversationId):
            return (.get, "conversations/\(conversationId)/messages", nil, URLEncoding.default)
        case .postMessageToConversation(let conversationId, let data):
            return (.post, "conversations/\(conversationId)/messages", data, JSONEncoding.default)
        case .createConversation(let body):
            return (.post, "messages", ["body":body], JSONEncoding.default)
        case .recordAnnouncement(let conversationId, let json):
            return (.post, "conversations/\(conversationId)/messages", json, JSONEncoding.default)
        case .recordNPS(let conversationId, let json):
            return (.post, "conversations/\(conversationId)/messages", json, JSONEncoding.default)
        }
    }
    
    
    func asURLRequest() throws -> URLRequest {
        var components = URLComponents(string: APIBase.Conversation.rawValue)
        if let accessToken = DriftDataStore.sharedInstance.auth?.accessToken{
            let authItem = URLQueryItem(name: "access_token", value: accessToken)
            components?.queryItems = [authItem]
        }
        var urlRequest = URLRequest(url: (components?.url!.appendingPathComponent(request.path))!)
        urlRequest.httpMethod = request.method.rawValue
        let encoding = request.encoding
        var req = try encoding.encode(urlRequest, with: request.parameters)
        
        req.url = URL(string: (req.url?.absoluteString.replacingOccurrences(of: "%5B%5D=", with: "="))!)
        
        return req
    }
    
}

enum DriftConversation2Router: URLRequestConvertible {
    
    case markMessageAsRead(messageId: Int)
    case markConversationAsRead(messageId: Int)
    
    var request: (method: Alamofire.HTTPMethod, path: String, parameters: [String: Any]?, encoding: ParameterEncoding){
        switch self {
        case .markMessageAsRead(let messageId):
            return (.post, "messages/\(messageId)/read", nil, URLEncoding.default)
        case .markConversationAsRead(let messageId):
            return (.post, "messages/\(messageId)/read-until", nil, URLEncoding.default)
        }
    }
    
    func asURLRequest() throws -> URLRequest {
        var components = URLComponents(string: APIBase.Conversation2.rawValue)
        if let accessToken = DriftDataStore.sharedInstance.auth?.accessToken{
            let authItem = URLQueryItem(name: "access_token", value: accessToken)
            components?.queryItems = [authItem]
        }
        var urlRequest = URLRequest(url: (components?.url!.appendingPathComponent(request.path))!)
        urlRequest.httpMethod = request.method.rawValue
        let encoding = request.encoding
        var req = try encoding.encode(urlRequest, with: request.parameters)
        
        req.url = URL(string: (req.url?.absoluteString.replacingOccurrences(of: "%5B%5D=", with: "="))!)

        return req
    }
    
}
