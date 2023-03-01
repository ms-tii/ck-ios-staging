//
//  MenuBar.swift
//  CareKernel
//
//  Created by Mohit Sharma on 29/10/21.
//

import Foundation
import UIKit

class MenuBar: UIView,  UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = #colorLiteral(red: 0.5725490451, green: 0, blue: 0.2313725501, alpha: 1)
        cv.dataSource = self
        cv.delegate = self
        return cv
    }()
    
    let cellId = "cellId"
    let imageNames = ["home", "trending", "subscriptions", "account", "trending", "subscriptions", "account"]
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        collectionView.register(MenuCell.self, forCellWithReuseIdentifier: cellId)
        
        addSubview(collectionView)
        addConstraintsWithFormat(format: "H:|[v0]|", views: collectionView)
        addConstraintsWithFormat(format: "V:|[v0]|", views: collectionView)
        
        let selectedIndexPath = IndexPath(item: 0, section: 0)
        collectionView.selectItem(at: selectedIndexPath, animated: false, scrollPosition: .bottom)
    }
//    override class func awakeFromNib() {
//        super.awakeFromNib()
//    }
    required init?(coder aDecoder: NSCoder) {
            super.init(coder: aDecoder)
    }
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 4
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! MenuCell
        
//        cell.imageView.image = UIImage(named: imageNames[indexPath.item])?.withRenderingMode(.alwaysTemplate)
//        cell.tintColor = UIColor.rgb(red: 91, green: 14, blue: 13)
        cell.setupViews()
        cell.label.text = imageNames[indexPath.item]
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: frame.width / 4, height: frame.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}

class MenuCell: UICollectionViewCell {
    
//    let imageView: UIImageView = {
//        let iv = UIImageView()
//        iv.image = UIImage(named: "home")?.withRenderingMode(.alwaysTemplate)
//        iv.tintColor = UIColor.rgb(red: 91, green: 14, blue: 13)
//        return iv
//    }()
    
    let label: UILabel = {
        let lbl = UILabel()
        lbl.text = "Basic Details"
        lbl.textColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
//        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()
    
    override var isHighlighted: Bool {
        didSet {
            label.tintColor = isHighlighted ? UIColor.white : UIColor.blue
        }
    }
    
    override var isSelected: Bool {
        didSet {
            label.tintColor = isSelected ? UIColor.white : UIColor.brown
        }
    }
    
    func setupViews() {
        
        addSubview(label)
        addConstraintsWithFormat(format: "H:[v0]", views: label)
        addConstraintsWithFormat(format: "V:[v0]", views: label)
        
        addConstraint(NSLayoutConstraint(item: label, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1, constant: 0))
        addConstraint(NSLayoutConstraint(item: label, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 0))
    }
    
}
