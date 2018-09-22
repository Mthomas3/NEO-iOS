//
//  ColorsButtonsOnEditing.swift
//  Neo
//
//  Created by Thomas Martins on 16/02/2018.
//  Copyright © 2018 Neo. All rights reserved.
//

import UIKit

class ColorsButtonOnEditing {
    
    init() { }
    
    private func colorButtonBlue(button: UIButton){
        button.backgroundColor = UIColor(hue: 0.5417, saturation: 0.52, brightness: 0.78, alpha: 1.0)
    }
    
    private func resetButtonColor(button: UIButton){
        button.backgroundColor = UIColor(hue: 0, saturation: 0, brightness: 0.79, alpha: 1.0)
    }
    
    public func colorsButtonOnEditing(textfields: [UITextField], button: UIButton)  {
        
        for field in textfields {
            guard let currentText = field.text, !currentText.isEmpty else {
                resetButtonColor(button: button)
                return
            }
            colorButtonBlue(button: button)
        }
    }
    
    
}
