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

    public var childNumber: String = "Invitations (0)"
    private var dataArray = [ItemCellData]()
    private let estimateWidth = 140.0
    private let cellMarginSize = 3.0
    public var tabTitle: String? = "Invitations (0)"

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
        self.dataArray.removeAll()
        
        checkInvitationsOnSocket()
    }
    
    private func checkInvitationsOnSocket () {
        
        SocketManager.sharedInstance.getManager().defaultSocket.on("circle_invite") { invitation, _  in
                let invites = JSON(invitation)
                var circle_inv_id = 0
            
                for item in invites.arrayValue {
                    circle_inv_id = item["circle_invite_id"].intValue
                }
            
            self.updatingTitle()
            
            ServicesCircle.shareInstance.getCirclesInvitesOnSocket(id: circle_inv_id, token:            User.sharedInstance.getTokenParameter(), completion: { (inv) in
                    self.dataArray.append(ItemCellData(Name: inv["circle"]["name"].stringValue,
                                                       Date: inv["circle"]["created"].stringValue, Id: inv["id"].intValue))
                
                    self.collectionView.reloadData()
                })
            }
        }
    
    public func updatingTitle() {
        ServicesCircle.shareInstance.getNumberCircleInvitOnWait { (number) in
            self.tabTitle = "Invitations (\(String(number)))"
            if let page = self.parent as? ButtonBarPagerTabStripViewController {
                page.buttonBarView.reloadData()
            }
        }
    }
    
    @objc private func doubleTapped() {
        
        if !self.dataArray.isEmpty && ((self.collectionView.indexPathsForSelectedItems?.first != nil)){
            self.performUIAlert(title: "Êtes-vous sûr de vouloir rejoindre ce cercle?", message: nil, actionTitles: ["Non", "Oui"], actions:
                [{ _ in self.declineCircleInvite()}, {_ in self.joinCircleInvite()}])
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.updatingTitle()
        self.loadingCircleInvitation()
    }
    
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return IndicatorInfo(title: self.tabTitle)
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
        
        return (self.dataArray.count)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ItemCell", for: indexPath) as! ItemCell
        
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
    
    func joinCircleInvite() {
        let indexPath = self.collectionView.indexPathsForSelectedItems?.first
        let id = self.dataArray[(indexPath?.row)!].Id
        
        ServicesCircle.shareInstance.acceptCircleInvitationGroup(id: id) { (data) in
            self.updatingTitle()
            self.performUIAlert(title: "Vous avez rejoint un nouveau cercle!", message: nil, actionTitles: ["Terminer"], actions:
                [{ _ in self.loadingCircleInvitation()}])
            if let pagerTabStrip = self.parent as? ButtonBarPagerTabStripViewController {
                pagerTabStrip.moveToViewController(at: 0)
            }
        }
    }
    
    func declineCircleInvite() {
        let indexPath = self.collectionView.indexPathsForSelectedItems?.first
        let id = self.dataArray[(indexPath?.row)!].Id
        
        ServicesCircle.shareInstance.declineCircleInvitationGroup(id: id) { (data) in
            self.updatingTitle()
            self.performUIAlert(title: "Vous avez refusez l'invitation", message: nil, actionTitles: ["Terminer"], actions:
                [{ _ in self.loadingCircleInvitation()}])
        }
    }
    
    func loadingCircleInvitation() {
        ServicesCircle.shareInstance.getCirclesInvites { (data) in
            self.dataArray = data
            self.collectionView.reloadData()
        }
    }
}
