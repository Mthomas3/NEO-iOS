//
//  ExtensionCollectionView.swift
//  Neo
//
//  Created by Thomas Martins on 28/10/2018.
//  Copyright © 2018 Neo. All rights reserved.
//

import UIKit


extension ChatLogController:  UICollectionViewDelegateFlowLayout{
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    private func createTemporaryDownloadingCell(indexPath: IndexPath) -> UICollectionViewCell{
        let cell = collectionView!.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath as IndexPath) as! ChatLogMessageCell
        
        cell.textBubbleView.backgroundColor = CommonFunc.hexStringToUIColor(hex: "#CBCBCB")
        cell.messageTextView.isHidden = true
        cell.messageTextView.text = ""
        
        if messages[indexPath.item].isSender {
            cell.textBubbleView.frame = CGRect(x: 160, y: 20, width: 200, height: 250)
            cell.profileImageView.isHidden = true
            return cell
        }
        cell.profileImageView.image = UIImage(named: "Logo-png")
        cell.textBubbleView.frame = CGRect(x: 50, y: 20, width: 200, height:  250)
        cell.profileImageView.isHidden = false
        return cell
    }
    
    private func createCellForMedia(indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView!.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath as IndexPath) as! ChatLogMessageCell
        
        let newImage = UIImageView(frame: CGRect(x: 0, y: 0, width: 200, height: 250))
        newImage.image = messages[indexPath.item].image
        
        if messages[indexPath.item].isSender {
            cell.textBubbleView.frame = CGRect(x: 160, y: 20, width: 200, height: 250)
            cell.profileImageView.isHidden = true
            cell.textBubbleView.addSubview(newImage)
            return cell
        }
        
        cell.textBubbleView.frame = CGRect(x: 50, y: 20, width: 200, height:  250)
        cell.profileImageView.image = UIImage(named: "Logo-png")
        cell.profileImageView.isHidden = false
        cell.textBubbleView.addSubview(newImage)
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath as IndexPath) as! ChatLogMessageCell
        
        if messages[indexPath.item].isMediaLoading != nil && messages[indexPath.item].isMediaLoading == true {
            return self.createTemporaryDownloadingCell(indexPath: indexPath)
        }
        
        if messages[indexPath.item].image != nil {
            return self.createCellForMedia(indexPath: indexPath)
        }
        
        if (messages[indexPath.item].text != nil) {
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
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if messages[indexPath.item].image != nil || messages[indexPath.item].isMediaLoading == true{
            return CGSize(width: view.frame.width, height: 265)
        }
        
        if let messageText = messages[indexPath.item].text {
            let size = CGSize(width: 250, height: 1000)
            let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
            let estimatedFrame = NSString(string: messageText).boundingRect(with: size, options: options, attributes: [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 18)], context: nil)
            return CGSize(width: view.frame.width, height: estimatedFrame.height + 20)
        }
        return CGSize(width: view.frame.width, height: 200)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsetsMake(8, 0, 0, 0)
    }
}
