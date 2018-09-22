//
//  BackButtonDesign.swift
//  Neo
//
//  Created by Thomas Martins on 18/09/2017.
//  Copyright © 2017 Neo. All rights reserved.
//

import UIKit

class BackButton: UIButton {

    /* Create a back button Navigation */
    
    override func awakeFromNib() {
        guard let titleLabel = titleLabel else { return }
        let font = UIFont(name: "Font Awesome 5 Pro", size: titleLabel.font.pointSize)
        titleLabel.font = font!
        
        setTitle("\u{f104}", for: state)
        self.setTitleColor(UIColor.yellow, for: .normal)
        self.setTitleColor(CommonFunc.hexStringToUIColor(hex: "#60AEC9"), for: .normal)
        
    }
}
