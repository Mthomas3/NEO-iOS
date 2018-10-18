//
//  ChildViewController.swift
//  Neo
//
//  Created by Thomas Martins on 11/09/2018.
//  Copyright © 2018 Neo. All rights reserved.
//

import UIKit
import XLPagerTabStrip
import SwiftyJSON

class ChildViewController: UIViewController, IndicatorInfoProvider, UICollectionViewDataSource {
    
    var childNumber: String = ""
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    private var dataArray = [ItemCellData]()
    private let estimateWidth = 140.0
    private let cellMarginSize = 3.0
    
    override func viewWillAppear(_ animated: Bool) {
        self.loadingCircleContact()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        self.collectionView.register(UINib(nibName: "ItemCell", bundle: nil), forCellWithReuseIdentifier: "ItemCell")
        
        self.setupGridView()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(doubleTapped))
        tap.numberOfTapsRequired = 2
        view.addGestureRecognizer(tap)
        
    }
    
    @objc func doubleTapped() {
        if !self.dataArray.isEmpty && (self.collectionView.indexPathsForSelectedItems?.first != nil) {
            self.performSegue(withIdentifier: "addContactToCircle", sender: self)
        }
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
    
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return IndicatorInfo(title: "\(childNumber)")
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "addContactToCircle" {
            
            let loadCircleView = segue.destination as? ManagePeopleInCircles
            let indexPath = collectionView.indexPathsForSelectedItems?.first
            
            loadCircleView?.setCircleData(circleItems: self.dataArray[(indexPath?.row)!])
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int { return (self.dataArray.count) }
    
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

extension ChildViewController : UICollectionViewDelegateFlowLayout {
    
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
    
    func loadingCircleContact() {
        ServicesCircle.shareInstance.getCirclesInformations(completion: { (data) in
            self.dataArray = data
            self.collectionView.reloadData()
        })
    }
}
