//
//  JSONStore.swift
//  Drift
//
//  Created by Eoin O'Connell on 24/02/2016.
//  Copyright © 2016 Drift. All rights reserved.
//

import UIKit

class JSONStore {

    static let correctAuthJSON = "{\r\n  \"accessToken\": \"2392gcui86crf75xkecstnbytbtwsb2pdvd6rh\",\r\n  \"sessionToken\": \"77LsOIbnS2ZQMRduLKLcSOC9uGBX4B71OHzMTYREMKbuWLQFS36Cley83u2ceSL3Jo6AxjRk392nBhQMZH8ypA.8-4\",\r\n  \"endUser\": {\r\n    \"id\": 7,\r\n    \"orgId\": 1,\r\n    \"customerId\": 0,\r\n    \"status\": \"ENABLED\",\r\n    \"name\": \"Eoin O\'Connell\",\r\n    \"alias\": null,\r\n    \"email\": \"eoin@8bytes.ie\",\r\n    \"phone\": null,\r\n    \"locale\": null,\r\n    \"timeZone\": null,\r\n    \"avatarUrl\": null,\r\n    \"createdAt\": 1456154182646,\r\n    \"externalId\": \"10\",\r\n    \"socialProfile\": {},\r\n    \"attributes\": {},\r\n    \"tags\": [],\r\n    \"happiness\": 0.0,\r\n    \"type\": \"END_USER\"\r\n  }\r\n}"
    
    static let incompleteAuthJSON = "{\r\n  \"accessToken\": null,\r\n  \"sessionToken\": \"77LsOIbnS2ZQMRduLKLcSOC9uGBX4B71OHzMTYREMKbuWLQFS36Cley83u2ceSL3Jo6AxjRk392nBhQMZH8ypA.8-4\",\r\n  \"endUser\": {\r\n    \"id\": 7,\r\n    \"orgId\": 1,\r\n    \"customerId\": 0,\r\n    \"status\": \"ENABLED\",\r\n    \"name\": \"Eoin O\'Connell\",\r\n    \"alias\": null,\r\n    \"email\": \"eoin@8bytes.ie\",\r\n    \"phone\": null,\r\n    \"locale\": null,\r\n    \"timeZone\": null,\r\n    \"avatarUrl\": null,\r\n    \"createdAt\": 1456154182646,\r\n    \"externalId\": \"10\",\r\n    \"socialProfile\": {},\r\n    \"attributes\": {},\r\n    \"tags\": [],\r\n    \"happiness\": 0.0,\r\n    \"type\": \"END_USER\"\r\n  }\r\n}"

    static let authJSONEmptyAccessToken = "{\r\n  \"accessToken\": \"\",\r\n  \"sessionToken\": \"77LsOIbnS2ZQMRduLKLcSOC9uGBX4B71OHzMTYREMKbuWLQFS36Cley83u2ceSL3Jo6AxjRk392nBhQMZH8ypA.8-4\",\r\n  \"endUser\": {\r\n    \"id\": 7,\r\n    \"orgId\": 1,\r\n    \"customerId\": 0,\r\n    \"status\": \"ENABLED\",\r\n    \"name\": \"Eoin O\'Connell\",\r\n    \"alias\": null,\r\n    \"email\": \"eoin@8bytes.ie\",\r\n    \"phone\": null,\r\n    \"locale\": null,\r\n    \"timeZone\": null,\r\n    \"avatarUrl\": null,\r\n    \"createdAt\": 1456154182646,\r\n    \"externalId\": \"10\",\r\n    \"socialProfile\": {},\r\n    \"attributes\": {},\r\n    \"tags\": [],\r\n    \"happiness\": 0.0,\r\n    \"type\": \"END_USER\"\r\n  }\r\n}"

    static let authJSONNoUser = "{\r\n  \"accessToken\": \"2392gcui86crf75xkecstnbytbtwsb2pdvd6rh\",\r\n  \"sessionToken\": \"77LsOIbnS2ZQMRduLKLcSOC9uGBX4B71OHzMTYREMKbuWLQFS36Cley83u2ceSL3Jo6AxjRk392nBhQMZH8ypA.8-4\"\r\n}"

