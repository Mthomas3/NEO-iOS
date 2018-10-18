//
//  ChatLogController.swift
//  Neo
//
//  Created by Nicolas Gascon on 11/04/2018.
//  Copyright © 2018 Neo. All rights reserved.
//

import UIKit
import SocketIO
import SwiftyJSON


class ChatLogController: UICollectionViewController, UICollectionViewDelegateFlowLayout,
    UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    private let cellId = "cellId"
    private let dateId = "dateId"
    
    var timer: Timer?
    var messages = [Message]()
    var convId: Int = 0
    var circleId: Int = 0
    let messageDay:[Int: String] = [1:"Sun", 2:"Mon", 3:"Tue", 4:"Wed", 5:"Thu", 6:"Fri", 7:"Sat"]
    
    var bottomConstraint: NSLayoutConstraint?
    
    let messageInputContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white
        return view
    }()
    
    let inputTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Entrer un message..."
        return textField
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
    
    @objc func addMediaConversation() {
        
        let imagePickerController = UIImagePickerController()
        imagePickerController.allowsEditing = true
        imagePickerController.delegate = self
        
        present(imagePickerController, animated: true, completion: nil)
        
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
    
    private func uploadImageToDataBase(image: UIImage) {
        
        let imageName = NSUUID().uuidString
        print("name = \(imageName)")
    
        let uploadImage = UIImageJPEGRepresentation(image, 0.2)
        //print("the image \(uploadImage) && param = \(image)")
        
        print("upload to database!!!")
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    private func setUpNavigationBar() {
        
        let rightAddBarButtonItem:UIBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.done, target: self, action: #selector(self.addMediaConversation))
        
        rightAddBarButtonItem.setTitleTextAttributes([NSAttributedStringKey.font: UIFont(name: "Font Awesome 5 Pro", size: 17)!], for: .normal)
        
        let rightAddBarButtonItemAdd:UIBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.done, target: self, action: #selector(self.addMediaConversation))
        
        rightAddBarButtonItemAdd.setTitleTextAttributes([NSAttributedStringKey.font: UIFont(name: "Font Awesome 5 Pro", size: 17)!], for: .normal)
        
        self.navigationItem.setRightBarButtonItems([rightAddBarButtonItem, rightAddBarButtonItemAdd], animated: true)
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
    
    func findLinkId(links: [[String: Any]], linkId: Int) -> [String: Any]? {
        for idx in 0...links.count - 1 {
            if links[idx]["id"] as! Int == linkId {
                return links[idx]
            }
        }
        
        return nil
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
    
    private func handleMedia(media: JSON) {
        
        ApiManager.performAlamofireRequest(url: ApiRoute.ROUTE_DOWNLOAD_MEDIA, param: ["token": User.sharedInstance.getParameter(parameter: "token"), "media_id": media["media"]["id"].intValue]).done { (value) in

            var str = JSON(value)["data"].stringValue
            let image = self.base64Convert(base64String: str)
            
//           let imageview = UIImageView(image: image)
//            self.view.addSubview(imageview)
            
            let imageMessage = Message()
            imageMessage.image = image
            imageMessage.text = "[DEV: PICTURE!]"
            self.messages.append(imageMessage)
            self.collectionView?.reloadData()
        
            
            }.catch {error in print("error -> \(error)")}
    }
    
    private func handleMessage(message: JSON) {
        let msg = Message()
        
        msg.text = message["message"]["content"].stringValue
        msg.date = self.returnDateFromString(text: message["time"].stringValue)
        
        if message["sender"]["email"].stringValue == User.sharedInstance.getEmail() {
            msg.isSender = true
        } else {
            msg.isSender = false
        }
        self.messages.append(msg)
    }
    
    func launchTimer() {
        loadConv()
        SocketManager.sharedInstance.getManager().defaultSocket.emit("join_conversation", JoinConversation(conversation_id: convId))
        SocketManager.sharedInstance.getManager().defaultSocket.on("message") { data, ack in
            
            data.forEach({ (item) in
                let data = JSON(item)
                
                if data["message"]["medias"].boolValue == true {
                    if (data["status"].stringValue).isEqualToString(find: "done"){
                        self.handleMedia(media: data)
                    }
                    
                } else {
                    self.handleMessage(message: data)
                }
            })
            self.slideOnLastMessage()
        }

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
    
    private func createButtonConversation(nameConversation: String) {
        let button =  UIButton(type: .custom)
        button.frame = CGRect(x: 0, y: 0, width: 150, height: 40)
        button.backgroundColor = UIColor(white: 1, alpha: 0.0)
        button.setTitle(nameConversation, for: .normal)
        button.setTitleColor(UIColor.black, for: .normal)
        button.addTarget(self, action: #selector(self.clickOnTitle), for: .touchUpInside)
        self.navigationItem.titleView = button
    }
    
    private func slideOnLastMessage() {
        self.collectionView?.reloadData()
        let lastItemIndex = NSIndexPath(item: self.messages.count - 1, section: 0)
        self.collectionView?.scrollToItem(at: lastItemIndex as IndexPath, at: .bottom, animated: false)
    }
    
    private func detectSenderMessage(link_id: Int, links: JSON) -> Bool{
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
    
    private func loadConv() {
        ApiManager.performAlamofireRequest(url: ApiRoute.ROUTE_CONVERSATION_INFO, param: ["token": User.sharedInstance.getParameter(parameter: "token"), "conversation_id": convId]).done {
            jsonData in
            
            let content = JSON(jsonData)["content"]
            let messages = content["messages"]
            self.createButtonConversation(nameConversation: content["circle"]["name"].stringValue)
            self.messages.removeAll()

            messages.forEach({ (item, data) in
                let newMessage = Message()
                
                if data["medias"].boolValue == true {
                    newMessage.text = "[DEV: PICTURE]"
                    
                } else {
                    newMessage.text = data["content"].stringValue
                    newMessage.date = self.returnDateFromString(text: data["sent"].stringValue)
                    newMessage.isSender = self.detectSenderMessage(link_id: data["link_id"].intValue, links: content["links"])
                }
                
                self.messages.append(newMessage)
                self.slideOnLastMessage()
            })
            }.catch { error in
                print("[Error on loadConv: (\(error))]")
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
        messageInputContainerView.addSubview(topBorderView)
        
        messageInputContainerView.addConstraintsWithFormat(format: "H:|-8-[v0][v1(120)]|", views: inputTextField, sendButton)
        
        messageInputContainerView.addConstraintsWithFormat(format: "V:|[v0]|", views: inputTextField)
        messageInputContainerView.addConstraintsWithFormat(format: "V:|[v0]|", views: sendButton)
        
        messageInputContainerView.addConstraintsWithFormat(format: "H:|[v0]|", views: topBorderView)
        messageInputContainerView.addConstraintsWithFormat(format: "V:|[v0(0.5)]", views: topBorderView)
    }
    
    @objc func handleSend() {
        SocketManager.sharedInstance.getManager().defaultSocket.emit("message", MessageData(text_message: inputTextField.text!, conversation_id: convId))
        
        inputTextField.text = nil
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
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath as IndexPath) as! ChatLogMessageCell
        
        if messages[indexPath.item].text!.isEqualToString(find: "[DEV: PICTURE!]") {

        
            cell.messageImageView.image = messages[indexPath.item].image
            cell.profileImageView.image = messages[indexPath.item].image
            cell.messageImageView.isHidden = false
            cell.profileImageView.isHidden = false
            
            print("handling picture here ...***")

            return cell
        }
//    print("IS THERE ANYTHING HERE???")
        
        if messages[indexPath.item].text!.count > 8 && messages[indexPath.item].text![0] == "/" && messages[indexPath.item].text![1] == "*" && messages[indexPath.item].text![2] == "/" && messages[indexPath.item].text![3] == "*" && messages[indexPath.item].text![messages[indexPath.item].text!.count - 1] == "/" && messages[indexPath.item].text![messages[indexPath.item].text!.count - 2] == "*" && messages[indexPath.item].text![messages[indexPath.item].text!.count - 3] == "/"  && messages[indexPath.item].text![messages[indexPath.item].text!.count - 4] == "*"   {
            
            let txt = messages[indexPath.item].text![4..<messages[indexPath.item].text!.count - 4]
            let cellDate = collectionView.dequeueReusableCell(withReuseIdentifier: dateId, for: indexPath as IndexPath) as! ChatLogDateCell
            
            cellDate.messageTextView.frame = CGRect(x: 165, y: 0, width: 100, height: 20)
            
            cellDate.leftLine.frame = CGRect(x: 12, y: 10, width: 150, height: 2)
            
            cellDate.rightLine.frame = CGRect(x: 230, y: 10, width: 130, height: 2)
            
            cellDate.messageTextView.textColor = UIColor.white
            
            cellDate.leftLine.backgroundColor = UIColor.lightGray
            
            cellDate.rightLine.backgroundColor = UIColor.lightGray
            
            cellDate.messageTextView.text = String(txt)
            cellDate.messageTextView.textColor = UIColor.lightGray
            cellDate.messageTextView.font?.withSize(3)
            
            
            return cellDate
            
        } else {
            
            do {
                if indexPath.item >= messages.count {
                    cell.messageTextView.text = ""
                } else {
                    cell.messageTextView.text = messages[indexPath.item].text
                }
                let profileImageName = "Logo-png"
                
                if let messageText = messages[indexPath.item].text {
                    let message = messages[indexPath.item]
                    cell.profileImageView.image = UIImage(named: profileImageName)
                    
                    let size = CGSize(width: 250, height: 1000)
                    let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
                    let estimatedFrame = NSString(string: messageText).boundingRect(with: size, options: options, attributes: [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 18)], context: nil)
                    
                    if !message.isSender {
                        cell.messageTextView.frame = CGRect(x: 48 + 8, y: 0, width: estimatedFrame.width + 16, height: estimatedFrame.height + 20)
                        
                        cell.textBubbleView.frame = CGRect(x: 48, y: 0, width: estimatedFrame.width + 16 + 8, height: estimatedFrame.height + 20)
                        
                        cell.textBubbleView.backgroundColor = UIColor(white: 0.95, alpha: 1)
                        cell.messageTextView.textColor = UIColor.black
                        
                        cell.profileImageView.isHidden = false;
                    } else {
                        cell.messageTextView.frame = CGRect(x: view.frame.width - estimatedFrame.width - 16 - 16, y: 0, width: estimatedFrame.width + 16, height: estimatedFrame.height + 20)
                        
                        cell.textBubbleView.frame = CGRect(x: view.frame.width - estimatedFrame.width - 16 - 8 - 16, y: 0, width: estimatedFrame.width + 16 + 8, height: estimatedFrame.height + 20)
                        
                        cell.textBubbleView.backgroundColor = UIColor(red: 0, green: 137/255, blue: 249/255, alpha: 1)
                        cell.messageTextView.textColor = UIColor.white
                        
                        cell.profileImageView.isHidden = true;
                        
                        return cell
                    }
                }
            } catch {
                
            }
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if let messageText = messages[indexPath.item].text {
            let size = CGSize(width: 250, height: 1000)
            let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
            let estimatedFrame = NSString(string: messageText).boundingRect(with: size, options: options, attributes: [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 18)], context: nil)
            return CGSize(width: view.frame.width, height: estimatedFrame.height + 20)
        }
        return CGSize(width: view.frame.width, height: 100)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsetsMake(8, 0, 0, 0)
    }
    
}

class ChatLogMessageCell: BaseCell {
    
    let messageTextView: UITextView = {
        let textView = UITextView()
        textView.font = UIFont.systemFont(ofSize: 18)
        textView.text = "Sample message"
        textView.backgroundColor = UIColor.clear
        textView.isEditable = false
        return textView
    }()
    
    
    let messageImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = UIColor.white
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 15
        imageView.layer.masksToBounds = true
        return imageView
    }()
    
    
    let textBubbleView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(white: 0.95, alpha: 1)
        view.layer.cornerRadius = 15
        view.layer.masksToBounds = true
        return view
    }()
    
    let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = UIColor.white
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 15
        imageView.layer.masksToBounds = true
        return imageView
    }()
    
    override func setupView() {
        super.setupView()
        
        backgroundColor = UIColor.white
        
        addSubview(textBubbleView)
        addSubview(messageTextView)
        
        addSubview(messageImageView)
        
        messageImageView.backgroundColor = UIColor.black
        
       /* messageImageView.leftAnchor.constraint(equalTo: textBubbleView.leftAnchor).isActive = true
        messageImageView.topAnchor.constraint(equalTo: textBubbleView.topAnchor).isActive = true
        messageImageView.widthAnchor.constraint(equalTo: textBubbleView.widthAnchor).isActive = true
        messageImageView.heightAnchor.constraint(equalTo: textBubbleView.heightAnchor).isActive = true*/
        
       // addSubview(messageImageView)
        
        addSubview(profileImageView)
        addConstraintsWithFormat(format: "H:|-8-[v0(30)]", views: profileImageView)
        addConstraintsWithFormat(format: "V:[v0(30)]|", views: profileImageView)
        profileImageView.backgroundColor = UIColor.white
    }
}

class ChatLogDateCell: BaseCell {
    
    let messageTextView: UITextView = {
        let textView = UITextView()
        textView.font = UIFont.systemFont(ofSize: 18)
        textView.text = "15:03"
        textView.backgroundColor = UIColor.clear
        return textView
    }()
    
    let messageImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = UIColor.white
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 15
        imageView.layer.masksToBounds = true
        return imageView
    }()
    
    let leftLine: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(white: 0.95, alpha: 1)
        view.layer.cornerRadius = 5
        view.layer.masksToBounds = true
        return view
    }()
    
    //More than a year display year //
    //More than a month display month //
    //More than a day display day //
    //Less than a day display hours //
    
    let rightLine: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(white: 0.95, alpha: 1)
        view.layer.cornerRadius = 5
        view.layer.masksToBounds = true
        return view
    }()
    
    override func setupView() {
        super.setupView()
        
        backgroundColor = UIColor.white
        
        addSubview(leftLine)
        addSubview(messageTextView)
        addSubview(rightLine)
        addSubview(messageImageView)
       // addSubview(messageImageView)
        
        addConstraintsWithFormat(format: "H:|-8-[v0(30)]", views: leftLine)
        addConstraintsWithFormat(format: "V:[v0(30)]|", views: leftLine)
        addConstraintsWithFormat(format: "H:|-8-[v0(30)]", views: messageTextView)
        addConstraintsWithFormat(format: "V:[v0(30)]|", views: messageTextView)
        addConstraintsWithFormat(format: "H:|-8-[v0(30)]", views: rightLine)
        addConstraintsWithFormat(format: "V:[v0(30)]|", views: rightLine)
    }
}

