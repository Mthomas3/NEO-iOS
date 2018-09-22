//
//  CircleCells.swift
//  Neo
//
//  Created by Thomas Martins on 14/09/2018.
//  Copyright © 2018 Neo. All rights reserved.
//

import UIKit

@IBDesignable class CircleCells: UITableViewCell {
    
    @IBInspectable var borderWidth = 2.0
    @IBInspectable var borderColor = UIColor.gray.cgColor
    
    override func awakeFromNib() {
        self.layer.borderWidth = CGFloat(borderWidth)
        self.layer.borderColor = borderColor
        //cell.layer.borderWidth = 2.0
        //cell.layer.borderColor = UIColor.gray.cgColor

    }
    
}
