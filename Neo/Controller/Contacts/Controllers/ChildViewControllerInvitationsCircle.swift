//
//  ChildViewControllerSecond.swift
//  Neo
//
//  Created by Thomas Martins on 12/09/2018.
//  Copyright © 2018 Neo. All rights reserved.
//

import UIKit
import XLPagerTabStrip
import SwiftyJSON

class ChildViewControllerInvitationsCircle: UIViewController, IndicatorInfoProvider, UICollectionViewDataSource {

    public var childNumber: String = ""
    private var dataArray = [ItemCellData]()
    private let estimateWidth = 140.0
    private let cellMarginSize = 3.0

    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        self.collectionView.register(UINib(nibName: "ItemCell", bundle: nil), forCellWithReuseIdentifier: "ItemCell")
        self.setupGridView()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(doubleTapped))
        tap.numberOfTapsRequired = 2
        view.addGestureRecognizer(tap)
        checkInvitationsOnSocket()
    }
    
    private func refreshCollectionView() {
        self.loadCirclesInvitations()
    }
    
    private func checkInvitationsOnSocket () {
        
        SocketManager.sharedInstance.getManager().defaultSocket.on("circle_invite") { invitation, _  in
                let invites = JSON(invitation)
                var circle_inv_id = 0
            
                for item in invites.arrayValue {
                    circle_inv_id = item["circle_invite_id"].intValue
                }
            ServicesCircle.shareInstance.getCirclesInvitesOnSocket(id: circle_inv_id, token:            User.sharedInstance.getTokenParameter(), completion: { (inv) in
                    self.dataArray.append(ItemCellData(Name: inv["circle"]["name"].stringValue, Date: "coucou", Id: inv["circle"]["id"].intValue))
                    self.collectionView.reloadData()
                })
            }
        }
    
    private func performDeclineCircle() {
        
        let indexPath = collectionView.indexPathsForSelectedItems?.first
        let id = self.dataArray[(indexPath?.row)!].Id

        ApiManager.performAlamofireRequest(url: ApiRoute.ROUTE_FRIEND_NO, param: ["token": User.sharedInstance.getParameter(parameter: "token"), "invite_id": id]).done {
            jsonData in
        
            self.performUIAlert(title: "Vous avez refusez l'invitation", message: nil, actionTitles: ["Terminer"], actions:
                [{ _ in self.refreshCollectionView()}])
        
            
            }.catch { _ in
        }
    }
    
    private func performJoiningCircle() {
        let indexPath = collectionView.indexPathsForSelectedItems?.first
        let id = self.dataArray[(indexPath?.row)!].Id

        ApiManager.performAlamofireRequest(url: ApiRoute.ROUTE_FRIEND_YES, param: ["token": User.sharedInstance.getParameter(parameter: "token"), "invite_id": id]).done {
            jsonData in
   
            self.performUIAlert(title: "Vous avez rejoint un nouveau cercle!", message: nil, actionTitles: ["Terminer"], actions:
                [{ _ in self.refreshCollectionView()}])
            
            }.catch { _ in
        }
    }
    
    @objc private func doubleTapped() {
        
        self.performUIAlert(title: "Êtes-vous sûr de vouloir rejoindre ce cercle?", message: nil, actionTitles: ["Non", "Oui"], actions:
            [{ _ in self.performDeclineCircle()}, {_ in self.performJoiningCircle()}])
    }
    
    private func loadCirclesInvitations() {

        ApiManager.performAlamofireRequest(url: ApiRoute.ROUTE_ACCOUNT_INFO, param: User.sharedInstance.getTokenParameter()).done {
            response in
            let invites = JSON(response)["content"]["invites"]
            self.dataArray.removeAll()
            
            for index in 0...invites.count {
                self.dataArray.append(ItemCellData(Name: invites[index]["circle"]["name"].stringValue,
                                                   Date: invites[index]["created"].stringValue, Id: invites[index]["id"].intValue))
            }
            self.collectionView.reloadData()
            
            }.catch{
                _ in
                HandleErrors.displayError(message: "Impossible de charger les cercles", controller: self)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        loadCirclesInvitations()
    }
    
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return IndicatorInfo(title: "\(childNumber)")
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        self.setupGridView()
        DispatchQueue.main.async {
            self.collectionView.reloadData()
        }
    }
    
    func setupGridView() {
        let flow = collectionView?.collectionViewLayout as! UICollectionViewFlowLayout
        flow.minimumInteritemSpacing = CGFloat(self.cellMarginSize)
        flow.minimumLineSpacing = CGFloat(self.cellMarginSize)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return (self.dataArray.count - 1)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ItemCell", for: indexPath) as! ItemCell

        print("INSIDE VIEW -> \(self.dataArray)")
        
        cell.setData(circleName: self.dataArray[indexPath.row].Name, circleDate: self.dataArray[indexPath.row].Date)

        cell.layer.borderColor = UIColor.lightGray.cgColor
        cell.layer.borderWidth = 0.5
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath)
        cell?.layer.borderColor = UIColor.gray.cgColor
        cell?.layer.borderWidth = 2
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath)
        cell?.layer.borderColor = UIColor.gray.cgColor
        cell?.layer.borderWidth = 0.5
    }

}

extension ChildViewControllerInvitationsCircle: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = self.calculateWith()
        return CGSize(width: width, height: width)
    }
    
    func calculateWith() -> CGFloat {
        let estimatedWidth = CGFloat(estimateWidth)
        let cellCount = floor(CGFloat(self.view.frame.size.width / estimatedWidth))
        
        let margin = CGFloat(cellMarginSize * 2)
        let width = (self.view.frame.size.width - CGFloat(cellMarginSize) * (cellCount - 1) - margin) / cellCount
        
        return width
    }
}
