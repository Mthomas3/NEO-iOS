//
//  FriendsControllerCollectionViewController.swift
//  Neo
//
//  Created by Nicolas Gascon on 11/04/2018.
//  Copyright © 2018 Neo. All rights reserved.
//

import UIKit
import SocketIO

struct JoinCircle : SocketData {
    let circle_id: Int
    
    func socketRepresentation() -> SocketData {
        return ["circle_id": circle_id]
    }
}

class FriendsControllerCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    private let cellId = "cellId"
    
    var messages = [Circle]()
    var circleids = [Int]()
    
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
    
    deinit {
        //Leave circles
        for id in self.circleids {
            SocketManager.sharedInstance.getManager().defaultSocket.emit("leave_circle", JoinCircle(circle_id: id))
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        messages.removeAll()
        
        tabBarController?.tabBar.isHidden = false
        
        ApiManager.performAlamofireRequest(url: ApiRoute.ROUTE_ACCOUNT_INFO, param: ["token": User.sharedInstance.getParameter(parameter: "token")]).done {
            accInfoJson in
            let ctcAcc = accInfoJson["content"] as? [String: Any]
            let circlesArr = ctcAcc!["circles"] as? [[String: Any]]
            
            if circlesArr?.count == 0 {
                return
            }
            for idx in 0...(circlesArr?.count)! - 1 {
                let circle = circlesArr![idx]
                
                //Join circle
            SocketManager.sharedInstance.getManager().defaultSocket.emit("join_circle", JoinCircle(circle_id: (circle["circle"] as! [String:Any])["id"] as! Int))
                
                self.circleids.append((circle["circle"] as! [String:Any])["id"] as! Int)
                
                ApiManager.performAlamofireRequest(url: ApiRoute.ROUTE_CONVERSATION_LIST, param: ["token": User.sharedInstance.getParameter(parameter: "token"), "circle_id": (circle["circle"] as! [String:Any])["id"] as! Int]).done {
                    jsonData in
                    if let content = jsonData["content"] as? [[String:Any]] {
                        for a in content {
                            let circle = Circle()
                            circle.date = self.returnDateFromString(text: a["updated"] as! String)
                            circle.name = a["name"] as? String
                            circle.id = a["id"] as? Int
                            self.messages.append(circle)
                        }
                        self.collectionView?.reloadData()
                    }
                }.catch { _ in
                    print("Errrrr") //lzzaaaaaa
                    //HandleErrors.displayError(message: "The email is invalid", controller: self)
                }
            }
        }.catch { _ in
            print("Errrrr") //lzzaaaaaa
            //HandleErrors.displayError(message: "The email is invalid", controller: self)
        }
    }
    
    @IBAction func unwindToChatConversation(segue:UIStoryboardSegue) { }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        /*let msg = Circle()
        msg.name = "Name"
        msg.date = Date()
        messages.append(msg)
        messages.append(msg)
        messages.append(msg)*/
        
        SocketManager.sharedInstance.connect()
        
        navigationItem.title = "Récents"

        collectionView?.backgroundColor = UIColor.white
        collectionView?.alwaysBounceVertical = true
        
        self.collectionView!.register(MessageCell.self, forCellWithReuseIdentifier: cellId)
        
        let rightAddBarButtonItem:UIBarButtonItem = UIBarButtonItem(title: "Créer", style: UIBarButtonItemStyle.plain, target: self, action: #selector(addConv))
        
        self.navigationItem.setRightBarButtonItems([rightAddBarButtonItem], animated: true)
    }
    
    @objc func addConv() {
        self.performSegue(withIdentifier: "createConv", sender: self)
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! MessageCell
        
        let message = messages[indexPath.item]
            cell.message = message
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width, height: 100)
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let layout = UICollectionViewFlowLayout()
        //let controller = CircleConcersationController(collectionViewLayout: layout)
        let controller = ChatLogController(collectionViewLayout: layout)
        
        
        //controller.friend = messages?[indexPath.item].friend
        
        
        
        
        navigationController?.pushViewController(controller, animated: true)
        
        if indexPath.item < self.messages.count {
            controller.convId = self.messages[indexPath.item].id!
            controller.loadConversationOnSocket()
        }
    }
}

class MessageCell: BaseCell {
    
