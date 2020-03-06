//
//  modelTests.swift
//  Drift
//
//  Created by Eoin O'Connell on 24/02/2016.
//  Copyright © 2016 Drift. All rights reserved.
//

import XCTest
@testable import Drift

class ModelTests: XCTestCase {

    let decoder = DriftAPIManager.jsonDecoder()

    
    func testAuth() {
        XCTAssertNotNil(try decoder.decode(AuthDTO.self, from: JSONStore.correctAuthJSON.data(using: .utf8)!).mapToObject(), "Auth Did not Map For correct JSON")
        XCTAssertNil(try decoder.decode(AuthDTO.self, from: JSONStore.incompleteAuthJSON.data(using: .utf8)!).mapToObject(), "Auth mapped incorrect JSON")
        XCTAssertNil(try decoder.decode(AuthDTO.self, from: JSONStore.authJSONEmptyAccessToken.data(using: .utf8)!).mapToObject(), "Auth mapped incorrect JSON when access token is empty String")
        XCTAssertNotNil(try decoder.decode(AuthDTO.self, from: JSONStore.authJSONNoUser.data(using: .utf8)!).mapToObject(), "Auth mapping failed when no user")
    }
    
    func testEmbed(){
        XCTAssertNotNil(try decoder.decode(EmbedDTO.self, from: JSONStore.embedJSONCorrect.data(using: .utf8)!).mapToObject(), "Embed Did not Map For correct JSON")
        XCTAssertNil(try decoder.decode(EmbedDTO.self, from: JSONStore.embedJSONNoOrgId.data(using: .utf8)!).mapToObject(), "Embed Mapped embed with no orgId")
    }
}