    let test = "\"https://js.driftt.com/include/u4r5t7h6w6h5-dev.js\""
    
    static let embedJSONCorrect = "{\r\n  \"id\": \"y7hy72e542gx\",\r\n  \"url\": \"https://js.driftt.com/include/y7hy72e542gx.js\",\r\n  \"snippet\": \"\",\r\n  \"orgId\": 68,\r\n  \"verified\": false,\r\n  \"configuration\": {\r\n    \"inboxId\": 77,\r\n    \"refreshRate\": 300000,\r\n    \"layerAppId\": \"15806ab6-607f-11e5-817e-98d908000a42\",\r\n    \"inboxEmailAddress\": null,\r\n    \"authClientId\": \"6mx25hy22pgpbc\",\r\n    \"redirectUri\": \"https://app.driftt.com/\",\r\n    \"organizationName\": \"8bytes\",\r\n    \"theme\": {\r\n      \"backgroundColor\": \"2D88F3\",\r\n      \"foregroundColor\": \"FFFFFF\",\r\n      \"logoUrl\": null\r\n    },\r\n    \"chatEnabled\": true,\r\n    \"leadChatEnabled\": false,\r\n    \"enabled\": true,\r\n    \"showBranding\": true,\r\n    \"campaigns\": []\r\n  }\r\n}"
    
    static let embedJSONNoOrgId = "{\r\n  \"id\": \"u4r5t7h6w6h5-dev\",\r\n  \"url\": \"https://js.driftt.com/include/u4r5t7h6w6h5-dev.js\",\r\n  \"orgId\": null,\r\n  \"verified\": false,\r\n  \"configuration\": {\r\n    \"inboxId\": 1,\r\n    \"refreshRate\": 300000,\r\n    \"layerAppId\": \"158066ce-607f-11e5-92d4-98d908000a42\",\r\n    \"authClientId\": \"su9c9zfvdkcfr6\",\r\n    \"redirectUri\": \"https://start.stage.driftt.com\",\r\n    \"organizationName\": \"Driftt Staging\",\r\n    \"theme\": {\r\n      \"backgroundColor\": \"2D88F3\",\r\n      \"foregroundColor\": \"48B1D8\",\r\n      \"logoUrl\": \"https://s3.amazonaws.com/customer-api-org-logos-dev/1/dbc08f540ef37f1e657ea0585a2d9c37\"\r\n    },\r\n    \"chatEnabled\": false,\r\n    \"leadChatEnabled\": false,\r\n    \"enabled\": false\r\n  }\r\n}"

    static let embedJSONEmptyOrgId = "{\r\n  \"id\": \"u4r5t7h6w6h5-dev\",\r\n  \"url\": \"https://js.driftt.com/include/u4r5t7h6w6h5-dev.js\",\r\n  \"orgId\": \"\",\r\n  \"verified\": false,\r\n  \"configuration\": {\r\n    \"inboxId\": 1,\r\n    \"refreshRate\": 300000,\r\n    \"layerAppId\": \"158066ce-607f-11e5-92d4-98d908000a42\",\r\n    \"authClientId\": \"su9c9zfvdkcfr6\",\r\n    \"redirectUri\": \"https://start.stage.driftt.com\",\r\n    \"organizationName\": \"Driftt Staging\",\r\n    \"theme\": {\r\n      \"backgroundColor\": \"2D88F3\",\r\n      \"foregroundColor\": \"48B1D8\",\r\n      \"logoUrl\": \"https://s3.amazonaws.com/customer-api-org-logos-dev/1/dbc08f540ef37f1e657ea0585a2d9c37\"\r\n    },\r\n    \"chatEnabled\": false,\r\n    \"leadChatEnabled\": false,\r\n    \"enabled\": false\r\n  }\r\n}"

