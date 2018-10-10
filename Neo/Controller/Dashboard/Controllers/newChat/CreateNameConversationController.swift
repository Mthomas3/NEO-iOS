//
//  CreateNameConversationController.swift
//  Neo
//
//  Created by Thomas Martins on 07/10/2018.
//  Copyright © 2018 Neo. All rights reserved.
//

import UIKit
import TextFieldEffects
import SwiftyJSON

class CreateNameConversationController: UIViewController {

    var cells : [MemberCreateConvCell] = []
    
    private var _colorButton : ColorsButtonOnEditing
    @IBOutlet private weak var _nameConv: HoshiTextField!
    @IBOutlet private weak var _doneButton: NextButton!
    internal var circleData: ItemCellData!
    
    required init(coder: NSCoder) {
        _colorButton = ColorsButtonOnEditing()
        super.init(coder: coder)!
    }
    
    private func handleColorButton(){
        _colorButton.colorsButtonOnEditing(textfields: [_nameConv], button: _doneButton)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        _nameConv.becomeFirstResponder()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.view.endEditing(true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        _nameConv.resignFirstResponder()
        _nameConv.autocorrectionType = .no
        
        if #available (iOS 11, *) {
            _nameConv.textContentType = UITextContentType("")
        }
    }
    
    @IBAction func nameEditingChanged(_ sender: Any) {
        handleColorButton()
    }
    
    private func getEmailChecked() -> [String]{
        var emails: [String] = []
        
        cells.forEach { (email) in
            if email.isChecked {
                emails.append(email.email!)
            }
        }
        return emails
    }
    
    @IBAction func createNewConversation(_ sender: Any) {
        
        guard let name = _nameConv.text, !name.isEmpty else {
            HandleErrors.displayError(message: "Le nom n'est pas correct", controller: self)
            return
        }
        
        var checkedCells: [MemberCreateConvCell] = []
        for idx in 0..<cells.count {
            if cells[idx].isChecked == true {
                checkedCells.append(cells[idx])
            }
        }
        
        print("the circle id is \(circleData.Id) && the emails selected \(cells)")
        
        let emails = getEmailChecked()
        
        
        print("emails \(emails) && \(checkedCells[checkedCells.count - 1].email!)")
        /*ApiManager.performAlamofireRequest(url: ApiRoute.ROUTE_CONVERSATION_CREATE, param: ["token": User.sharedInstance.getParameter(parameter: "token"), "circle_id": circleData.Id, "email": getEmailChecked(), "text_message": ""]).done {
                response in
            
                print("the response is \(JSON(response))")
            
            }.catch {error in
            print("the error we get -> \(error)")
        }*/
        
        
        self.performSegue(withIdentifier: "unwindToChatConversation", sender: self)
    }
    
}
