//
//  SessionBasicsCell.swift
//  CareKernel
//
//  Created by Mohit Sharma on 05/11/21.
//

import UIKit
import SwiftyJSON


protocol SessionDetailsDelegate: AnyObject {
    func didTapButton(for cell: SessionBasicsCell, cellData: [String:Any], title: String)

    func buttonInCollectionCellTapped(_ tag: Int, title: String)
}

class SessionBasicsCell: UITableViewCell, UICollectionViewDataSource, UICollectionViewDelegate, CollectionCellDelegate {

    @IBOutlet weak var clientsCollectionView: UICollectionView!
    @IBOutlet var startTimelbl: UILabel!
    @IBOutlet var endtimelbl: UILabel!
    @IBOutlet var workerNamelbl: UILabel!
    @IBOutlet var travelLbl: UILabel!
    @IBOutlet var locationLbl: UILabel!
    @IBOutlet var instructionLbl: UILabel!
    @IBOutlet weak var instructionDataLabel: UILabel!
    @IBOutlet var timerLbl: UILabel!
    @IBOutlet var clockOnButton: UIButton!
    @IBOutlet var unassignButton: UIButton!
    @IBOutlet var deliveredButton: UISwitch!
    @IBOutlet weak var noRecordLabel: UILabel!
    @IBOutlet weak var descriptionView: UIView!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var descriptionDataLabel: UILabel!
    
    var clientLineDetails = NSMutableArray()

    var parentViewController: UIViewController? = nil
    static let identifire = "SessionBasicsCell"
    weak var delegate: SessionDetailsDelegate?
    var indexPath: IndexPath?
    var dataDict: [String:Any] = [:]
    var callback: ((_ switch: UISwitch) -> Void)?
    var value: Bool =  true
    static func nib() -> UINib {
        
            return UINib(nibName: "SessionBasicsCell", bundle: nil)
    }
    
    var clientsDetailsArray : NSMutableArray = [] {
        
        didSet {
            if clientsDetailsArray.count == 0{
                self.noRecordLabel.isHidden = false
            }else{
                self.clientsCollectionView.reloadData()
                self.noRecordLabel.isHidden = true
            }
            
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.noRecordLabel.isHidden = false
        parentViewController = SessionDetailsViewController()
        self.clientsCollectionView.dataSource = self
                self.clientsCollectionView.delegate = self
                self.clientsCollectionView.register(UINib.init(nibName: "ClientsCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "clientsCollectionCell")

    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func clockOnAction(_ sender: UIButton) {
        let currentCell = self
        delegate?.didTapButton(for: currentCell, cellData: dataDict, title: sender.title(for: .normal) ?? "Clock On")
    }
    
    @IBAction func deliveredButtonAction(_ sender: UISwitch) {
//        let currentCell = self
//        if sender.isOn{
//        delegate?.didTapButton(for: currentCell, cellData: dataDict, title:  "Delivered Button")
//        }
        
        self.value = sender.isOn
        callback?(sender)
    }

    func clientButtonCelltapped(_ tag: Int) {
        delegate?.buttonInCollectionCellTapped(tag, title: "ClientButton")
    }

    
    @objc func clientButtonAction(sender: UIButton){
    
        delegate?.buttonInCollectionCellTapped(sender.tag, title: "ClientButton")
    }
    
    @objc func lineItemButtonAction(sender: UIButton){
    
        delegate?.buttonInCollectionCellTapped(sender.tag, title: "LineItemButton")
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
       
        return clientsDetailsArray.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "clientsCollectionCell", for: indexPath as IndexPath) as! ClientsCollectionViewCell
        cell.delegate = delegate as? CollectionCellDelegate
        cell.layer.cornerRadius = 4
        cell.layer.masksToBounds = false
//        let clientLineDetails = careKernelDefaults.value(forKey: "clientLineDetails") as! NSMutableArray
        let clientName = JSON(clientsDetailsArray)[indexPath.row]["fullName"].stringValue
        let lineItemsArr = JSON(clientsDetailsArray)[indexPath.row]["lineItem"].arrayValue
        cell.clientNameButton.setTitle(clientName, for: .normal)
        cell.clientNameButton.tag = indexPath.row
        cell.clientNameButton.addTarget(self, action: #selector(clientButtonAction), for: .touchUpInside)
        var arrString = String()
        for value in lineItemsArr {
           
            arrString = "\(arrString) \(value),"
                        
//            print(arrString)
            
        }
        cell.lineItemsLabel.text = arrString
        cell.lineItemButton.tag = indexPath.row
        cell.lineItemButton.setTitle("", for: .normal)
        cell.lineItemButton.addTarget(self, action: #selector(lineItemButtonAction), for: .touchUpInside)
                return cell
    }
}

