//
//  NeoUITestsConnection.swift
//  NeoUITests
//
//  Created by Thomas Martins on 02/10/2017.
//  Copyright © 2017 Neo. All rights reserved.
//

import XCTest

class NeoUITestsConnection: XCTestCase {
    private let screen = Screen()
    
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        XCUIApplication().launch()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testNavigationConnection(){
        screen.tapOnButton(buttonName: "SIGN IN")
        XCTAssert(XCUIApplication().textFields["Email"].exists)
    }
    
    func testNavigationBackHome(){
        screen.tapOnButton(buttonName: "SIGN IN")
        XCTAssert(XCUIApplication().textFields["Email"].exists)
        screen.tapOnButton(buttonName: "backButton")
        XCTAssert(XCUIApplication().buttons["SIGN IN"].exists)
    }
    
    
    
    func testConnectionBadArguments(){
        
        screen.tapOnButton(buttonName: "SIGN IN")
        let data = CommunMethods.getDictionaryData()
        
        for value in data{
            
            screen.type(string: value.key, field: XCUIApplication().textFields["Email"])
            XCUIApplication().secureTextFields["Mot de passe"].tap()
            XCUIApplication().secureTextFields["Mot de passe"].typeText(value.value)
            
            screen.tapOnButton(buttonName: "Connection")
            
            XCTAssert(XCUIApplication().buttons["Connection"].exists)
            
            screen.clearSecureTextFIeld(textField: "Mot de passe")
            screen.clearTextField(textField: "Email")
            
            screen.tapOnTextfield(textFieldName: "Email")
        }
    }
    
    func testSucessfulConnection(){
        
       /* screen.tapOnButton(buttonName: "SIGN IN")
        screen.type(string: "thomas.martins@epitech.eu", field: XCUIApplication().textFields["Email"])
        XCUIApplication().secureTextFields["Mot de passe"].tap()
        screen.type(string: "toto", field: XCUIApplication().secureTextFields["Mot de passe"])
        
        screen.tapOnButton(buttonName: "Connection")
        //XCTAssert(XCUIApplication().tables.staticTexts["Mon Compte"].exists)
        
        // XCTAssertTrue((XCUIApplication().tables/*@START_MENU_TOKEN@*/.cells.staticTexts["Mon Compte"]/*[[".cells.staticTexts[\"Mon Compte\"]",".staticTexts[\"Mon Compte\"]"],[[[-1,1],[-1,0]]],[1]]@END_MENU_TOKEN@*/).exists)*/
        
        
        let app = XCUIApplication()
        app.buttons["SIGN IN"].tap()
        app.textFields["Email"].typeText("thomas.martins@epitech.eu")
        
        let motDePasseSecureTextField = app.secureTextFields["Mot de passe"]
        motDePasseSecureTextField.tap()
        motDePasseSecureTextField.typeText("toto")
        app.buttons["Connection"].tap()
    }
    
    func testNavigation(){
        let app = XCUIApplication()
        app.buttons["SIGN IN"].tap()
        app.textFields["Email"].typeText("thomas.martins@epitech.eu")
        
        let motDePasseSecureTextField = app.secureTextFields["Mot de passe"]
        motDePasseSecureTextField.tap()
        motDePasseSecureTextField.typeText("toto")
        app.buttons["Connection"].tap()
        
        let tabBarsQuery = app.tabBars
        tabBarsQuery.buttons["Contacts"].tap()
        tabBarsQuery.buttons["Favorites"].tap()
        tabBarsQuery.buttons["Recents"].tap()
        
    }
    
    func testSettingAccount(){
        
        let app = XCUIApplication()
        app.buttons["SIGN IN"].tap()
        app.textFields["Email"].typeText("thomas.martins@epitech.eu")
        
        let motDePasseSecureTextField = app.secureTextFields["Mot de passe"]
        motDePasseSecureTextField.tap()
        motDePasseSecureTextField.typeText("toto")
        app.buttons["Connection"].tap()
        app.tabBars.buttons["Favorites"].tap()
        app.tables/*@START_MENU_TOKEN@*/.staticTexts["Account"]/*[[".cells.staticTexts[\"Account\"]",".staticTexts[\"Account\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        app.navigationBars["Account"].buttons["Settings"].tap()
       
    }
    
    
    func testSettingChangeUserName(){
        let app = XCUIApplication()
        app.buttons["SIGN IN"].tap()
        app.textFields["Email"].typeText("thomas.martins@epitech.eu")
        
        let motDePasseSecureTextField = app.secureTextFields["Mot de passe"]
        motDePasseSecureTextField.tap()
        motDePasseSecureTextField.typeText("toto")
        app.buttons["Connection"].tap()
        app.tabBars.buttons["Favorites"].tap()
        
        let tablesQuery = app.tables
        tablesQuery/*@START_MENU_TOKEN@*/.staticTexts["Account"]/*[[".cells.staticTexts[\"Account\"]",".staticTexts[\"Account\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        
        let textField = tablesQuery.children(matching: .cell).element(boundBy: 0).children(matching: .textField).element
        textField.tap()
        textField.typeText("eaeoae")
        app.navigationBars["Account"].buttons["Done"].tap()
    }
    
    func testWrongEmailAddress(){
        
        let app = XCUIApplication()
        app.buttons["SIGN IN"].tap()
        app.textFields["Email"].typeText("thomas.martins@epitech.eu")
        
        let motDePasseSecureTextField = app.secureTextFields["Mot de passe"]
        motDePasseSecureTextField.tap()
        motDePasseSecureTextField.typeText("toto")
        app.buttons["Connection"].tap()
        
        let tabBarsQuery = app.tabBars
        tabBarsQuery.buttons["Contacts"].tap()
        app.navigationBars["Contacts"].buttons["Add"].tap()
        
        let textField = app.tables.cells.children(matching: .textField).element
        textField.tap()
        textField.typeText("")
        textField.typeText("nicolas.gascon@outlook.fr")
        
        let addAContactNavigationBar = app.navigationBars["Add a contact"]
        addAContactNavigationBar.buttons["Save"].tap()
        app.alerts["An error occured"].buttons["Ok"].tap()
        addAContactNavigationBar.buttons["Contacts"].tap()
        tabBarsQuery.buttons["Recents"].tap()
        
    }
    
    
}
