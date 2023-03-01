//
//  HealthConditionViewController.swift
//  CareKernel
//
//  Created by Mohit Sharma on 26/11/21.
//

import UIKit
import SwiftyJSON
import JGProgressHUD

class HealthConditionViewController: UIViewController {

    @IBOutlet var healthTableView: UITableView!
    @IBOutlet var noRecordsLabel: UILabel!
    
    var clientDetailsVM = ClientDetailsViewModel()
    var clientId = 0
    var healthConditionsArray = NSMutableArray()
    var tempTableHeight = 0.0
    var tempTableWidth = 0.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        refreshTableView()
        noRecordsLabel.isHidden = true
        healthTableView.register(CasenotesHeaderCell.nib(), forHeaderFooterViewReuseIdentifier: "CasenotesHeaderCell")
        if #available(iOS 15.0, *) {
            healthTableView.sectionHeaderTopPadding = 0
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        clientId = careKernelDefaults.value(forKey: "clientID") as! Int
        DispatchQueue.main.asyncAfter(deadline: .now() + 0) {
            self.fetchData()
        }
    }
    
    override func viewDidLayoutSubviews(){
            super.viewDidLayoutSubviews()
        let tableHeight = self.healthTableView.frame.height
        let viewHeight = self.view.frame.height
        tempTableHeight = viewHeight - tableHeight
        let framWidth = self.view.frame.width
        tempTableWidth = framWidth + 20
        var frame = self.healthTableView.frame
        
        switch UIDevice().type {
        case .iPhone5, .iPhone5C, .iPhone5S, .iPhoneSE :
            frame.size.height = frame.size.height
            frame.size.width = frame.size.width + 95
        case .iPhoneSE2, .iPhone6, .iPhone6S, .iPhone7, .iPhone8 :
            frame.size.height = frame.size.height
            frame.size.width = frame.size.width + 40
        case .iPhone6SPlus, .iPhone7Plus, .iPhone8Plus :
//            frame.size.height = tempTableHeight
//            frame.size.width = frame.size.width + 10
            break
        case .iPhone11Pro, .iPhoneXS  :
//            frame.size.height = frame.size.height - 10
            frame.size.width = frame.size.width + 40
            break
        case .iPhone12, .iPhone12Pro, .iPhone13Pro, .iPhone13 :
//            frame.size.height = tempTableHeight - 24
//            frame.size.width = frame.size.width + 28
            break
        case .iPhone12Mini, .iPhone13Mini :
//            frame.size.height = tempTableHeight - 24
            frame.size.width = frame.size.width + 40
            break
        case .iPhone12ProMax, .iPhone13ProMax  :
//            frame.size.width = frame.size.width - 14
            break
        default: break
        }
        self.healthTableView.frame = frame
    }
    
    func refreshTableView(){
        self.healthTableView.refreshControl = UIRefreshControl()
        self.healthTableView.refreshControl?.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        
    }
    
    @objc private func refreshData(){
        print("Refreshed")
        self.fetchData()
    }
    
    func fetchData(){
        healthConditionsArray.removeAllObjects()
        guard let token = careKernelDefaults.value(forKey: kLoginToken) as? String else {
            careKernelDefaults.set(false, forKey: kIsLoggedIn)
            return }
        clientDetailsVM.getClientHealthCondition(clientID: "\(clientId)", token: token) { response, success in
            if success {
                DispatchQueue.main.async {
                    let tempArray = JSON(response)["data"].arrayValue
                    if tempArray.count != 0 {
                        for value in tempArray {
                            let isActive = JSON(value)["isActive"].boolValue
                            if isActive{
                            self.healthConditionsArray.add(value)
                            }
                        }
                        
                        self.noRecordsLabel.isHidden = true
                        self.healthTableView.reloadData()
                    }else{
                        self.noRecordsLabel.isHidden = false
                        self.healthTableView.isHidden = true
                    }
                }
            }else{
                let statusCode = JSON(response)["statusCode"].intValue
                let message = JSON(response)["message"].stringValue
                if statusCode == 401 && message == "Unauthorized" {
                    careKernelDefaults.set(false, forKey: kIsLoggedIn)
                    careKernelDefaults.set("", forKey: kUserEmailId)
                    careKernelDefaults.set("", forKey: kLoginToken)
                    self.dismiss(animated: false, completion: nil)
                }
            }
            self.healthTableView.refreshControl?.endRefreshing()
        }
        
    }

}

extension HealthConditionViewController : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
            return UITableView.automaticDimension
        }

    func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
            return 66.0
        }
    

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let cell = tableView.dequeueReusableHeaderFooterView(withIdentifier: "CasenotesHeaderCell") as? CasenotesHeaderCell else {
          return nil
          }
        cell.headerTitleLabel.text = "Health Conditions"
        cell.iconImageView.image = UIImage(named: "icon-health")
        cell.clipsToBounds = true
        cell.layer.cornerRadius = 8
        cell.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
          return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        healthConditionsArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "HealthConditionCell", for: indexPath) as! HealthConditionCell
        
        cell.typeLabel.text = JSON(healthConditionsArray)[indexPath.row ]["healthConditionType"]["name"].stringValue
        
        if healthConditionsArray.count-1 == indexPath.row {
            cell.clipsToBounds = true
            cell.layer.cornerRadius = 8
            cell.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        }
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let details = JSON(healthConditionsArray)[indexPath.row ]["healthConditionType"]["name"].stringValue
        showAlertAlligned("Type", message: details, actions: ["Ok"]) { action in
            
        }
    }
}


class HealthConditionCell : UITableViewCell {
    
    @IBOutlet var typeLabel: UILabel!
}
