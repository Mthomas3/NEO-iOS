//
//  ChatLogController.swift
//  Neo
//
//  Created by Thomas Martins on 05/10/2018.
//  Copyright © 2018 Neo. All rights reserved.
//

import UIKit
import SocketIO
import SwiftyJSON
import Alamofire

class ChatLogController: UICollectionViewController,
    UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    internal let cellId = "cellId"
    internal let dateId = "dateId"
    internal var messages = [Message]()
    internal var convId: Int = 0
    internal var circleId: Int = 0
    private let messageDay:[Int: String] = [1:"Sun", 2:"Mon", 3:"Tue", 4:"Wed", 5:"Thu", 6:"Fri", 7:"Sat"]
    private var bottomConstraint: NSLayoutConstraint?
    internal var mediaCellCount = 0
    public var AlamofireTasks = [Alamofire.Request]()
    
    public func getAlamofireTasks() -> [Alamofire.Request] {return self.AlamofireTasks}
    public func setAlamofireTasks(task: Alamofire.Request) {self.AlamofireTasks.append(task)}
    
    let messageInputContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white
        return view
    }()
    
    var inputTextField: UITextField = {
        let textField = UITextField()
        textField.layer.borderColor = UIColor.gray.cgColor
        textField.layer.borderWidth = 0.5
        textField.layer.cornerRadius = 20
        textField.placeholder = "Entrer un message..."
        let paddingView = UIView(frame: CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: 15, height: textField.frame.height)))
        textField.leftView = paddingView
        textField.leftViewMode = .always
        return textField
    }()
    
    lazy var imageButton: UIButton = {
        let button = UIButton(type: .system)
        var buttonString = ""
        button.tintColor = UIColor.gray
        var buttonStringAttributed = NSMutableAttributedString(string: buttonString, attributes: [NSAttributedStringKey.font:UIFont(name: "Font Awesome 5 Pro", size: 22)!])
        button.setAttributedTitle(buttonStringAttributed, for: .normal)
        button.addTarget(self, action: #selector(handleSendImage), for: .touchUpInside)
        return button
    }()
    
    lazy var sendButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Envoyer", for: .normal)
        let titleColor = UIColor(red: 0, green: 137/255, blue: 249/255, alpha: 1)
        button.setTitleColor(titleColor, for: [])
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.addTarget(self, action: #selector(handleSend), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpUI()
    }
    
    private func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {

    
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        var selectedImageFromPicker: UIImage?
        if let image = info["UIImagePickerControllerEditedImage"] as? UIImage {
            selectedImageFromPicker = image
        } else if let originalImage = info["UIImagePickerControllerOriginalImage"] as? UIImage {
            selectedImageFromPicker = originalImage
        }
        
        if let selectedImage = selectedImageFromPicker {
            uploadImageSelectedOnConversation(image: selectedImage, isPicker: "true")
        }
        dismiss(animated: true, completion: nil)
    }
    
    @objc private func handleSendImage() {
        let imagePickerController = UIImagePickerController()
        imagePickerController.allowsEditing = true
        imagePickerController.delegate = self
        present(imagePickerController, animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    private func setUpNavigationBar() {
        
        let rightAddBarButtonItem:UIBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.done, target: self, action: #selector(self.addToConv))
        rightAddBarButtonItem.setTitleTextAttributes([NSAttributedStringKey.font: UIFont(name: "Font Awesome 5 Pro", size: 19)!], for: .normal)
       
        
        let rightAddBarButtonItemCall:UIBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.done, target: self, action: #selector(self.performVideoCall))
        rightAddBarButtonItemCall.setTitleTextAttributes([NSAttributedStringKey.font: UIFont(name: "Font Awesome 5 Pro", size: 19)!], for: .normal)
        
        
        self.navigationItem.setRightBarButtonItems([rightAddBarButtonItemCall, rightAddBarButtonItem], animated: true)
    }
    
    @objc private func performVideoCall() {
        ApiManager.performAlamofireRequest(url: "conversation/info", param: ["token": User.sharedInstance.getParameter(parameter: "token"), "conversation_id": convId]).done {
            data in
            
            let json = JSON(data)["content"]["links"][0]["user_id"]
            
            let newViewController = UIStoryboard(name: "Dashboard", bundle: nil).instantiateViewController(withIdentifier: "VideoCallController") as! VideoCallController
            self.navigationController?.pushViewController(newViewController, animated: true)
            
            newViewController.OpponentEmail = json["email"].stringValue
            newViewController.OpponentId = json["id"].intValue
            
        }
    }
    
    private func setUpUI() {
        self.tabBarController?.tabBar.isHidden = true
        hideKeyboardWhenTappedAround()

        collectionView?.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 40, right: 0)
        collectionView?.alwaysBounceVertical = true
        collectionView?.backgroundColor = UIColor.white
        collectionView?.register(ChatLogMessageCell.self, forCellWithReuseIdentifier: cellId)
        collectionView?.register(ChatLogDateCell.self, forCellWithReuseIdentifier: dateId)
        view.addSubview(messageInputContainerView)
        view.addConstraintsWithFormat(format: "H:|[v0]|", views: messageInputContainerView)
        view.addConstraintsWithFormat(format: "V:[v0(68)]", views: messageInputContainerView)
        bottomConstraint = NSLayoutConstraint(item: messageInputContainerView, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1, constant: 0)
        view.addConstraint(bottomConstraint!)
        setupInputComponents()
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardNotification), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardNotificationHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        setUpNavigationBar()
    }
    
    @objc func addToConv() {
        let newViewController = UIStoryboard(name: "Dashboard", bundle: nil).instantiateViewController(withIdentifier: "AddMemberStoryboard") as! AddMemberToConvController
        
        self.navigationController?.pushViewController(newViewController, animated: true)
        newViewController.convId = convId
        newViewController.viewController = self
        newViewController.loadCircles()
    }
    
    func loadDayName(weekDay: Int) -> String{
        return messageDay[weekDay] ?? "None"
    }
    
    func getDayOfWeek(_ todayDate: Date) -> Int {
        let myCalendar = Calendar(identifier: .gregorian)
        let weekDay = myCalendar.component(.weekday, from: todayDate)
        return weekDay
    }
    
    deinit {
        SocketManager.sharedInstance.getManager().defaultSocket.emit("leave_conversation", JoinConversation(conversation_id: convId))
    }
    
    func returnDateFromString( text: String) -> Date {
        let types: NSTextCheckingResult.CheckingType = [.date ]
        let detector = try? NSDataDetector(types: types.rawValue)
        var aDate = Date() // default to today if none, no error check I know
        let result = detector?.firstMatch(in: text, range: NSMakeRange(0, text.utf16.count))
        if result?.resultType == .date {
            aDate = (result?.date)!
        }
        return aDate
    }
    
    internal func createButtonConversation(nameConversation: String) {
        let button =  UIButton(type: .custom)
        button.frame = CGRect(x: 0, y: 0, width: 150, height: 40)
        button.backgroundColor = UIColor(white: 1, alpha: 0.0)
        button.setTitle(nameConversation, for: .normal)
        button.setTitleColor(UIColor.black, for: .normal)
        button.addTarget(self, action: #selector(self.clickOnTitle), for: .touchUpInside)
        self.navigationItem.titleView = button
    }
    
    internal func slideOnLastMessage() {
        self.collectionView?.reloadData()
        let lastItemIndex = NSIndexPath(item: self.messages.count - 1, section: 0)
        self.collectionView?.scrollToItem(at: lastItemIndex as IndexPath, at: .bottom, animated: false)
    }
    
    internal func detectSenderMessage(link_id: Int, links: JSON) -> Bool{
        var tmp: JSON = []
        
        for (_, item) in links {
            if item["id"].intValue == link_id {
                tmp = item
                break
            }
        }
        if ((!tmp.isEmpty) && tmp["user_id"]["email"].stringValue == User.sharedInstance.getEmail()) {
            return true
        }
        return false
    }
    
    internal func displayMediaInCollectionView(image: UIImage) {
        
        for idx in 0...(self.messages.count) - 1 {
            
            if self.messages[idx].isMediaLoading == true {
                self.messages[idx].image = image
                self.messages[idx].text = nil
                self.messages[idx].isMediaLoading = false
                self.collectionView?.reloadItems(at: [IndexPath(row: idx, section: 0)])
                break
            }
        }
    }
    
    @objc func clickOnTitle() {
        let newViewController = UIStoryboard(name: "Dashboard", bundle: nil).instantiateViewController(withIdentifier: "convSettings") as! ConvConfigurationSettings
        self.navigationController?.pushViewController(newViewController, animated: true)
        newViewController.convId = convId
        newViewController.loadSettings()
    }
    
    private func setupInputComponents() {
        let topBorderView = UIView()
        topBorderView.backgroundColor = UIColor(white: 0.5, alpha: 0.5)
        
        messageInputContainerView.addSubview(inputTextField)
        messageInputContainerView.addSubview(sendButton)
        
        messageInputContainerView.addSubview(imageButton)
        
        topBorderView.layer.backgroundColor = UIColor.white.cgColor
        
        messageInputContainerView.addSubview(topBorderView)
        
        messageInputContainerView.addConstraintsWithFormat(format: "H:|-8-[v0]-10-[v1(230)][v2(80)]-8-|", views: imageButton, inputTextField, sendButton)
        
        messageInputContainerView.addConstraintsWithFormat(format: "V:|-12-[v0]-12-|", views: inputTextField)
        messageInputContainerView.addConstraintsWithFormat(format: "V:|[v0]|", views: sendButton)
        messageInputContainerView.addConstraintsWithFormat(format: "V:|[v0]|", views: imageButton)
        
        messageInputContainerView.addConstraintsWithFormat(format: "H:|[v0]|", views: topBorderView)
        messageInputContainerView.addConstraintsWithFormat(format: "V:|[v0(0.5)]", views: topBorderView)
    }
    
    @objc func handleSend() {
    
        if !((inputTextField.text?.isEmpty)!) {
            SocketManager.sharedInstance.getManager().defaultSocket.emit("message", MessageData(text_message: inputTextField.text!, conversation_id: convId))
            
            inputTextField.text = nil
        }
    }
    
    @objc func handleKeyboardNotification(notification: NSNotification) {
        if let userInfo = notification.userInfo {
            
            let keyboardFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as AnyObject).cgRectValue
            let keyboardDuration = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as AnyObject).doubleValue
            
            bottomConstraint?.constant = -keyboardFrame!.height
            
            print(-keyboardFrame!.height)
            
            UIView.animate(withDuration: keyboardDuration!, animations: {
                
                self.view.layoutIfNeeded()
                
            }, completion: { (completed) in
                
                self.collectionView?.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 80, right: 0)
                let lastItemIndex = NSIndexPath(item: self.messages.count - 1, section: 0)
                self.collectionView?.scrollToItem(at: lastItemIndex as IndexPath, at: .bottom, animated: false)
                
            })
        }
    }
    
    @objc func handleKeyboardNotificationHide(notification: NSNotification) {
        
        
        if let userInfo = notification.userInfo {
            
            let keyboardDuration = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as AnyObject).doubleValue
            
            bottomConstraint?.constant = 0
            
            UIView.animate(withDuration: keyboardDuration!, animations: {
                self.view.layoutIfNeeded()
            }, completion: {(completed) in
                self.collectionView?.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 40, right: 0)
                let lastItemIndex = NSIndexPath(item: self.messages.count - 1, section: 0)
                self.collectionView?.scrollToItem(at: lastItemIndex as IndexPath, at: .bottom, animated: false)
            })
        }
    }
}
