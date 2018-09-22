//
//  CustomButton.swift
//  Neo
//
//  Created by Thomas Martins on 12/09/2017.
//  Copyright © 2017 Neo. All rights reserved.
//

import UIKit

@IBDesignable class NextButton: UIButton {
    
    @IBInspectable var cornerradius : CGFloat = 22
    @IBInspectable var backgroundcolor: String = "#CBCBCB"
    
    override func awakeFromNib() {
        

        self.layer.cornerRadius = cornerradius;
        self.backgroundColor = CommonFunc.hexStringToUIColor(hex: backgroundcolor);
        self.setTitleColor(UIColor.white, for: UIControlState.normal)
        self.titleLabel?.font = UIFont.systemFont(ofSize: 20)
        self.clipsToBounds = true;
    }
}
