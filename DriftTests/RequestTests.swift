//
//  RequestTests.swift
//  Drift
//
//  Created by Eoin O'Connell on 02/02/2016.
//  Copyright © 2016 Drift. All rights reserved.
//

import XCTest
@testable import Drift

class RequestTests: XCTestCase {
    
    override func setUp() {
        super.setUp()

    }
    
    override func tearDown() {

        super.tearDown()
    }
    
    func testGET(){
        
        let request = Request(url: NSURL(string: "http://www.8bytes.ie")!)
        
        XCTAssertTrue(request.getRequest().HTTPMethod == "GET", "Method is GET")
        XCTAssertFalse(request.getRequest().HTTPMethod == "POST", "Method is POST")
        
        request.setMethod(.POST)
        XCTAssertTrue(request.getRequest().HTTPMethod == "POST", "Method is POST")
        
        request.setData(.URL(params: ["test": "true"]))
        
        XCTAssertTrue(request.getRequest().URL!.absoluteString.containsString("?test=true"), "Method has URL params")
        
        XCTAssertTrue(request.getRequest().HTTPBody == nil, "Body is nil")
        
        request.setData(.JSON(json: ["json": true]))
        
        XCTAssertTrue(request.getRequest().allHTTPHeaderFields!["Content-Type"] == "application/json", "Check content Type")
        XCTAssertTrue(request.getRequest().allHTTPHeaderFields!["Accept"] == "application/json", "Check content Type")

        
    }
    
}
