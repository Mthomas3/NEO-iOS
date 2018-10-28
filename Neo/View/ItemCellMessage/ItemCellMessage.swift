//
//  ItemCellMessage.swift
//  Neo
//
//  Created by Thomas Martins on 28/10/2018.
//  Copyright © 2018 Neo. All rights reserved.
//

import UIKit

class ChatLogMessageCell: BaseCell {
    
    let messageTextView: UITextView = {
        let textView = UITextView()
        textView.font = UIFont.systemFont(ofSize: 18)
        textView.isHidden = false
        textView.backgroundColor = UIColor.clear
        textView.isEditable = false
        return textView
    }()
    
    var messageImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = UIColor.clear
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
    
    private func setConstraintMedia() {
        messageImageView.leftAnchor.constraint(equalTo: textBubbleView.leftAnchor).isActive = true
        messageImageView.topAnchor.constraint(equalTo: textBubbleView.topAnchor).isActive = true
        messageImageView.widthAnchor.constraint(equalTo: textBubbleView.widthAnchor).isActive = true
        messageImageView.heightAnchor.constraint(equalTo: textBubbleView.heightAnchor).isActive = true
    }
    
    override func setupView() {
        super.setupView()
        backgroundColor = UIColor.white
        addSubview(textBubbleView)
        addSubview(messageTextView)
        addSubview(profileImageView)
        
        textBubbleView.addSubview(messageImageView)
        
        self.setConstraintMedia()
        
        addConstraintsWithFormat(format: "H:|-8-[v0(30)]", views: profileImageView, messageImageView)
        addConstraintsWithFormat(format: "V:[v0(30)]|", views: profileImageView, messageImageView)
        
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
        imageView.backgroundColor = UIColor.clear
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
        
        addConstraintsWithFormat(format: "H:|-8-[v0(30)]", views: leftLine)
        addConstraintsWithFormat(format: "V:[v0(30)]|", views: leftLine)
        
        addConstraintsWithFormat(format: "H:|-8-[v0(30)]", views: messageTextView)
        addConstraintsWithFormat(format: "V:[v0(30)]|", views: messageTextView)
        
        addConstraintsWithFormat(format: "H:|-8-[v0(30)]", views: messageImageView)
        addConstraintsWithFormat(format: "V:[v0(30)]|", views: messageImageView)
        
        
        addConstraintsWithFormat(format: "H:|-8-[v0(30)]", views: rightLine)
        addConstraintsWithFormat(format: "V:[v0(30)]|", views: rightLine)
    }
}