    let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 34
        imageView.layer.masksToBounds = true
        return imageView
    }()
    
    let dividerLineView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(white: 0.5, alpha: 0.5)
        return view
    }()
    
    let nameLabel: UILabel = {
        let label = UILabel()
        label.text = "Nicolas Gascon"
        label.font = UIFont.systemFont(ofSize: 18)
        return label
    }()
    
    let messageLabel: UILabel = {
        let label = UILabel()
        label.text = "Your friend's message and something else..."
        label.textColor = UIColor.darkGray
        label.font = UIFont.systemFont(ofSize: 14)
        return label
    }()
    
    let timeLabel: UILabel = {
        let label = UILabel()
        label.text = "12:05 pm"
        label.font = UIFont.systemFont(ofSize: 16)
        label.textAlignment = .right
        return label
    }()
    
    let hasReadImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 10
        imageView.layer.masksToBounds = true
        return imageView
    }()
    
    override var isHighlighted: Bool {
        didSet {
            backgroundColor = isHighlighted ? UIColor(red: 0, green: 134/255, blue: 249/255, alpha: 1) : UIColor.white
            nameLabel.textColor = isHighlighted ? UIColor.white : UIColor.black
            timeLabel.textColor = isHighlighted ? UIColor.white : UIColor.black
            messageLabel.textColor = isHighlighted ? UIColor.white : UIColor.black
        }
    }
    
    var message: Circle? {
        didSet {
            //nameLabel.text = message?.friend?.name
            
            //if let profileImageName = message?.friend?.profileImageName {
                //profileImageView.image = UIImage(named: profileImageName);
                //hasReadImageView.image = UIImage(named: profileImageName);
            //}
            
            //messageLabel.text = message?.text
            nameLabel.text = (message?.name!)!
            messageLabel.isHidden = true
            
            if let date = message?.date {
                
                print(date)
                
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "h:mm a"
                
                let elapsedTimeInSeconds = NSDate().timeIntervalSince(date as Date)
                
                let secondInDays: TimeInterval = 60 * 60 * 24
                
                if elapsedTimeInSeconds > 7 * secondInDays {
                    dateFormatter.dateFormat = "MM/dd/yy"
                } else if elapsedTimeInSeconds > secondInDays {
                    dateFormatter.dateFormat = "EEE"
                }
                
                timeLabel.text = dateFormatter.string(from: date as Date)
                
            }
            
        }
    }
    
    override func setupView() {
        print("somewhere here")
        /*let addButton = UIBarButtonItem(title: "Add", style: UIBarButtonItemStyle.done, target: self, action: #selector(addCircle))
        
        navigationItem.rightBarButtonItem = addButton*/
        
        addSubview(profileImageView)
        addSubview(dividerLineView)
        
        setupContainerView()
        
        profileImageView.image = UIImage(named: "Logo-png")
        hasReadImageView.image = UIImage(named: "Logo-png")

        addConstraintsWithFormat(format: "H:|-12-[v0(68)]", views: profileImageView)
        addConstraintsWithFormat(format: "V:[v0(68)]", views: profileImageView)
        
        addConstraint(NSLayoutConstraint(item: profileImageView, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 0))
        
        addConstraintsWithFormat(format: "H:|-82-[v0]-82-|", views: dividerLineView)
        addConstraintsWithFormat(format: "V:[v0(1)]|", views: dividerLineView)
    }
    
    @objc private func addCircle() {
        
    }
    
    private func setupContainerView() {
        let containerView = UIView()
        addSubview(containerView)
        
        addConstraintsWithFormat(format: "H:|-90-[v0]|", views: containerView)
        addConstraintsWithFormat(format: "V:[v0(50)]", views: containerView)
        addConstraint(NSLayoutConstraint(item: containerView, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 0))
        
        containerView.addSubview(nameLabel)
        containerView.addSubview(messageLabel)
        containerView.addSubview(timeLabel)
        containerView.addSubview(hasReadImageView)
        
        containerView.addConstraintsWithFormat(format: "H:|[v0][v1(80)]-12-|", views: nameLabel, timeLabel)
        
        containerView.addConstraintsWithFormat(format: "V:|[v0][v1(24)]|", views: nameLabel, messageLabel)
        
        containerView.addConstraintsWithFormat(format: "H:|[v0]-8-[v1(20)]-12-|", views: messageLabel, hasReadImageView)
        
        containerView.addConstraintsWithFormat(format: "V:|[v0(24)]", views: timeLabel)
        
        containerView.addConstraintsWithFormat(format: "V:[v0(20)]|", views: hasReadImageView)
    }
}

class BaseCell: UICollectionViewCell {
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupView() {
        backgroundColor = UIColor.blue
    }
}
