//
//  MedicinesViewController.swift
//  CareKernel
//
//  Created by Mohit Sharma on 27/11/21.
//

import UIKit
import SwiftyJSON
import JGProgressHUD

class MedicinesViewController: UIViewController {

    @IBOutlet var medicinesTableView: UITableView!
    @IBOutlet var noRecordsLabel: UILabel!
    
    var clientDetailsVM = ClientDetailsViewModel()
    var clientId = 0
    var medicinesArray = NSMutableArray()
    var filesArray = NSMutableArray()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        noRecordsLabel.isHidden = true
        medicinesTableView.register(CasenotesHeaderCell.nib(), forHeaderFooterViewReuseIdentifier: "CasenotesHeaderCell")
        medicinesTableView.register(ClientFilesCell.nib(), forCellReuseIdentifier: "ClientFilesCell")
        
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
        self.medicinesTableView.refreshControl = UIRefreshControl()
        self.medicinesTableView.refreshControl?.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        
    }
    
    @objc private func refreshData(){
        print("Refreshed")
        self.fetchData()
    }


    func fetchData(){
        medicinesArray.removeAllObjects()
        guard let token = careKernelDefaults.value(forKey: kLoginToken) as? String else {
            careKernelDefaults.set(false, forKey: kIsLoggedIn)
            return }
        clientDetailsVM.getClientMedicines(clientID: "\(clientId)", token: token) { response, success in
            if success {
                DispatchQueue.main.async {
                    let tempArray = JSON(response)["data"].arrayValue
                    if tempArray.count != 0 {
                        for value in tempArray {
                            self.medicinesArray.add(value)
                        }
                        
                        
                        self.clientDetailsVM.getClientFiles(entity: "medications", clientID: "\(self.clientId)", token: token) { response2, success2 in
                            if success2 {
                                self.filesArray.removeAllObjects()
                                let tempFileArray = JSON(response2)["data"].arrayValue
                                if tempFileArray.count != 0 {
                                    for file in tempFileArray {
                                        self.filesArray.add(file)
                                    }
                                    
                                    self.medicinesTableView.reloadData()
                                }
                            }
                        }
                        self.noRecordsLabel.isHidden = true
                        self.medicinesTableView.reloadData()
                    }else{
                        self.noRecordsLabel.isHidden = false
                        self.medicinesTableView.isHidden = true
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
            self.medicinesTableView.refreshControl?.endRefreshing()
        }
        
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let vc = segue.destination as? FilesImageViewController {
            vc.imageurlString = sender as! String
        }
    }
}

extension MedicinesViewController : UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        2
    }
    
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
        if section == 0 {
            cell.headerTitleLabel.text = "Medicines"
            cell.iconImageView.image = UIImage(named: "icon-medicines")
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
            return medicinesArray.count
        }else{
            return filesArray.count
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0{
            let cell = tableView.dequeueReusableCell(withIdentifier: "MedicineCell", for: indexPath) as! MedicineCell
            
            cell.nameLabel.text = JSON(medicinesArray)[indexPath.row ]["medicineName"].stringValue
            cell.frequencyLabel.text = JSON(medicinesArray)[indexPath.row ]["frequency"].stringValue
            cell.doseLabel.text = JSON(medicinesArray)[indexPath.row ]["dose"].stringValue
            if medicinesArray.count-1 == indexPath.row {
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
//            let arrString = String()
            let medName = "Name - " + JSON(medicinesArray)[indexPath.row ]["medicineName"].stringValue
            let frequencyName = "Frequency - " + JSON(medicinesArray)[indexPath.row ]["frequency"].stringValue
            let doseName = "Dose - " + JSON(medicinesArray)[indexPath.row ]["dose"].stringValue
            let details = "\(medName) \n\(frequencyName) \n\(doseName)"
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

class MedicineCell: UITableViewCell {
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var frequencyLabel: UILabel!
    @IBOutlet var doseLabel: UILabel!
}

