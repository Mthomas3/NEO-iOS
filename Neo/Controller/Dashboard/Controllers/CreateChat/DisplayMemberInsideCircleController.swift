//
//  DisplayMemberInsideCircleController.swift
//  Neo
//
//  Created by Thomas Martins on 05/10/2018.
//  Copyright © 2018 Neo. All rights reserved.
//

import UIKit

class DisplayMemberInsideCircleController: UIViewController,  UICollectionViewDelegate, UICollectionViewDataSource{

    @IBOutlet weak var collectionView: UICollectionView!
   
    
    internal var CircleData: ItemCellData? = nil
    private var cellMembers: [MemberCellData] = []
    private var cells: [MemberCreateConvCell] = []
    private var _colorButton : ColorsButtonOnEditing
    @IBOutlet private weak var _nextButton: NextButton!    
    
    required init(coder: NSCoder) {
        _colorButton = ColorsButtonOnEditing()
        super.init(coder: coder)!
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        setColorOnCollectionViewBorder()
        
        getMembersInCircle()
        
    }
    
    @IBAction func labelPressed(_ sender: Any) {
        var count = 0
        self.cells.forEach { (members) in
            print("MEMBERS \(members.isChecked)")
            if members.isChecked {
                count += 1
            }
        }
        _nextButton.backgroundColor = UIColor(hue: 0.5417, saturation: 0.52, brightness: 0.78, alpha: 1.0)
    }
    
    
    private func setColorOnCollectionViewBorder() {
        collectionView.layer.borderColor = UIColor(hue: 0.5417, saturation: 0.52, brightness: 0.78, alpha: 1.0).cgColor
        collectionView.layer.borderWidth = 1.0
        collectionView.layer.cornerRadius = 3.0
    }
    
    private func getMembersInCircle() {
        ServicesCircle.shareInstance.getMembersInCircle(circle_id: (CircleData?.Id)!) { (data) in
            data.forEach({ (member) in
                if !member.Email.isEqualToString(find: User.sharedInstance.getEmail()) {
                    self.cellMembers.append(member)
                }
                print("people in circle -> \(member.Email)")
            })
            if self.cellMembers.isEmpty {
                self.cellMembers.append(MemberCellData(FName: "Aucun", LName: "Contact", Email: ""))
            }
            self.collectionView.reloadData()
        }
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if identifier.isEqualToString(find: "createNameConv") {
            var count = 0
            self.cells.forEach { (item) in
                if item.isChecked {
                    count += 1
                }
            }
            if count == 0 {
                HandleErrors.displayError(message: "Vous devez sélectionner au moins un membre", controller: self)
                return false
            }
            return true
        }
        return true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier?.isEqualToString(find: "createNameConv"))! {
            let vc = segue.destination as? CreateNameConversationController
            vc?.cells = self.cells
            vc?.circleData = CircleData
        }
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int { return self.cellMembers.count }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = self.collectionView.dequeueReusableCell(withReuseIdentifier: "memberCell", for: indexPath) as! MemberCreateConvCell
        cell.setName = self.cellMembers[indexPath.row].FName.concat(string: " \(self.cellMembers[indexPath.row].LName)")
        cell.email = self.cellMembers[indexPath.row].Email
        self.cells.append(cell)
        return cell
    }
    
    
}
