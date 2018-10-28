//
//  DisplayAvailableCircleController.swift
//  Neo
//
//  Created by Thomas Martins on 05/10/2018.
//  Copyright © 2018 Neo. All rights reserved.
//

import UIKit
import SwiftyJSON
import TextFieldEffects

class DisplayAvailableCircleController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {

    @IBOutlet weak var _circleSelected: HoshiTextField!
    @IBOutlet private weak var _pickerCircle: UIPickerView!
    @IBOutlet private weak var _nextButton: NextButton!
    private var circle: [ItemCellData] = []
    private var _colorButton : ColorsButtonOnEditing
    
    required init(coder: NSCoder) {
        _colorButton = ColorsButtonOnEditing()
        super.init(coder: coder)!
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        _pickerCircle.delegate = self
        _pickerCircle.dataSource = self
    }
    
    private func handleColorButton(){
        
        _colorButton.colorsButtonOnEditing(textfields: [_circleSelected], button: _nextButton)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        circle.removeAll()
        ServicesCircle.shareInstance.getCirclesInformations { (data) in
            data.forEach({ (item) in
                self.circle.append(item)
            })
            self._pickerCircle.reloadAllComponents()
        }
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return circle.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        _circleSelected.text = circle[row].Name
        handleColorButton()
        return circle[row].Name
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if identifier.isEqualToString(find: "createConvSegue") {
            guard let selectedValue = _circleSelected.text, !selectedValue.isEmpty else {
                HandleErrors.displayError(message: "Aucun cercle n'a été sélectionné", controller: self)
                return false
            }
            return true
        }
        return true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "createConvSegue" {
            
            let idx = self._pickerCircle.selectedRow(inComponent: 0)
        
            let vc = segue.destination as? DisplayMemberInsideCircleController
            vc?.CircleData = self.circle[idx]
        }
    }
}
