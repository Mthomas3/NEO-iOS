//
//  Screen.swift
//  NeoUITests
//
//  Created by Thomas Martins on 02/10/2017.
//  Copyright © 2017 Neo. All rights reserved.
//

import XCTest

class Screen {
    
    private let doneButton = XCUIApplication().navigationBars["Expense"].buttons["Done"]
    private let trashButton = XCUIApplication().navigationBars["Expense"].buttons["Edit"]
    private let editButton = XCUIApplication().navigationBars["Expense"].buttons["Trash"]
    private let deleteButton = XCUIApplication().alerts["Delete transaction?"].buttons["Delete"]
    private let pickerWheelDate = XCUIApplication().tables.pickerWheels.element(boundBy: 0)
    
    private func tap(element: XCUIElement){
        element.tap()
    }
    
    func tapOnDeleteButton(){
        tap(element: deleteButton)
    }
    
    func type(string: String, field: XCUIElement){
        tap(element: field)
        field.typeText(string)
    }
    
    func tapOnButton(buttonName: String){
        tap(element: XCUIApplication().buttons[buttonName])
    }
    
    func tapOnDoneButton(){
        tap(element: doneButton)
    }
    
    func tapOnTrashButton(){
        tap(element: trashButton)
    }
    
    func tapOnEditButton(){
        tap(element: editButton)
    }
    
    func selectDate(month: String, day: String){
        pickerWheelDate.adjust(toPickerWheelValue: "\(month) \(day)")
    }
    
    func tapOnTextfield(textFieldName: String){
        tap(element: XCUIApplication().textFields[textFieldName])
    }
    
    func clearTextField(textField: String){
        XCUIApplication().textFields[textField].clearTextField()
    }
    
    func clearSecureTextFIeld(textField: String){
        XCUIApplication().secureTextFields[textField].clearTextField()
    }
    
}
