//
//  modelTests.swift
//  Drift
//
//  Created by Eoin O'Connell on 24/02/2016.
//  Copyright © 2016 Drift. All rights reserved.
//

import XCTest
import ObjectMapper
@testable import Drift

class ModelTests: XCTestCase {
       
    func testAuth() {
        XCTAssertNotNil(Mapper<Auth>().map(JSON: JSONStore.convertStringToDictionary(text: JSONStore.correctAuthJSON)!), "Auth Did not Map For correct JSON")
        XCTAssertNil(Mapper<Auth>().map(JSON: JSONStore.convertStringToDictionary(text: JSONStore.incompleteAuthJSON)!), "Auth mapped incorrect JSON")
        XCTAssertNil(Mapper<Auth>().map(JSON: JSONStore.convertStringToDictionary(text: JSONStore.authJSONEmptyAccessToken)!), "Auth mapped incorrect JSON when access token is empty String")
        XCTAssertNotNil(Mapper<Auth>().map(JSON: JSONStore.convertStringToDictionary(text: JSONStore.authJSONNoUser)!), "Auth mapping failed when no user")
    }
    
    func testEmbed(){
        XCTAssertNotNil(Mapper<Embed>().map(JSON: JSONStore.convertStringToDictionary(text: JSONStore.embedJSONCorrect)!), "Embed Did not Map For correct JSON")
        XCTAssertNil(Mapper<Embed>().map(JSON: JSONStore.convertStringToDictionary(text: JSONStore.embedJSONNoOrgId)!), "Embed Mapped embed with no orgId")
        XCTAssertNil(Mapper<Embed>().map(JSON: JSONStore.convertStringToDictionary(text: JSONStore.embedJSONEmptyOrgId)!), "Embed Mapped embed with string org Id")
    }
}
