//
//  MemberCreateConvCell.swift
//  Neo
//
//  Created by Nicolas Gascon on 09/07/2018.
//  Copyright © 2018 Neo. All rights reserved.
//

import UIKit

class MemberCreateConvCell: UICollectionViewCell {
    
    @IBOutlet weak var checkBox: UILabel!
    
    @IBOutlet weak var memberName: UILabel!
    
    var email: String?
    
    var isChecked: Bool = false {
        didSet {
            if isChecked == true {
                checkBox.text = ""
            } else {
                checkBox.text = ""
            }
        }
    }
    
    var setName: String = "" {
        didSet {
            memberName.text = setName
        }
    }
    
    @IBAction func pressCellAction(_ sender: Any) {
        isChecked = !isChecked
    }
}
