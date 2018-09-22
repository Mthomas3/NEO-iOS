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


class ChildViewControllerSecond: UIViewController, IndicatorInfoProvider, UICollectionViewDataSource {

    var childNumber: String = ""
    
    private var dataArray = [[String(), String(), Int()]]
    private var estimateWidth = 140.0
    private var cellMarginSize = 3.0

    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        
        // Register cells
        self.collectionView.register(UINib(nibName: "ItemCell", bundle: nil), forCellWithReuseIdentifier: "ItemCell")
        
        // SetupGrid view
        self.setupGridView()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(doubleTapped))
        tap.numberOfTapsRequired = 2
        view.addGestureRecognizer(tap)
    }
    
    private func refreshCollectionView() {
        self.loadCirclesInvitations()
    }
    
    private func performDeclineCircle() {
        
        let indexPath = collectionView.indexPathsForSelectedItems?.first
        let id = self.dataArray[(indexPath?.row)!][2]

       ApiManager.performAlamofireRequest(url: ApiRoute.ROUTE_FRIEND_NO, param: ["token": User.sharedInstance.getParameter(parameter: "token"), "invite_id": id]).done {
            jsonData in
        
            self.performUIAlert(title: "Vous avez refusez l'invitation", message: nil, actionTitles: ["Terminer"], actions:
                [{ _ in self.refreshCollectionView()}])
        
            
            }.catch { _ in
        }
    }
    
    private func performJoiningCircle() {

        let indexPath = collectionView.indexPathsForSelectedItems?.first
        let id = self.dataArray[(indexPath?.row)!][2]
        
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
        self.dataArray.removeAll()
        ApiManager.performAlamofireRequest(url: ApiRoute.ROUTE_ACCOUNT_INFO, param: User.sharedInstance.getTokenParameter()).done {
            response in
            let JSONdata = JSON( response)
            let content = JSONdata["content"]
            let invites = content["invites"]
            self.dataArray.removeAll()
            
            for index in 0...invites.count {
                
                let _id = invites[index]["id"]
                let _date = invites[index]["created"]
                
                let _circleInvitation = invites[index]["circle"]
                
                let name = _circleInvitation["name"]
                
                self.dataArray.append([name.stringValue, _date.stringValue, _id.intValue])
                
            }
            print("the invites are \(invites)")
            self.collectionView.reloadData()
            
            
            }.catch{
                _ in
                HandleErrors.displayError(message: "something went wrong", controller: self)
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.dataArray.removeAll()
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
        // set the data here
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ItemCell", for: indexPath) as! ItemCell
        print("inside collection view -> \(self.dataArray)")
        cell.setData(circleName: self.dataArray[indexPath.row][indexPath.section] as! String, circleDate: self.dataArray[indexPath.row][1] as! String)
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

extension ChildViewControllerSecond: UICollectionViewDelegateFlowLayout {
    
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