extension String {
    subscript (i: Int) -> Character {
        return self[index(startIndex, offsetBy: i)]
    }
    subscript (bounds: CountableRange<Int>) -> Substring {
        let start = index(startIndex, offsetBy: bounds.lowerBound)
        let end = index(startIndex, offsetBy: bounds.upperBound)
        return self[start ..< end]
    }
    subscript (bounds: CountableClosedRange<Int>) -> Substring {
        let start = index(startIndex, offsetBy: bounds.lowerBound)
        let end = index(startIndex, offsetBy: bounds.upperBound)
        return self[start ... end]
    }
    subscript (bounds: CountablePartialRangeFrom<Int>) -> Substring {
        let start = index(startIndex, offsetBy: bounds.lowerBound)
        let end = index(endIndex, offsetBy: -1)
        return self[start ... end]
    }
    subscript (bounds: PartialRangeThrough<Int>) -> Substring {
        let end = index(startIndex, offsetBy: bounds.upperBound)
        return self[startIndex ... end]
    }
    subscript (bounds: PartialRangeUpTo<Int>) -> Substring {
        let end = index(startIndex, offsetBy: bounds.upperBound)
        return self[startIndex ..< end]
    }
}
extension Substring {
    subscript (i: Int) -> Character {
        return self[index(startIndex, offsetBy: i)]
    }
    subscript (bounds: CountableRange<Int>) -> Substring {
        let start = index(startIndex, offsetBy: bounds.lowerBound)
        let end = index(startIndex, offsetBy: bounds.upperBound)
        return self[start ..< end]
    }
    subscript (bounds: CountableClosedRange<Int>) -> Substring {
        let start = index(startIndex, offsetBy: bounds.lowerBound)
        let end = index(startIndex, offsetBy: bounds.upperBound)
        return self[start ... end]
    }
    subscript (bounds: CountablePartialRangeFrom<Int>) -> Substring {
        let start = index(startIndex, offsetBy: bounds.lowerBound)
        let end = index(endIndex, offsetBy: -1)
        return self[start ... end]
    }
    subscript (bounds: PartialRangeThrough<Int>) -> Substring {
        let end = index(startIndex, offsetBy: bounds.upperBound)
        return self[startIndex ... end]
    }
    subscript (bounds: PartialRangeUpTo<Int>) -> Substring {
        let end = index(startIndex, offsetBy: bounds.upperBound)
        return self[startIndex ..< end]
    }
}

