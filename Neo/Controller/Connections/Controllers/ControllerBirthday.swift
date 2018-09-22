//
//  ViewControllerBirthday.swift
//  Neo
//
//  Created by Thomas Martins on 13/09/2017.
//  Copyright © 2017 Neo. All rights reserved.
//

import UIKit
import TextFieldEffects

class ControllerBirthday: UIViewController {
    
    @IBOutlet private weak var _displayBirthday: HoshiTextField!
    @IBOutlet private weak var _birthdayValue: UIDatePicker!
    @IBOutlet private weak var _nextButton: NextButton!
    private var _colorButton : ColorsButtonOnEditing
    
    required init(coder: NSCoder) {
        _colorButton = ColorsButtonOnEditing()
        super.init(coder: coder)!
    }
    
    @IBAction func backButtonTrigger(_ sender: Any) { }
    
    private func handleColorButton(){
        _colorButton.colorsButtonOnEditing(textfields: [_displayBirthday], button: _nextButton)
    }
    
    @IBAction private func birthdayValueChanged(_ sender: Any) {
        datePickerValueChanged(sender: _birthdayValue)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        _displayBirthday.isUserInteractionEnabled = false
    }
    
    override var prefersStatusBarHidden: Bool{
        return true
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if identifier.isEqualToString(find: "showPassword"){
            guard let birthdayValue = _displayBirthday.text, !birthdayValue.isEmpty else {
                
                HandleErrors.displayError(message: "The birthday date you picked is invalid", controller: self)
                
                return false
            }
        }
        return true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard segue.identifier == "showPassword" else {return}
        
        if segue.destination as? ControllerPassword != nil {
            User.sharedInstance.setUserInformations(birthday: _displayBirthday.text!)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func unwindToBirthday( segue:UIStoryboardSegue ){
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.view.endEditing(true);
    }
    
    private func datePickerValueChanged(sender: UIDatePicker) -> Void{
        let formatter = DateFormatter();
        formatter.dateStyle = DateFormatter.Style.medium;
        formatter.timeStyle = DateFormatter.Style.none;
        _displayBirthday.text = formatter.string(from: sender.date)
        handleColorButton()
    }
}
