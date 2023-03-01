//
//  MedicalDetailsViewController.swift
//  CareKernel
//
//  Created by Mohit Sharma on 28/11/21.
//

import UIKit
import SwiftyJSON

class MedicalDetailsViewController: UIViewController {

    @IBOutlet var medicalDetailsTable: UITableView!
    @IBOutlet var noRecordsLabel: UILabel!
    
    var clientDetailsVM = ClientDetailsViewModel()
    var clientId = 0
    var medicalDetailsArray = NSMutableArray()
    var medicalTitleArray = ["Primary Disability","Secondary Disability","Health Support Level","Hearing","Other Health Issues","Date of Diagonse","Medical Condition Level","Vision","Summary Disability"]
    override func viewDidLoad() {
        super.viewDidLoad()
        noRecordsLabel.isHidden = true
        medicalDetailsTable.register(CasenotesHeaderCell.nib(), forHeaderFooterViewReuseIdentifier: "CasenotesHeaderCell")
        
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
        self.medicalDetailsTable.refreshControl = UIRefreshControl()
        self.medicalDetailsTable.refreshControl?.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        
    }
    
    @objc private func refreshData(){
        print("Refreshed")
        self.fetchData()
    }
    
    func fetchData(){
        medicalDetailsArray.removeAllObjects()
        guard let token = careKernelDefaults.value(forKey: kLoginToken) as? String else {
            careKernelDefaults.set(false, forKey: kIsLoggedIn)
            return }
        clientDetailsVM.getClientMedicalDetails(clientID: "\(clientId)", token: token) { response, success in
            if success {
                DispatchQueue.main.async {
                    let tempArray = JSON(response)["data"].arrayValue
                    if tempArray.count != 0 {
                        for value in tempArray {
                            self.medicalDetailsArray.add(value)
                        }
                        self.noRecordsLabel.isHidden = true
                        self.medicalDetailsTable.reloadData()
                    }else{
                        self.noRecordsLabel.isHidden = false
                        self.medicalDetailsTable.isHidden = true
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
            self.medicalDetailsTable.refreshControl?.endRefreshing()
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
}

class MedicalDetailsCell : UITableViewCell {
    
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var nameLabel: UILabel!
}

extension MedicalDetailsViewController : UITableViewDelegate, UITableViewDataSource {
    
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
        cell.headerTitleLabel.text = "Medical Details"
        cell.iconImageView.image = UIImage(named: "icon disability")
        cell.clipsToBounds = true
        cell.layer.cornerRadius = 8
        cell.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
          return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        medicalTitleArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MedicalDetailsCell", for: indexPath) as! MedicalDetailsCell
        
        let titleName = medicalTitleArray[indexPath.row]
        cell.titleLabel.text = titleName
        switch titleName {
        case "Primary Disability" :
            let primaryDisabilities = JSON(medicalDetailsArray)[0]["primaryDisabilities"].arrayValue
            var primaryDisabilitiesNamesArr = [""]
            primaryDisabilitiesNamesArr.removeAll()
            for value in primaryDisabilities{
                primaryDisabilitiesNamesArr.append(value["name"].rawValue as! String)
            }
            let primaryDisabilitiesString = primaryDisabilitiesNamesArr.joined(separator: ", ")
            cell.nameLabel.text = primaryDisabilities.count == 0 ? "NA" : primaryDisabilitiesString
            break
        case "Secondary Disability" :
            let secondaryDisability = JSON(medicalDetailsArray)[0]["secondaryDisabilities"].arrayValue
            var secondaryDisabilityNamesArr = [""]
            secondaryDisabilityNamesArr.removeAll()
            for value in secondaryDisability{
                secondaryDisabilityNamesArr.append(value["name"].rawValue as! String)
            }
            let secondaryDisabilityString = secondaryDisabilityNamesArr.joined(separator: ", ")
            cell.nameLabel.text = secondaryDisability.count == 0 ? "NA" : secondaryDisabilityString
            break
        case "Health Support Level" :
            let healthSupportLevel = JSON(medicalDetailsArray)[0]["healthSupportLevel"].stringValue.capitalized
            cell.nameLabel.text = healthSupportLevel == "" ? "NA" : healthSupportLevel
            break
        case "Hearing" :
            let hearing = JSON(medicalDetailsArray)[0]["hearing"].stringValue
            cell.nameLabel.text = hearing == "" ? "NA" : hearing
            break
        case "Other Health Issues" :
            let otherHealthIssues = JSON(medicalDetailsArray)[0]["otherHealthIssues"].stringValue
            cell.nameLabel.text = otherHealthIssues == "" ? "NA" : otherHealthIssues
            break
        case "Date of Diagonse" :
            let diagnosedAt = JSON(medicalDetailsArray)[0]["diagnosedAt"].stringValue
            let dateOfDiagnose = getFormattedDate(date: iso860ToString(dateString: diagnosedAt), format: "dd/mm/yyyy")
                                                           
            cell.nameLabel.text = diagnosedAt == "" ? "NA" : dateOfDiagnose
            break
        case "Medical Condition Level" :
            let medicalConditionLevelArr = JSON(medicalDetailsArray)[0]["medicalConditions"].arrayValue
            var medicalConditionArr = [""]
            medicalConditionArr.removeAll()
            for value in medicalConditionLevelArr{
                medicalConditionArr.append(value["name"].rawValue as! String)
            }
            let medicalConditionLevelString = medicalConditionArr.joined(separator: ", ")
            cell.nameLabel.text = medicalConditionLevelArr.count == 0 ? "NA" : medicalConditionLevelString
            break
        case "Vision" :
            let vision = JSON(medicalDetailsArray)[0]["vision"].stringValue
            cell.nameLabel.text = vision == "" ? "NA" : vision
            break
        case "Summary Disability" :
            let summaryDisability = JSON(medicalDetailsArray)[0]["summaryDisability"]["name"].stringValue
            cell.nameLabel.text = summaryDisability == "" ? "NA" : summaryDisability
            break
        default : break
        }

        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let titleName = medicalTitleArray[indexPath.row]
        var details = String()
        switch titleName {
        case "Primary Disability" :
            let primaryDisability = JSON(medicalDetailsArray)[0]["primaryDisability"]["name"].stringValue
            let primaryString = primaryDisability == "" ? "NA" : primaryDisability
            details = "\(titleName) - \(primaryString)"
            
        case "Secondary Disability" :
            let secondaryDisability = JSON(medicalDetailsArray)[0]["secondaryDisabilities"].arrayValue
            var secondaryDisabilityNamesArr = [""]
            secondaryDisabilityNamesArr.removeAll()
            for value in secondaryDisability{
                secondaryDisabilityNamesArr.append(value["name"].rawValue as! String)
            }
            let secondaryDisabilityString = secondaryDisabilityNamesArr.joined(separator: ", ")
            let secondaryString = secondaryDisability.count == 0 ? "NA" : secondaryDisabilityString
            details = "\(titleName) - \(secondaryString)"
            
        case "Health Support Level" :
            let healthSupportLevel = JSON(medicalDetailsArray)[0]["healthSupportLevel"].stringValue
            let healthSupportString = healthSupportLevel == "" ? "NA" : healthSupportLevel
            details = "\(titleName) - \(healthSupportString)"
            
        case "Hearing" :
            let hearing = JSON(medicalDetailsArray)[0]["hearing"].stringValue
            let hearingString = hearing == "" ? "NA" : hearing
            details = "\(titleName) - \(hearingString)"
            
        case "Other Health Issues" :
            let otherHealthIssues = JSON(medicalDetailsArray)[0]["otherHealthIssues"].stringValue
            let otherString = otherHealthIssues == "" ? "NA" : otherHealthIssues
            details = "\(titleName) - \(otherString)"
            
        case "Date of Diagonse" :
            let diagnosedAt = JSON(medicalDetailsArray)[0]["diagnosedAt"].stringValue
            let dateOfDiagnose = getFormattedDate(date: iso860ToString(dateString: diagnosedAt), format: "dd/mm/yyyy")
                                                           
            let diagnoseString = diagnosedAt == "" ? "NA" : dateOfDiagnose
            details = "\(titleName) - \(diagnoseString)"
            
        case "Medical Condition Level" :
            let medicalConditionLevelArr = JSON(medicalDetailsArray)[0]["medicalConditions"].arrayValue
            var medicalConditionArr = [""]
            medicalConditionArr.removeAll()
            for value in medicalConditionLevelArr{
                medicalConditionArr.append(value["name"].rawValue as! String)
            }
            let medicalConditionLevelString = medicalConditionArr.joined(separator: ", ")
            let conditionString = medicalConditionLevelArr.count == 0 ? "NA" : medicalConditionLevelString
            details = "\(titleName) - \(conditionString)"
            
        case "Vision" :
            let vision = JSON(medicalDetailsArray)[0]["vision"].stringValue
            let visionString = vision == "" ? "NA" : vision
            details = "\(titleName) - \(visionString)"
            
        case "Summary Disability" :
            let summaryDisability = JSON(medicalDetailsArray)[0]["summaryDisability"]["name"].stringValue
            let summaryString = summaryDisability == "" ? "NA" : summaryDisability
            details = "\(titleName) - \(summaryString)"
            
        default : break
        }
        showAlertAlligned("Details", message: details, actions: ["Ok"]) { action in
            
        }
    }

}
