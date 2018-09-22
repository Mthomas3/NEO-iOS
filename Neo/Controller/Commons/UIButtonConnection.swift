//
//  UIButtonConnection.swift
//  Neo
//
//  Created by Thomas Martins on 21/09/2018.
//  Copyright © 2018 Neo. All rights reserved.
//

import UIKit
import TransitionButton

class setUIviewButtonConnection {
    static public func setView(button: TransitionButton, title: String, actionSelector: Selector?, controller: UIViewController) {
        
        controller.view.addSubview(button)
        button.backgroundColor = CommonFunc.hexStringToUIColor(hex: "#CBCBCB")
        button.setTitle("Connexion", for: .normal)
        button.cornerRadius = 20
        button.spinnerColor = .white
        button.addTarget(controller, action: actionSelector!, for: .touchUpInside)
        
    }
}
