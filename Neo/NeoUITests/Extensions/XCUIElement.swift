//
//  XCUIElement.swift
//  NeoUITests
//
//  Created by Thomas Martins on 14/10/2017.
//  Copyright © 2017 Neo. All rights reserved.
//

import XCTest

extension XCUIElement {

    func clearTextField() {
        guard let stringValue = self.value as? String else {
            XCTFail("Tried to clear and enter text into a non string value")
            return
        }
        self.tap()
        let deleteString = stringValue.map { _ in XCUIKeyboardKey.delete.rawValue }
        self.typeText(deleteString.joined(separator: ""))
    }
}
