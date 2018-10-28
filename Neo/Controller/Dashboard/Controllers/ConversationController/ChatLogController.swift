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
    
    public let cellId = "cellId"
    public let dateId = "dateId"
    
    var timer: Timer?
    var messages = [Message]()
    var convId: Int = 0
    var circleId: Int = 0
    let messageDay:[Int: String] = [1:"Sun", 2:"Mon", 3:"Tue", 4:"Wed", 5:"Thu", 6:"Fri", 7:"Sat"]
    var bottomConstraint: NSLayoutConstraint?
    var mediaCellCount = 0
    var mediaDownloaded = [Int: UIImage]()
    
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
    
    private func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        var selectedImageFromPicker: UIImage?
        if let image = info["UIImagePickerControllerEditedImage"] as? UIImage {
            selectedImageFromPicker = image
        } else if let originalImage = info["UIImagePickerControllerOriginalImage"] as? UIImage {
            selectedImageFromPicker = originalImage
        }
        
        if let selectedImage = selectedImageFromPicker {
            uploadImageToDataBase(image: selectedImage)
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
        self.navigationItem.setRightBarButtonItems([rightAddBarButtonItem], animated: true)
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpUI()
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
    
    func base64Convert(base64String: String?) -> UIImage{
        if (base64String?.isEmpty)! {
            return UIImage()
        }else {
            let temp = base64String?.components(separatedBy: ",")
            let dataDecoded : Data = Data(base64Encoded: temp![1], options: .ignoreUnknownCharacters)!
            let decodedimage = UIImage(data: dataDecoded)
            return decodedimage!
        }
    }
    
    public func retrieveMedia(media: JSON, completion: @escaping(UIImage) -> ()) {
        
        ApiManager.performAlamofireRequest(url: ApiRoute.ROUTE_DOWNLOAD_MEDIA, param: ["token": User.sharedInstance.getParameter(parameter: "token"), "media_id": media["media"]["id"].intValue]).done { (value) in
                completion(self.base64Convert(base64String: JSON(value)["data"].stringValue))
            }.catch { (error) in
                print("[ERROR RETRIEVE MEDIA (\(error)) ]")
        }
    }
    
    internal func handleMessage(message: JSON) {
        let msg = Message()
        
        msg.text = message["message"]["content"].stringValue
        msg.date = self.returnDateFromString(text: message["time"].stringValue)
        msg.image = nil
        
        if message["sender"]["email"].stringValue == User.sharedInstance.getEmail() {
            msg.isSender = true
        } else {
            msg.isSender = false
        }
        self.messages.append(msg)
    }

    override func viewWillDisappear(_ animated: Bool) {
        if timer != nil {
            timer?.invalidate()
        }
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
    
    private func displayMedia(image: UIImage) {
        
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
    
    internal func loadingMediaIntoConv(data: JSON, index: Int) {
        
        ApiManager.performAlamofireRequest(url: ApiRoute.ROUTE_MEDIA_INFO, param: ["token": User.sharedInstance.getParameter(parameter: "token"), "message_id": data["id"].intValue]).done({ (value) in
            let json = JSON(value)

            json.forEach({ (name, data) in
                if name.isEqualToString(find: "content") {
                    data.forEach({ (name, data) in
                        if data["media"]["uploaded"].boolValue == true {
                            self.retrieveMedia(media: data, completion: { (image) in
                                self.mediaDownloaded[index] = image
                                self.displayMedia(image: image)
                            })
                        }
                    })
                }
            })
        }).catch({ (error) in
            print("ERROR = \(error)")
        })
        
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
