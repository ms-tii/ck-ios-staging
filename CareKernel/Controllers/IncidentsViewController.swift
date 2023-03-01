//
//  IncidentsViewController.swift
//  CareKernel
//
//  Created by Mohit Sharma on 13/12/21.
//

import UIKit
import SwiftyJSON

class IncidentsViewController: UIViewController {

    @IBOutlet var incidentsTableView: UITableView!
    
    @IBOutlet var noRecordLable: UILabel!
    
    
    
    var clientId = 0
    var incidentsArray = NSMutableArray()
    var heightForRow = 0.0
    var fromDate = ""
    var toDate = ""
    var selectedDateType = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        noRecordLable.isHidden = true
        incidentsTableView.register(IncidentHeaderCell.nib(), forHeaderFooterViewReuseIdentifier: "IncidentHeaderCell")
        incidentsTableView.register(IncidentFIlterCell.nib(), forCellReuseIdentifier: "IncidentFIlterCell")
        if #available(iOS 15.0, *) {
            incidentsTableView.sectionHeaderTopPadding = 0
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        clientId = careKernelDefaults.value(forKey: "clientID") as! Int
        
        if let isHaveValue = careKernelDefaults.value(forKey: "incidentsFilterDate") as? [String:String] {
            
            fromDate = JSON(isHaveValue)["fromDate"].stringValue
            toDate = JSON(isHaveValue)["toDate"].stringValue
            if fromDate == ""{
                fromDate = "From"
            }
            if toDate == "" {
                toDate = "To"
            }
            heightForRow = 128.0
            self.incidentsTableView.reloadData()
            
        }else{
            fromDate = "From"
            toDate = "To"
            DispatchQueue.main.asyncAfter(deadline: .now() + 0) {
                self.fetchData(fromDate: "", toDate: "")
            }
            
        }
        
        
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
    }
    
    func fetchData(fromDate: String, toDate: String){
        incidentsArray.removeAllObjects()
        var incidentVM = IncidentViewModel()
        guard let token = careKernelDefaults.value(forKey: kLoginToken) as? String else {
            careKernelDefaults.set(false, forKey: kIsLoggedIn)
            return }
        incidentVM.token = token
        incidentVM.clientId = self.clientId
        incidentVM.getClientIncidentList(fromDate: fromDate, toDate: toDate) { response, success in
            if success {
                print(response)
                DispatchQueue.main.async {
                    let tempArray = JSON(response)["data"].arrayValue
                    if tempArray.count != 0 {
                        self.incidentsTableView.isHidden = false
                        self.noRecordLable.isHidden = true
                        for value in tempArray {
                            self.incidentsArray.add(value)
                        }
                        
                        self.noRecordLable.isHidden = true
                        
                        self.incidentsTableView.reloadData()
                    }else{
                        
                        self.noRecordLable.isHidden = false
                        self.incidentsTableView.reloadData()
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
                }else{
                    self.showAlert("Error! \(statusCode)", message: message, actions: ["Ok"]) { (actionTitle) in
                        print(actionTitle)
                    }
                }
                
                
            }
        }
        
    }

    @objc func addIncidentsAction(){

//        guard let token = careKernelDefaults.value(forKey: kLoginToken) as? String else {
//            careKernelDefaults.set(false, forKey: kIsLoggedIn)
//            return }
//        let url = "https://staging.carekernel.net/incidents-responsive/?token=" + token
//        let title = "Add Incident"
//        let param : [String:String] = ["urlString": url, "title": title]
//        self.performSegue(withIdentifier: "segueToIncidentWebView", sender: param)
        self.addEditIncidentMethod(type: "Add")
    }
    
    func addEditIncidentMethod(id: Int = 0,type: String ){
        guard let token = careKernelDefaults.value(forKey: kLoginToken) as? String else {
            careKernelDefaults.set(false, forKey: kIsLoggedIn)
            return }
        var url = String()
        var title = String()
        if type == "Add"{
            url = "https://staging.carekernel.net/incidents-responsive/?token=" + token
            title = "Add Incident"
        }else{
            url = "https://staging.carekernel.net/incidents-responsive/" + "\(id)?token="  + token
            title = "Edit Incident"
        }
        
        let param : [String:String] = ["urlString": url, "title": title]
        DispatchQueue.main.async {
            self.performSegue(withIdentifier: "segueToIncidentWebView", sender: param)
        }
        
    }
    
    @objc func addfilterButtonAction(){
        fromDate = "From"
        toDate = "To"
        heightForRow = 128.0
        self.incidentsTableView.reloadData()
    }
    
    @objc func fromButtonAction(){
        selectedDateType = "From"
        self.performSegue(withIdentifier: "segueToIncidentFilter", sender: "from")
    }
    
    @objc func toButtonAction(){
        selectedDateType = "To"
        self.performSegue(withIdentifier: "segueToIncidentFilter", sender: "to")

    }
    
    @objc func applyButtonAction(){
        if (self.fromDate != "From" && self.toDate == "To") {
            self.showAlert("Alert!", message: "Please select 'To date'", actions: ["Ok"]) { actionTitle in
                
            }
        }else if (self.fromDate == "From") {
            self.showAlert("Alert!", message: "Please select 'From date'", actions: ["Ok"]) { actionTitle in
                
            }
        }else{
            let dateFormatter = DateFormatter()
                    dateFormatter.dateStyle = DateFormatter.Style.long
                    dateFormatter.dateFormat = "dd/MM/yyyy"
            let convertedFromDate = dateFormatter.date(from: fromDate) ?? Date()
            let convertedToDate = dateFormatter.date(from: toDate) ?? Date()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            let convertedFromDateStr = dateFormatter.string(from: convertedFromDate)
            let convertedToDateStr = dateFormatter.string(from: convertedToDate)
            fetchData(fromDate: convertedFromDateStr, toDate: convertedToDateStr)
        }
            
        
    }
    
    @objc func clearButtonAction(){
        fromDate = "From"
        toDate = "To"
        heightForRow = 0.0
        fetchData(fromDate: "", toDate: "")
    }
    
    func hexStringToUIColor (hex:String) -> UIColor {
        var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()

        if (cString.hasPrefix("#")) {
            cString.remove(at: cString.startIndex)
        }

        if ((cString.count) != 6) {
            return UIColor.gray
        }

        var rgbValue:UInt64 = 0
        Scanner(string: cString).scanHexInt64(&rgbValue)

        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
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
    
    // MARK: - Navigation

     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
         
         if let vc = segue.destination as? AddIncidentViewController {
             vc.incidentsArray = sender as! [String:Any]
         }else if let vc = segue.destination as? IncidentFilterViewController {
             if selectedDateType == "From"{
                 vc.fromDate = fromDate
             }else{
                 vc.fromDate = fromDate
                 vc.toDate = toDate
             }
             vc.selectedDateType = selectedDateType
         }else if let vc = segue.destination as? IncidentWebViewController {
             vc.params = sender as! [String:String]
         }
     }
    
}
extension IncidentsViewController : UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        2
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
            return UITableView.automaticDimension
        }

    func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 66
        }else{
            return 0
        }
    }
    

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 1 {
            return UITableViewCell()
        }else{
        
            guard let cell = tableView.dequeueReusableHeaderFooterView(withIdentifier: "IncidentHeaderCell") as? IncidentHeaderCell else {
              return nil
              }
            cell.addIncidentsButton.addTarget(self, action: #selector(addIncidentsAction), for: .touchUpInside)
            cell.filterButton.addTarget(self, action: #selector(addfilterButtonAction), for: .touchUpInside)
            return cell
        }
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        }else{
        return self.incidentsArray.count
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return heightForRow
        }else{
            return 250
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            
        
        if indexPath.section == 0 {
            let celll = tableView.dequeueReusableCell(withIdentifier: "IncidentFIlterCell", for: indexPath) as! IncidentFIlterCell
                    
            celll.fromButton.setTitle(fromDate, for: .normal)
            celll.toButton.setTitle(toDate, for: .normal)
            celll.fromButton.addTarget(self, action: #selector(fromButtonAction), for: .touchUpInside)
            celll.toButton.addTarget(self, action: #selector(toButtonAction), for: .touchUpInside)
            celll.clearButton.addTarget(self, action: #selector(clearButtonAction), for: .touchUpInside)
            celll.applyButton.addTarget(self, action: #selector(applyButtonAction), for: .touchUpInside)
            return celll
        }else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "IncidentCell", for: indexPath) as! IncidentCell
        cell.separatorInset = .zero
            cell.idLabel.text = JSON(incidentsArray)[indexPath.row ]["displayId"].stringValue
            cell.categoryLabel.text = JSON(incidentsArray)[indexPath.row ]["category"]["name"].stringValue
            let siteName = JSON(incidentsArray)[indexPath.row ]["site"]["name"].stringValue
            if siteName == "" {
                cell.dsiteLabel.text = "NA"
            }else{
                cell.dsiteLabel.text =  siteName.capitalized
            }
            
            cell.reportedByLabel.text = JSON(incidentsArray)[indexPath.row ]["creator"]["fullName"].stringValue.capitalized
            let isNDIS = JSON(incidentsArray)[indexPath.row ]["isReportableToNdis"].boolValue
            if isNDIS {
                cell.isNDISLabel.text = "True"
            }else{
                cell.isNDISLabel.text = "NA"
            }
            let observationDate = JSON(incidentsArray)[indexPath.row ]["observationDate"].stringValue
            let observationDateString = getFormattedDate(date: iso860ToString(dateString: observationDate), format: "dd/MM/yyyy")
            cell.observationDate.text = observationDateString
            let priority = JSON(incidentsArray)[indexPath.row ]["priority"].stringValue
            if priority != "" {
                cell.priorityLabel.text = priority.capitalized
                
            }else{
                cell.priorityLabel.text = "NA"
            }
            let badgeView = UIView()
            badgeView.layer.cornerRadius = 4
            cell.priorityLabel.addSubview(badgeView)
            badgeView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                badgeView.rightAnchor.constraint(equalTo: cell.priorityLabel.leftAnchor, constant: -4),
                badgeView.topAnchor.constraint(equalTo: cell.priorityLabel.topAnchor, constant: 5),
                badgeView.heightAnchor.constraint(equalToConstant: badgeView.layer.cornerRadius*2),
                badgeView.widthAnchor.constraint(equalToConstant: badgeView.layer.cornerRadius*2)
            ])
            switch priority {
            case "low":
                let greenColor = hexStringToUIColor(hex: "#3CBE91")
                badgeView.backgroundColor = greenColor
                break
            case "medium":
                let yellowColor = hexStringToUIColor(hex: "#FFBA38")
                badgeView.backgroundColor = yellowColor
                break
            case "high":
                let redColor = hexStringToUIColor(hex: "#FF5063")
                badgeView.backgroundColor = redColor
                break
            default:
                badgeView.backgroundColor = UIColor(named: "Home calendertable cell")
            }
            if incidentsArray.count-1 == indexPath.row {
                cell.clipsToBounds = true
                cell.layer.cornerRadius = 8
                cell.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
            }
            cell.attachmentIcon.isHidden = true
            let attachedFiles = JSON(incidentsArray)[indexPath.row ]["files"].arrayValue
            
            if attachedFiles.count > 0 {
                cell.attachmentIcon.isHidden = false
            }
            
            return cell
        }
            
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.section == 0 {
            heightForRow = 0.0
            self.incidentsTableView.reloadData()
        }else{

            let id = JSON(incidentsArray)[indexPath.row ]["id"].intValue
            self.addEditIncidentMethod(id: id, type: "Edit")
        }
        
    }

//    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
//        let swipeAction = UIContextualAction(style: .normal, title: "View/Edit") { [weak self] (action, view, completionHandler) in
//                                            self?.handleMoveToViewIncident()
//                                            completionHandler(true)
//        }
//        swipeAction.backgroundColor = UIColor(named: "Swipe yellow")
//        return UISwipeActionsConfiguration(actions: [swipeAction])
//    }
}

class IncidentCell: UITableViewCell {
    @IBOutlet var idLabel: UILabel!
    @IBOutlet var categoryLabel: UILabel!
    @IBOutlet var dsiteLabel: UILabel!
    @IBOutlet weak var observationDate: UILabel!
    @IBOutlet weak var priorityLabel: UILabel!
    @IBOutlet weak var reportedByLabel: UILabel!
    @IBOutlet weak var attachmentIcon: UIImageView!
    @IBOutlet weak var isNDISLabel: UILabel!
    
}
