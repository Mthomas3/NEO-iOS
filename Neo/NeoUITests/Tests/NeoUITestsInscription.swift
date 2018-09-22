//
//  NeoUITestsInscription.swift
//  NeoUITests
//
//  Created by Thomas Martins on 02/10/2017.
//  Copyright © 2017 Neo. All rights reserved.
//

import XCTest

class NeoUITestsInscription: XCTestCase {
    private let screen = Screen()
    
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        XCUIApplication().launch()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testNavigationInscription(){
        screen.tapOnButton(buttonName: "SIGN UP")
        XCTAssert(XCUIApplication().textFields["Name"].exists)
    }
    
    
    
}
