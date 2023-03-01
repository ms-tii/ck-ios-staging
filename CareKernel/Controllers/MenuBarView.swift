//
//  MenuBarViewController.swift
//  CareKernel
//
//  Created by Mohit Sharma on 30/10/21.
//

import Foundation
import UIKit

class MenuBarView: UIView, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource, UICollectionViewDelegate {
    
    //MARK: Properties
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var whiteBar: UIView!
    @IBOutlet weak var whiteBarLeadingConstraint: NSLayoutConstraint!
    var whiteBarLeftAnchorConstraint: NSLayoutConstraint?
    //    let pagesTitle = ["Basic Details", "Case Notes", "Health Conditions", "Medicines", "Medical Details", "Risks", "Incidents"]
    var pagesTitle = [String]()
    var selectedIndex = 0
    let horizontalBarView = UIView()
    var previousSelecteIndex = 0
    //MARK: View LifeCycle
    override func awakeFromNib() {
        super.awakeFromNib()
        setUpBar()
        pagesTitle = careKernelDefaults.value(forKey: "pageTitles") as! [String]
        pagesTitle.sort()
        whiteBar.isHidden = true
        NotificationCenter.default.addObserver(self, selector: #selector(self.animateMenu(notification:)), name: Notification.Name.init(rawValue: "scrollMenu"), object: nil)
    }
    func setUpBar(){
        
        horizontalBarView.backgroundColor = UIColor.white
        horizontalBarView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(horizontalBarView)
        whiteBarLeftAnchorConstraint = horizontalBarView.leftAnchor.constraint(equalTo: self.leftAnchor)
        whiteBarLeftAnchorConstraint?.isActive = true
        
        horizontalBarView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -3).isActive = true
        horizontalBarView.widthAnchor.constraint(equalToConstant: self.collectionView.frame.width / 3).isActive = true
        horizontalBarView.heightAnchor.constraint(equalToConstant: 5).isActive = true
    }
    func setupMenuBar() {
        collectionView.backgroundColor = UIColor(named: "Basic Blue")
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView?.register(UINib(nibName: "pagesCollectionCell", bundle: nil), forCellWithReuseIdentifier: "ReusableCell")
        
        
    }
    @objc func animateMenu(notification: Notification) {
        if let info = notification.userInfo {

            let userInfo = info as! [String: CGFloat]
            
            self.selectedIndex = Int((userInfo["length"]!))
            print(selectedIndex)
            if self.selectedIndex < 2 && selectedIndex < pagesTitle.count{
                let x = self.selectedIndex * Int(frame.width) / 3
                whiteBarLeftAnchorConstraint?.constant = CGFloat(x)
            }else if self.selectedIndex == 2 {
                if selectedIndex < pagesTitle.count && pagesTitle.count % 2 != 0{
                    if selectedIndex == pagesTitle.count - 1 {
                        let x = self.selectedIndex * Int(frame.width) / 3
                        whiteBarLeftAnchorConstraint?.constant = CGFloat(x)
                    }else{
                        let x =  frame.width / 3
                        whiteBarLeftAnchorConstraint?.constant = CGFloat(x)
                        
                    }
                }else{
                    let x =  frame.width / 3
                    whiteBarLeftAnchorConstraint?.constant = CGFloat(x)
                }
            }else if self.selectedIndex == 3 && pagesTitle.count % 2 != 0 {
                let consIndex = Int(self.selectedIndex) / 3
                let x = (CGFloat(consIndex)) * frame.width / 3
                whiteBarLeftAnchorConstraint?.constant = CGFloat(x)
            }else if self.selectedIndex >= 3 {
                var x =  frame.width / 3
                if selectedIndex == pagesTitle.count - 1{
                    x = x * 2
                }
                
                whiteBarLeftAnchorConstraint?.constant = CGFloat(x)
            }

            UIView.animate(withDuration: 0.75, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut) {
                self.layoutIfNeeded()
            } completion: { success in
                
            }
            self.collectionView.reloadData()
        }
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        pagesTitle.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "pagesCollectionCell", for: indexPath) as! pagesCollectionCell
        cell.pagesNameLabel.text = pagesTitle[indexPath.item]
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let barWidth = horizontalBarView.frame.width

        return CGSize(width: barWidth, height: collectionView.bounds.height)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if self.selectedIndex != indexPath.row {
            previousSelecteIndex = selectedIndex
            self.selectedIndex = indexPath.row
            
            if self.selectedIndex < 2 && selectedIndex < pagesTitle.count{
                let x = self.selectedIndex * Int(frame.width) / 3
                whiteBarLeftAnchorConstraint?.constant = CGFloat(x)
            }else if self.selectedIndex == 2 {
                if selectedIndex < pagesTitle.count && pagesTitle.count % 2 != 0{
                    if selectedIndex == pagesTitle.count - 1 {
                        let x = self.selectedIndex * Int(frame.width) / 3
                        whiteBarLeftAnchorConstraint?.constant = CGFloat(x)
                    }else{
                        let x =  frame.width / 3
                        whiteBarLeftAnchorConstraint?.constant = CGFloat(x)
                        
                    }
                }else{
                    let x =  frame.width / 3
                    whiteBarLeftAnchorConstraint?.constant = CGFloat(x)
                }
            }else if self.selectedIndex == 3 && pagesTitle.count % 2 != 0 {
                let consIndex = Int(self.selectedIndex) / 3
                let x = (CGFloat(consIndex)) * frame.width / 3
                whiteBarLeftAnchorConstraint?.constant = CGFloat(x)
            }else if self.selectedIndex >= 3 {
                var x =  frame.width / 3
                if selectedIndex == pagesTitle.count - 1{
                    x = x * 2
                }
                whiteBarLeftAnchorConstraint?.constant = CGFloat(x)
            }
            UIView.animate(withDuration: 0.75, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut) {
                self.layoutIfNeeded()
            } completion: { success in
                
            }
            NotificationCenter.default.post(name: Notification.Name.init(rawValue: "didSelectMenu"), object: nil, userInfo: ["index": self.selectedIndex])
            let indexPath = IndexPath(item: selectedIndex, section: 0)
            
            self.collectionView.selectItem(at: indexPath, animated: true, scrollPosition: .centeredHorizontally)
        }else if self.selectedIndex == indexPath.row{
            //Do nothing
        }else if self.selectedIndex < indexPath.row || self.selectedIndex > 0{
            let x = CGFloat(indexPath.item) * frame.width / 3
            whiteBarLeftAnchorConstraint?.constant = x
            UIView.animate(withDuration: 0.75, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut) {
                self.layoutIfNeeded()
            } completion: { success in
                
            }
        }
    }
    
    
    
    
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
