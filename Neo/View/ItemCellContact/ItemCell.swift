//
//  ItemCell.swift
//  Neo
//
//  Created by Thomas Martins on 13/09/2018.
//  Copyright © 2018 Neo. All rights reserved.
//

import UIKit

class ItemCell: UICollectionViewCell {

    @IBOutlet weak var textLabel: UILabel!
    @IBOutlet weak var _circleDate: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.layer.cornerRadius = 2
    }
    
    func setData(circleName: String, circleDate: String) {
        self.textLabel.text = circleName
        self._circleDate.text = circleDate
    }
    
    public func getData() -> String{ return self.textLabel.text!}

}
