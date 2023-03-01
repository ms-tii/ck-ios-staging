//
//  RiskViewController.swift
//  CareKernel
//
//  Created by Mohit Sharma on 28/11/21.
//

import UIKit
import SwiftyJSON

class RiskViewController: UIViewController {

    @IBOutlet var riskTableView: UITableView!
    @IBOutlet var noRecordsLabel: UILabel!
    
    
    var clientDetailsVM = ClientDetailsViewModel()
    var clientId = 0
    var riskArray = NSMutableArray()
    var filesArray = NSMutableArray()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        noRecordsLabel.isHidden = true
        riskTableView.register(CasenotesHeaderCell.nib(), forHeaderFooterViewReuseIdentifier: "CasenotesHeaderCell")
        riskTableView.register(ClientFilesCell.nib(), forCellReuseIdentifier: "ClientFilesCell")
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        refreshTableView()
        clientId = careKernelDefaults.value(forKey: "clientID") as! Int
        DispatchQueue.main.asyncAfter(deadline: .now() + 0) {
            self.fetchData()
        }
    }
    
    func refreshTableView(){
        self.riskTableView.refreshControl = UIRefreshControl()
        self.riskTableView.refreshControl?.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        
    }
    
    @objc private func refreshData(){
        print("Refreshed")
        self.fetchData()
    }

    
    func fetchData(){
        riskArray.removeAllObjects()
        guard let token = careKernelDefaults.value(forKey: kLoginToken) as? String else {
            careKernelDefaults.set(false, forKey: kIsLoggedIn)
            return }
        clientDetailsVM.getClientRisks(clientID: "\(clientId)", token: token) { response, success in
            if success {
                DispatchQueue.main.async {
                    let tempArray = JSON(response)["data"].arrayValue
                    if tempArray.count != 0 {
                        for value in tempArray {
                            self.riskArray.add(value)
                        }
                        
                        print(self.riskArray)
                        self.clientDetailsVM.getClientFiles(entity: "risks", clientID: "\(self.clientId)", token: token) { response2, success2 in
                            if success2 {
                                self.filesArray.removeAllObjects()
                                let tempFileArray = JSON(response2)["data"].arrayValue
                                if tempFileArray.count != 0 {
                                    for file in tempFileArray {
                                        self.filesArray.add(file)
                                    }
                                    self.riskTableView.reloadData()
                                }
                            }
                        }
                        self.noRecordsLabel.isHidden = true
                        self.riskTableView.reloadData()
                    }else{
                        self.noRecordsLabel.isHidden = false
                        self.riskTableView.isHidden = true

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
            self.riskTableView.refreshControl?.endRefreshing()
        }
        
    }

    func getFormattedDate(date: Date, format: String) -> String {
        let dateformat = DateFormatter()
        dateformat.dateFormat = format
        return dateformat.string(from: date)
    }
    
    func iso860ToString(dateString: String) -> Date{
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        let date = dateFormatter.date(from:dateString) ?? Date()
        return date
        
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let vc = segue.destination as? FilesImageViewController {
            vc.imageurlString = sender as! String
        }
    }
}

class RiskCell : UITableViewCell {
    
    @IBOutlet var domainLabel: UILabel!
    @IBOutlet var descriptionLabel: UILabel!
    @IBOutlet var alertLabel: UILabel!
    @IBOutlet var createdAtLabel: UILabel!
}

extension RiskViewController : UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        2
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
            return UITableView.automaticDimension
        }

    func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
            return 66.0
        }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 150
        }else{
            return 75
        }
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let cell = tableView.dequeueReusableHeaderFooterView(withIdentifier: "CasenotesHeaderCell") as? CasenotesHeaderCell else {
          return nil
          }
        if section == 0 {
            cell.headerTitleLabel.text = "Risks"
            cell.iconImageView.image = UIImage(named: "icon-risks")
        }else{
            cell.headerTitleLabel.text = "Files"
            cell.iconImageView.image = UIImage(named: "icon-files")
        }
        cell.clipsToBounds = true
        cell.layer.cornerRadius = 8
        cell.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
          return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return riskArray.count
        }else{
            return filesArray.count
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0{
            let cell = tableView.dequeueReusableCell(withIdentifier: "RiskCell", for: indexPath) as! RiskCell
            let domain = JSON(riskArray)[indexPath.row ]["riskDomain"]["name"].stringValue
            let desc = JSON(riskArray)[indexPath.row ]["description"].stringValue
            print(domain, desc)
            cell.domainLabel.text = domain
            cell.descriptionLabel.text = desc
            let alert = JSON(riskArray)[indexPath.row ]["isAlertable"].boolValue
            if alert {
                cell.alertLabel.text = "Yes"
            }else{
                cell.alertLabel.text = "No"
            }
            
            let createdAt = getFormattedDate(date: iso860ToString(dateString: JSON(riskArray)[indexPath.row ]["createdAt"].stringValue), format: "dd/mm/yyyy hh:mm a")
            
            cell.createdAtLabel.text = createdAt
            if riskArray.count-1 == indexPath.row {
                cell.clipsToBounds = true
                cell.layer.cornerRadius = 8
                cell.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
            }
            return cell
        }else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "ClientFilesCell", for: indexPath) as! ClientFilesCell
            
            cell.idLabel.text = JSON(filesArray)[indexPath.row ]["displayId"].stringValue
            cell.nameLabel.text = JSON(filesArray)[indexPath.row ]["name"].stringValue
            let isVisibleToServiceWorker = JSON(filesArray)[indexPath.row ]["viewFilePermission"].boolValue
            if isVisibleToServiceWorker {
                cell.viewLabel.isHidden = false
                cell.viewLabel.layer.cornerRadius = 8
                cell.viewLabel.layer.masksToBounds = true
            }else{
                cell.viewLabel.isHidden = true
            }
            cell.viewLabel.layer.cornerRadius = 8
            cell.viewLabel.layer.masksToBounds = true
            cell.selectionStyle = .none

            return cell
        }
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            let domain = "Domain - " + JSON(riskArray)[indexPath.row ]["riskDomain"]["name"].stringValue
            let desc = "Description - " + JSON(riskArray)[indexPath.row ]["description"].stringValue
            var alertValue = String()
            let alert = JSON(riskArray)[indexPath.row ]["isAlertable"].boolValue
            if alert {
                alertValue = "Alert - Yes"
            }else{
                alertValue = "Alert - No"
            }
            let createdAt = "Created at - " + getFormattedDate(date: iso860ToString(dateString: JSON(riskArray)[indexPath.row ]["createdAt"].stringValue), format: "dd/mm/yyyy hh:mm a")
            let details = "\(domain) \n\(desc) \n\(alertValue) \n\(createdAt)"
            showAlertAlligned("Details", message: details, actions: ["Ok"]) { action in
                
            }
        }else{
            let isVisibleToServiceWorker = JSON(filesArray)[indexPath.row ]["viewFilePermission"].boolValue
            if isVisibleToServiceWorker {
            let imageurl = JSON(filesArray)[indexPath.row ]["url"].stringValue
            self.performSegue(withIdentifier: "segueToShowFile", sender: imageurl)
            }
        }
        
    }

}