    static let embedJSONEmptyLayerAppId = "{\r\n  \"id\": \"u4r5t7h6w6h5-dev\",\r\n  \"url\": \"https://js.driftt.com/include/u4r5t7h6w6h5-dev.js\",\r\n  \"orgId\": 1,\r\n  \"verified\": false,\r\n  \"configuration\": {\r\n    \"inboxId\": 1,\r\n    \"refreshRate\": 300000,\r\n    \"layerAppId\": \"\",\r\n    \"authClientId\": \"su9c9zfvdkcfr6\",\r\n    \"redirectUri\": \"https://start.stage.driftt.com\",\r\n    \"organizationName\": \"Driftt Staging\",\r\n    \"theme\": {\r\n      \"backgroundColor\": \"2D88F3\",\r\n      \"foregroundColor\": \"48B1D8\",\r\n      \"logoUrl\": \"https://s3.amazonaws.com/customer-api-org-logos-dev/1/dbc08f540ef37f1e657ea0585a2d9c37\"\r\n    },\r\n    \"chatEnabled\": false,\r\n    \"leadChatEnabled\": false,\r\n    \"enabled\": false\r\n  }\r\n}"
    
    static let embedJSONNoLayerAppId = "{\r\n  \"id\": \"u4r5t7h6w6h5-dev\",\r\n  \"url\": \"https://js.driftt.com/include/u4r5t7h6w6h5-dev.js\",\r\n  \"orgId\": 1,\r\n  \"verified\": false,\r\n  \"configuration\": {\r\n    \"inboxId\": 1,\r\n    \"refreshRate\": 300000,\r\n    \"authClientId\": \"su9c9zfvdkcfr6\",\r\n    \"redirectUri\": \"https://start.stage.driftt.com\",\r\n    \"organizationName\": \"Driftt Staging\",\r\n    \"theme\": {\r\n      \"backgroundColor\": \"2D88F3\",\r\n      \"foregroundColor\": \"48B1D8\",\r\n      \"logoUrl\": \"https://s3.amazonaws.com/customer-api-org-logos-dev/1/dbc08f540ef37f1e657ea0585a2d9c37\"\r\n    },\r\n    \"chatEnabled\": false,\r\n    \"leadChatEnabled\": false,\r\n    \"enabled\": false\r\n  }\r\n}"

    static let campaignOrganiserJSONCorrect = "[\r\n  {\r\n    \"id\": 10,\r\n    \"name\": \"Eoin O\'Connell\",\r\n    \"avatarUrl\": \"https://driftt.imgix.net/https%3A%2F%2Fs3.amazonaws.com%2Fcustomer-api-avatars-dev%2F10%2F189129e1487177b3280518026f38707b?h=400&w=400&fit=1&s=96c3978127eeff36cd4cf8aad2bd4cc3\"\r\n  }\r\n]"

    static let campaignOrganiserJSONEmptyURL = "[\r\n  {\r\n    \"id\": 10,\r\n    \"name\": \"Eoin O\'Connell\",\r\n    \"avatarUrl\": \"\"\r\n  }\r\n]"
    static let campaignOrganiserJSONInvalidURL = "[\r\n  {\r\n    \"id\": 10,\r\n    \"name\": \"Eoin O\'Connell\",\r\n    \"avatarUrl\": \"test \"\r\n  }\r\n]"

    class func convertStringToDictionary(text: String) -> [String:AnyObject]? {
        if let data = text.dataUsingEncoding(NSUTF8StringEncoding) {
            do {
                return try NSJSONSerialization.JSONObjectWithData(data, options: []) as? [String:AnyObject]
            } catch let error as NSError {
                print(error)
            }
        }
        return nil
    }
    
    class func convertStringToDictionaryArray(text: String) -> [[String:AnyObject]]? {
        if let data = text.dataUsingEncoding(NSUTF8StringEncoding) {
            do {
                return try NSJSONSerialization.JSONObjectWithData(data, options: []) as? [[String:AnyObject]]
            } catch let error as NSError {
                print(error)
            }
        }
        return nil
    }

    
}
