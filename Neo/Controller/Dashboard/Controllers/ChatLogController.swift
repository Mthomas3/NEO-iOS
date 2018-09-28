//
//  ChatLogController.swift
//  Neo
//
//  Created by Thomas Martins on 11/06/2018.
//  Copyright © 2018 Neo. All rights reserved.
//

import UIKit
import SocketIO

struct TokenData : SocketData {
    let token: String
    
    func socketRepresentation() -> SocketData {
        return ["token": token]
    }
}

struct MessageData : SocketData {
    let text_message: String
    let conversation_id: Int
    
    func socketRepresentation() -> SocketData {
        return ["text_message": text_message, "conversation_id": conversation_id]
    }
}

struct JoinConversation : SocketData {
    let conversation_id: Int
    
    func socketRepresentation() -> SocketData {
        return ["conversation_id": conversation_id]
    }
}

class ChatLogController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    private let cellId = "cellId"
    private let dateId = "dateId"
    
    var timer: Timer?
    
    /*var friend: Friend? {
        didSet {
            navigationItem.title = frien d?.name
            
            messages = friend?.messages?.allObjects as? [Message]
            
            messages = messages?.sort({$0.date!.compare($1.date!) == .OrderedAscending})
        }
    }*/
    
    var messages = [Message]()
    
    var convId: Int = 0
    var circleId: Int = 0
    
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
    
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        //tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        hideKeyboardWhenTappedAround()
        
        tabBarController?.tabBar.isHidden = true
        
        collectionView?.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 40, right: 0)
        //        collectionView?.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: 50, right: 0)
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
        
        let rightAddBarButtonItem:UIBarButtonItem = UIBarButtonItem(title: "Ajouter", style: UIBarButtonItemStyle.plain, target: self, action: #selector(addToConv))
        
        self.navigationItem.setRightBarButtonItems([rightAddBarButtonItem], animated: true)
    }
    
    @objc func addToConv() {
        let newViewController = UIStoryboard(name: "Dashboard", bundle: nil).instantiateViewController(withIdentifier: "AddMemberStoryboard") as! AddMemberToConvController
        
        self.navigationController?.pushViewController(newViewController, animated: true)
        //self.present(newViewController, animated: true, completion: nil)
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
        switch weekDay {
        case 1:
            return "Sun"
        case 2:
            return "Mon"
        case 3:
            return "Tue"
        case 4:
            return "Wed"
        case 5:
            return "Thu"
        case 6:
            return "Fri"
        case 7:
            return "Sat"
        default:
            return "Nada"
        }
    }
    
    func getDayOfWeek(_ todayDate: Date) -> Int {
        let myCalendar = Calendar(identifier: .gregorian)
        let weekDay = myCalendar.component(.weekday, from: todayDate)
        return weekDay
    }
    
    deinit {
        SocketManager.sharedInstance.getManager().defaultSocket.emit("leave_conversation", JoinConversation(conversation_id: convId))
    }
    
    func launchTimer() {
        loadConv()
        //timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(loadConv), userInfo: nil, repeats: true)
        
        //Socket emit "join conversation"
        SocketManager.sharedInstance.getManager().defaultSocket.emit("join_conversation", JoinConversation(conversation_id: convId))
        //Socket on message
        SocketManager.sharedInstance.getManager().defaultSocket.on("message") { data, ack in
/*[{
 "conversation_id" = 3;
 "media_list" =     (
 );
 message =     {
 content = "ceci est un essai";
 id = 19;
 "link_id" = 4;
 medias = 0;
 read = "<null>";
 sent = "2018-09-11T22:28:32.137745";
 };
 sender =     {
 birthday = "1111-11-11T00:00:00";
 created = "2018-09-11T22:28:32.050500";
 email = "nico@gmail.com";
 "first_name" = Nicolas;
 id = 6;
 isOnline = 1;
 "last_name" = Gascon;
 type = DEFAULT;
 updated = "2018-09-11T22:28:32.050535";
 };
 status = done;
 time = "2018-09-11T22:28:32.137745";
 }]*/
            for json in data {
                let msg = Message()
                msg.text = (((json as! [String: Any])["message"] as! [String: Any])["content"] as! String)
                
                msg.date = self.returnDateFromString(text: ((json as! [String: Any])["time"] as! String))
                
                if ((json as! [String: Any])["sender"] as! [String: Any])["email"] as! String == User.sharedInstance.getEmail() {
                    msg.isSender = true
                } else {
                    msg.isSender = false
                }
                self.messages.append(msg)
            }
            
            self.collectionView?.reloadData()
            let lastItemIndex = NSIndexPath(item: self.messages.count - 1, section: 0)
            self.collectionView?.scrollToItem(at: lastItemIndex as IndexPath, at: .bottom, animated: true)
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
    
    @objc func loadConv() {
        ApiManager.performAlamofireRequest(url: ApiRoute.ROUTE_CONVERSATION_INFO, param: ["token": User.sharedInstance.getParameter(parameter: "token"), "conversation_id": convId]).done {
            jsonData in
                let content = jsonData["content"] as? [String: Any]
                let messages = content!["messages"] as? [[String: Any]]
            
                if content == nil {
                    return
                }
            
                let button =  UIButton(type: .custom)
                button.frame = CGRect(x: 0, y: 0, width: 150, height: 40)
                button.backgroundColor = UIColor(white: 1, alpha: 0.0)
                button.setTitle((content!["circle"] as? [String: Any])!["name"] as? String, for: .normal)
                button.setTitleColor(UIColor.black, for: .normal)
                button.addTarget(self, action: #selector(self.clickOnTitle), for: .touchUpInside)
                self.navigationItem.titleView = button
            
                self.messages.removeAll()
                for idx in 0...(messages?.count)! - 1 {
                    let message = messages![idx]
                    let msg = Message()
                    
                    if message["content"] as? String == nil {
                        continue
                    }
                    
                    msg.text = message["content"] as! String
                    //msg.date = Date()//message["sent"] as! Date

                    msg.date = self.returnDateFromString(text: message["sent"] as! String)
                    //print(message["sent"])
                    //print(msg.date)
                    
                    if let linkId = message["link_id"] as? Int {
                        let links = content!["links"] as! [[String:Any]]
                        
                        if (self.findLinkId(links: links, linkId: linkId)!["user_id"] as! [String: Any])["email"] as! String == User.sharedInstance.getEmail() {
                            msg.isSender = true
                        } else {
                            msg.isSender = false
                        }
                    } else {
                        msg.isSender = false
                    }
                    
                    //Check date diff
                    if self.messages.count > 0 {
                        let prevDate = self.messages[self.messages.count - 1].date
                        let components = Calendar.current.dateComponents([.year, .month, .day, .hour], from: prevDate!, to: msg.date!)
                        let dateFormatter = DateFormatter()
                        
                        if components.year! >= 1 {
                            let dateMessage = Message()
                            dateFormatter.dateFormat = "yyyy"
                            dateMessage.text = "/*/*" + dateFormatter.string(from: msg.date!) + "*/*/"
                            self.messages.append(dateMessage)
                        } else if components.month! >= 1 {
                            let dateMessage = Message()
                            dateFormatter.dateFormat = "MMM"
                            dateMessage.text = "/*/*" + dateFormatter.string(from: msg.date!) + "*/*/"
                            self.messages.append(dateMessage)
                        } else if components.day! >= 1 {
                            let dateMessage = Message()
                            dateFormatter.dateFormat = "ddd"
                            dateMessage.text = "/*/*" + dateFormatter.string(from: msg.date!) + "*/*/"
                            self.messages.append(dateMessage)
                        } else if components.hour! >= 1 {
                            let dateMessage = Message()
                            dateFormatter.dateFormat = "HH:mm"
                            dateMessage.text = "/*/*" + dateFormatter.string(from: msg.date!) + "*/*/"
                            self.messages.append(dateMessage)
                        }
                    } else {
                        let prevDate = msg.date!
                        let components = Calendar.current.dateComponents([.year, .month, .day, .hour], from: prevDate, to: Date())
                        let dateFormatter = DateFormatter()
                        
                        if components.year! >= 1 {
                            let dateMessage = Message()
                            dateFormatter.dateFormat = "yyyy"
                            dateMessage.text = "/*/*" + dateFormatter.string(from: msg.date!) + "*/*/"
                            self.messages.append(dateMessage)
                        } else if components.month! >= 1 {
                            let dateMessage = Message()
                            dateFormatter.dateFormat = "MMM"
                            dateMessage.text = "/*/*" + dateFormatter.string(from: msg.date!) + "*/*/"
                            self.messages.append(dateMessage)
                        } else if components.day! >= 1 {
                            let dateMessage = Message()
                            dateMessage.text = "/*/*" + self.loadDayName(weekDay: self.getDayOfWeek(msg.date!)) + "*/*/"
                            self.messages.append(dateMessage)
                        } else {
                            let dateMessage = Message()
                            dateFormatter.dateFormat = "HH:mm"
                            dateMessage.text = "/*/*" + dateFormatter.string(from: msg.date!) + "*/*/"
                            self.messages.append(dateMessage)
                        }
                    }
                    
                    self.messages.append(msg)
                }
                self.collectionView?.reloadData()
                let lastItemIndex = NSIndexPath(item: self.messages.count - 1, section: 0)
                self.collectionView?.scrollToItem(at: lastItemIndex as IndexPath, at: .bottom, animated: false)
                //To test
                //Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.self.goAtBottom), userInfo: nil, repeats: false)
            }.catch { _ in
                print("Errrrr") //lzzaaaaaa
                //HandleErrors.displayError(message: "The email is invalid", controller: self)
        }
    }
    
    @objc func clickOnTitle() {
        let newViewController = UIStoryboard(name: "Dashboard", bundle: nil).instantiateViewController(withIdentifier: "convSettings") as! ConvConfigurationSettings
        
        self.navigationController?.pushViewController(newViewController, animated: true)
        //self.present(newViewController, animated: true, completion: nil)
        newViewController.convId = convId
        newViewController.loadSettings()
    }
    
    func goAtBottom() {
            /*let item = messages.count - 1
            let insertionIndexPath = IndexPath(item: item, section: 0)
        
            collectionView?.insertItems(at: [insertionIndexPath])
            collectionView?.scrollToItem(at: insertionIndexPath, at: .bottom, animated: true)*/
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
        /*ApiManager.performAlamofireRequest(url: ApiRoute.ROUTE_MESSAGE_SEND, param: ["token": User.sharedInstance.getParameter(parameter: "token"), "conversation_id": convId, "text_message": inputTextField.text]).done {
            jsonData in
            
        }.catch { _ in
                HandleErrors.displayError(message: "Votre message n'a pas pu être envoyé.", controller: self)
        }*/
        
        inputTextField.text = nil
    }
    
    @objc func handleKeyboardNotification(notification: NSNotification) {
        if let userInfo = notification.userInfo {
            
            print("Ouiii")
            
            let keyboardFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as AnyObject).cgRectValue
            let keyboardDuration = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as AnyObject).doubleValue
            
            bottomConstraint?.constant = -keyboardFrame!.height
            
            print(-keyboardFrame!.height)
            
            UIView.animate(withDuration: keyboardDuration!, animations: {
                
                self.view.layoutIfNeeded()
                
            }, completion: { (completed) in
                
                //Scroll down
                self.collectionView?.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 80, right: 0)
                let lastItemIndex = NSIndexPath(item: self.messages.count - 1, section: 0)
                self.collectionView?.scrollToItem(at: lastItemIndex as IndexPath, at: .bottom, animated: false)
                
            })
        }
    }
    
    @objc func handleKeyboardNotificationHide(notification: NSNotification) {
        
        print("Ahhhhh")
        
        if let userInfo = notification.userInfo {
            
            print("Ohhhh")
            
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
