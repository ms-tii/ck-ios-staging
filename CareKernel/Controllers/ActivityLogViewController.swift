//
//  ActivityLogViewController.swift
//  CareKernel
//
//  Created by Mohit Sharma on 28/10/22.
//

import UIKit
import SwiftyJSON
import JGProgressHUD

class ActivityLogViewController: UIViewController {
    
    @IBOutlet weak var activityView: UIView!
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var startTimeValueLabel: UILabel!
    @IBOutlet weak var endTimeValueLabel: UILabel!
    @IBOutlet weak var clientButton: UIButton!
    @IBOutlet weak var categoryButton: UIButton!
    
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var activityTableView: UITableView!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet var dropDownBlackView: UIView!
    @IBOutlet var dropDownTableView: UITableView!
    @IBOutlet weak var notAccesibleLabel: UILabel!
    @IBOutlet weak var timeView: UIView!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var noRecordLabel: UILabel!
    
    let hud = JGProgressHUD()
    var tableArray = [[String:Any]]()
    var categoryArray = [[String:Any]]()
    var sessionId = 0
    var activityLogItems = NSMutableArray()
    var selectedDateType = String()
    var startTime = "00:00"
    var endTime = "00:00"
    var startTimestamp = String()
    var endTimestamp = String()
    var activityVM = ActivityViewModel()
    var descriptionString = String()
    var selectedCategoryId = Int()
    var numberOfRows = 0
    var clients = NSMutableArray()
    var nameArray = [[String:Any]]()
    var isCellSelected = Bool()
    var selectedCell = IndexPath()
    var dropDownType = String()
    var selectedValue = String()
    var isValueChanged = Bool()
    var selectedClientId = 0
    var selectedCategory = String()
    var selectedName = String()
    var namesId = [0]
    var headerTitle = String()
    var isKeyboardDismiss = Bool()
    var submitType = "Add"
    var selectedActivityID = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.dropDownBlackView.isHidden = true
        self.timeView.isHidden = true
        //        self.noRecordLabel.isHidden = true
        activityTableView.layoutMargins = UIEdgeInsets.zero
        activityTableView.separatorInset = UIEdgeInsets.zero
        self.scrollView.isHidden = true
    }
    
    @IBAction func startPickerButton(_ sender: UIButton) {
        datePicker.date = Date()
        startTime = "00:00"
        endTime = "00:00"
        selectedDateType = "Start"
        self.timeView.isHidden = false
    }
    
    @IBAction func endPickerButton(_ sender: UIButton) {
        endTime = "00:00"
        selectedDateType = "End"
        self.timeView.isHidden = false
    }
    
    @IBAction func addBUttonAction(_ sender: UIButton) {
        if submitType != "Edit" {
            saveNewActivity()
        }else{
            editActivity()
        }
        
    }
    func findIndex(Id : Int, Arr : [[String:Any]]) -> Int? {
        
        guard let index = Arr.firstIndex(where: {
            if let dic = $0 as? Dictionary<String,AnyObject> {
                if let value = dic["id"]  as? Int, value == Id {
                    return true
                }
            }
            return  false
        }) else { return nil }
        return index
    }
    
    @IBAction func clientButtonAction(_ sender: UIButton) {
        tableArray = nameArray
        let indexOfItem = self.nameArray.firstIndex(where: {_ in "name" == selectedName})
        let myindex = findIndex(Id: selectedClientId, Arr: tableArray)
        print(myindex ?? 0)
        self.selectedCell = IndexPath(row: myindex ?? 0, section: 0)
        self.isCellSelected = true
        headerTitle = "Clients"
        setTableHeader()
        
        dropDownType = "names"
        self.dropDownBlackView.isHidden = false
        self.dropDownTableView.reloadData()
        
    }
    @IBAction func categoryButtonAction(_ sender: UIButton) {
        tableArray = categoryArray
        let myindex = findIndex(Id: selectedCategoryId, Arr: tableArray)
        print(myindex ?? 0)
        self.selectedCell = IndexPath(row: myindex ?? 0, section: 0)
        self.isCellSelected = true
        headerTitle = "Category"
        setTableHeader()
        
        dropDownType = "category"
        self.dropDownBlackView.isHidden = false
        self.dropDownTableView.reloadData()
    }
    
    
    
    @IBAction func cancelButtonAction(_ sender: UIButton) {
        if selectedDateType == "Start" {
            startTime = "00:00"
            startTimestamp = ""
            
        }else{
            endTime = "00:00"
            endTimestamp = ""
        }
        self.timeView.isHidden = true
    }
    
    @IBAction func doneButtonAction(_ sender: UIButton) {
        if selectedDateType == "Start" {
            if startTime == "00:00" {
                let selectedTime = Date()
                self.setUITime(selected: selectedTime)
            }
        }else{
            if endTime == "00:00" {
                let selectedTime = Date()
                self.setUITime(selected: selectedTime)
            }
        }
        
        self.timeView.isHidden = true
    }
    
    @IBAction func pickerValueChanged(_ sender: UIDatePicker) {
        let selectedTime = datePicker.date
        self.setUITime(selected: selectedTime)
    }
    
    @IBAction func dropDownviewCloseButton(_ sender: UIButton) {
        self.dropDownBlackView.isHidden = true
    }
    
    func setUITime(selected: Date){
        let date = getFormattedDate(date: selected, format: "dd/MM/yyyy hh:mm a")
        print(date)
        let iso8601DateFormatter = ISO8601DateFormatter()
        iso8601DateFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        let dateString = iso8601DateFormatter.string(from: selected)
        if selectedDateType == "Start" {
            self.startTime = date
            self.startTimestamp = dateString
            self.startTimeValueLabel.text = "\(date)"
        }else{
            self.endTime = date
            self.endTimestamp = dateString
            self.endTimeValueLabel.text =  "\(date)"
        }
    }
    
    func setDetails() {
        nameArray.removeAll()
        clientButton.addBorderCorner(cornerRadius: 8, borderColor: UIColor(named: "Light Grey Font") ?? UIColor(), borderWidth: 1)
        categoryButton.addBorderCorner(cornerRadius: 8, borderColor: UIColor(named: "Light Grey Font") ?? UIColor(), borderWidth: 1)
        clientButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: (self.clientButton.bounds.width - 60), bottom: 0, right: 0)
        clientButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: (-10), bottom: 0, right: 0)
        categoryButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: (self.categoryButton.bounds.width - 60), bottom: 0, right: 0)
        categoryButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: (-10), bottom: 0, right: 0)
        self.dropDownBlackView.isHidden = true
        self.timeView.isHidden = true
        self.timeView.layer.borderWidth = 1
        self.timeView.layer.borderColor = UIColor(named: "Light Grey Font")?.cgColor
        self.view.isUserInteractionEnabled = false
        hud.show(in: self.view)
        clients.removeAllObjects()
        let clientData = Storage.readingFromDD(from: .documents, fileName: "clientLineDetails")
        let clientJson = try! JSON(data: clientData)
        let tempArr = JSON(clientJson).arrayValue
        if tempArr.count == 0 {// case of no clients and session type other
            self.notAccesibleLabel.isHidden = false
            self.hud.dismiss()
        }else{
            self.notAccesibleLabel.isHidden = true
        
        let defaultArr = ["id":0, "name":"Select"] as [String : Any]
        nameArray.append(defaultArr)
        for value in tempArr {
            self.clients.add(value)
            let name = JSON(value)["fullName"].stringValue
            let id = JSON(value)["id"].intValue
            let detailArr = ["id":id, "name":name] as [String : Any]
            nameArray.append(detailArr)
        }
        print(nameArray)
        if nameArray.count <= 2 {
            selectedCell = IndexPath(row: 1, section: 0)
            selectedName = JSON(nameArray)[selectedCell.row]["name"].stringValue
            self.clientButton.setTitle(selectedName.capitalized, for: .normal)
            selectedClientId = JSON(nameArray)[selectedCell.row]["id"].intValue
        }
        let sessionTime = careKernelDefaults.value(forKey: "sessionTime") as! [String:String]
        print(sessionTime)
        setDefaultTime(times: sessionTime)
        guard let token = careKernelDefaults.value(forKey: kLoginToken) as? String else {
            careKernelDefaults.set(false, forKey: kIsLoggedIn)
            return }
        activityVM.token = token
        getActivityLog()
    }
    }
    
    func setDefaultTime(times: [String:String]){
        let startAt = iso860ToString(dateString: JSON(times)["start"].stringValue)
        let startTime = getFormattedDate(date: startAt, format: "dd/MM/yyyy hh:mm a")
        let endAt = iso860ToString(dateString: JSON(times)["start"].stringValue).addingTimeInterval(5 * 60)
        let endTime = getFormattedDate(date: endAt, format: "dd/MM/yyyy hh:mm a")
        selectedDateType = "Start"
        setUITime(selected: startAt)
        selectedDateType = "End"
        setUITime(selected: endAt)
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
    
    func getActivityLog(refresh: Bool = false){
        if refresh {
            self.activityTableView.refreshControl?.beginRefreshing()
        }
        activityLogItems.removeAllObjects()
        activityVM.sessionId = self.sessionId
        activityVM.getActivityLogData { response, success in
            if success{
                DispatchQueue.main.async {
                    let tempArray = JSON(response)["data"].arrayValue
                    
                    if tempArray.count != 0 {
                        
                        for value in tempArray {
                            
                            self.activityLogItems.add(value)
                        }
                        print(self.activityLogItems)
                        self.noRecordLabel.isHidden = true
                        
                        
                    }else{
                        self.noRecordLabel.isHidden = false
                        self.activityTableView.isHidden = true
                    }
                    
                    self.activityTableView.refreshControl?.endRefreshing()
                    self.numberOfRows = 1
                    self.getActivityCategory()
                }
            }else{
                print(response)
                let statusCode = JSON(response)["statusCode"].intValue
                let message = JSON(response)["message"].stringValue
                self.showAlert("Error! \(statusCode)", message: message, actions: ["Ok"]) { (actionTitle) in
                    print(actionTitle)
                }
                self.hud.dismiss()
            }
            
        }
    }
    
    func getActivityCategory(){
        self.categoryArray.removeAll()
        activityVM.sessionId = self.sessionId
        activityVM.getActivityCategory { response, success in
            if success{
                DispatchQueue.main.async {
                    let tempArray = JSON(response)["data"].arrayValue
                    
                    if tempArray.count != 0 {
                        let defaultArr = ["id":0, "name":"Select"] as [String : Any]
                        self.categoryArray.append(defaultArr)
                        for value in tempArray {
                            
                            let name = JSON(value)["name"].stringValue
                            let id = JSON(value)["id"].intValue
                            let detailArr = ["id":id, "name":name] as [String : Any]
                            self.categoryArray.append(detailArr)
                        }
                        print(self.categoryArray)
                    }else{
                        
                    }
                    
                }
            }
            self.hud.dismiss()
            self.view.isUserInteractionEnabled = true
            self.activityTableView.reloadData()
            self.activityTableView.isHidden = false
            self.scrollView.isHidden = false
//            self.timeView.isHidden = true
//            self.datePicker.isHidden = true
        }
    }
    
    func saveNewActivity(){
        
        if descriptionString == "Add Text Here" || descriptionString == "" || selectedClientId == 0 || selectedCategoryId == 0{
            showAlert("CareKernel", message: "Fields cannot be empty.", actions: ["Ok"]) { result in
                
            }
        }else {
            
            let params : [String:Any] = [ "startTime": startTimestamp,
                                          "endTime": endTimestamp,
                                          "description": descriptionString,
                                          "clientId": selectedClientId,
                                          "activityLogCategoryId": selectedCategoryId,
                                          "sessionId": sessionId]
            activityVM.sessionId = self.sessionId
            activityVM.saveActivity(params: params) { response, success in
                if success {
                    print(response)
                    self.showAlert("CareKernel", message: "Created Successfully", actions: ["Ok"]) { (actionTitle) in
                        let sessionTime = careKernelDefaults.value(forKey: "sessionTime") as! [String:String]
                        print(sessionTime)
                        self.setDefaultTime(times: sessionTime)
//                        self.startTime = "00:00"
//                        self.endTime = "00:00"
//                        self.startTimestamp = ""
//                        self.endTimestamp = ""
                        self.descriptionString = "Add Text Here"
                        self.descriptionTextView.text = self.descriptionString
                        self.selectedCell = IndexPath(row: 0, section: 0)
                        self.selectedClientId = 0
                        self.selectedCategoryId = 0
                        self.clientButton.setTitle("Select", for: .normal)
                        self.categoryButton.setTitle("Select", for: .normal)
                        self.isKeyboardDismiss = true
                        self.resignFirstResponder()
                        self.view.endEditing(true)
                        self.getActivityLog()
                    }
                    
                }else{
                    print(response)
                    let statusCode = JSON(response)["statusCode"].intValue
                    let message = JSON(response)["message"].stringValue
                    self.showAlert("Error! \(statusCode)", message: message, actions: ["Ok"]) { (actionTitle) in
                        print(actionTitle)
                    }
                }
            }
        }
    }
    
    func editActivity(){
        
        if descriptionString == "Add Text Here" || descriptionString == "" || selectedClientId == 0 || selectedCategoryId == 0{
            showAlert("CareKernel", message: "Fields cannot be empty.", actions: ["Ok"]) { result in
                
            }
        }else {
            
            let params : [String:Any] = [ "startTime": startTimestamp,
                                          "endTime": endTimestamp,
                                          "description": descriptionString,
                                          "clientId": selectedClientId,
                                          "activityLogCategoryId": selectedCategoryId,
                                          "sessionId": sessionId]
            activityVM.sessionId = self.sessionId
            activityVM.editActivityLog(param: params, activityId: selectedActivityID) { response, success in
                if success {
                    self.showAlert("CareKernel", message: "Update Successfully", actions: ["Ok"]) { (actionTitle) in
                        print(response)
                        let sessionTime = careKernelDefaults.value(forKey: "sessionTime") as! [String:String]
                        print(sessionTime)
                        self.setDefaultTime(times: sessionTime)
                        self.startTime = "00:00"
                        self.endTime = "00:00"
                        self.startTimestamp = ""
                        self.endTimestamp = ""
                        self.descriptionString = "Add Text Here"
                        self.descriptionTextView.text = self.descriptionString
                        self.clientButton.setTitle("Select", for: .normal)
                        self.categoryButton.setTitle("Select", for: .normal)
                        self.selectedCell = IndexPath(row: 0, section: 0)
                        self.selectedClientId = 0
                        self.selectedCategoryId = 0
                        self.addButton.setTitle("Add", for: .normal)
                        self.submitType = "Add"
                        self.isKeyboardDismiss = true
                        self.resignFirstResponder()
                        self.view.endEditing(true)
                        self.getActivityLog()
                    }
                }else{
                    print(response)
                    let statusCode = JSON(response)["statusCode"].intValue
                    let message = JSON(response)["message"].stringValue
                    self.showAlert("Error! \(statusCode)", message: message, actions: ["Ok"]) { (actionTitle) in
                        print(actionTitle)
                    }
                }
            }
        }
    }
    
    func setTableHeader(){
        let header = UIView(frame: CGRect(x: 0, y: 0, width:dropDownTableView.frame.width, height: 70))
        //        header.backgroundColor = .red
        let titleLable = UILabel(frame: CGRect(x: 24, y: 30, width: 200, height: 21))
        titleLable.textColor = UIColor(named: "Basic Blue")
        titleLable.text = headerTitle
        header.addSubview(titleLable)
        let lineLable = UILabel(frame: CGRect(x: 0, y: header.frame.height - 1, width:header.frame.width, height: 1))
        lineLable.backgroundColor = UIColor(named: "Light Grey Font")
        header.addSubview(lineLable)
        header.backgroundColor = UIColor(named: "Home calendertable cell")
        dropDownTableView.tableHeaderView = header
    }
    
    func handleSwipe(indexPath: IndexPath, action: String){
        selectedActivityID = JSON(activityLogItems)[indexPath.row]["id"].intValue
        
        let startTime = JSON(activityLogItems)[indexPath.row]["startTime"].stringValue
        
        
        let endTime = JSON(activityLogItems)[indexPath.row]["endTime"].stringValue
       
        
        let activityLogCategory = JSON(activityLogItems)[indexPath.row]["activityLogCategory"].dictionaryValue
        let user = JSON(activityLogItems)[indexPath.row]["user"].dictionaryValue
        let categoryName = JSON(activityLogCategory)["name"].stringValue.capitalized
        let supportWorker = JSON(user)["fullName"].stringValue.capitalized
        let description = JSON(activityLogItems)[indexPath.row]["description"].stringValue.capitalized
        
        self.descriptionString = description
        self.selectedClientId = JSON(activityLogItems)[indexPath.row]["clientId"].intValue
        self.selectedCategoryId = JSON(activityLogCategory)["id"].intValue
        
        if action == "Edit" {
//            self.startTimeValueLabel.text = startTimeString
//            self.endTimeValueLabel.text = endTimeString
            selectedDateType = "Start"
            setUITime(selected: iso860ToString(dateString: startTime))
            selectedDateType = "End"
            setUITime(selected: iso860ToString(dateString: endTime))
            
            self.categoryButton.setTitle(categoryName, for: .normal)
            self.descriptionTextView.text = description
            let myindex = findIndex(Id: selectedClientId, Arr: nameArray)
            let clientName = JSON(nameArray)[myindex ?? 0]["name"].stringValue
            self.clientButton.setTitle(clientName, for: .normal)
            self.addButton.setTitle("Update", for: .normal)
            self.submitType = "Edit"
        }else{
            activityVM.deleteAllowance(activityId: selectedActivityID) { response, success in
                if success {
                    self.showAlert("CareKernel", message: "Successfully deleted", actions: ["Ok"]) { action in
                        if action == "Ok" {
                            self.getActivityLog()
                        }
                    }
                }else{
                    print(response)
                    let statusCode = JSON(response)["statusCode"].intValue
                    let message = JSON(response)["message"].stringValue
                    self.showAlert("Error! \(statusCode)", message: message, actions: ["Ok"]) { (actionTitle) in
                        print(actionTitle)
                    }
                }
            }
        }
        
    }
    
    @objc func didTapView(_ sender: UITapGestureRecognizer) {
        isKeyboardDismiss = true
        self.resignFirstResponder()
        view.endEditing(true)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        isKeyboardDismiss = true
        self.resignFirstResponder()
        view.endEditing(true)
        
    }
}

extension ActivityLogViewController : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if tableView == self.activityTableView {
            return 178
        }else{
            return 50
        }
        
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if tableView == self.activityTableView {
            return activityLogItems.count
        }else{
            return tableArray.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if tableView == self.activityTableView {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ActivityLogCell", for: indexPath) as! ActivityLogCell
            
            let startTime = JSON(activityLogItems)[indexPath.row]["startTime"].stringValue
            let startTimeString = getFormattedDate(date: iso860ToString(dateString: startTime), format: "dd/MM/yyyy hh:mm a")
            let endTime = JSON(activityLogItems)[indexPath.row]["endTime"].stringValue
            let endTimeString = getFormattedDate(date: iso860ToString(dateString: endTime), format: "dd/MM/yyyy hh:mm a")
            let activityLogCategory = JSON(activityLogItems)[indexPath.row]["activityLogCategory"].dictionaryValue
            let supportWorker = JSON(activityLogItems)[indexPath.row]["user"].dictionaryValue
            cell.startTimeLabel.text = startTimeString
            cell.endTimeLabel.text = endTimeString
            cell.categoryLabel.text = JSON(activityLogCategory)["name"].stringValue.capitalized
            cell.supportWorkerLabel.text = JSON(supportWorker)["fullName"].stringValue.capitalized
            cell.descriptionLabel.text = JSON(activityLogItems)[indexPath.row]["description"].stringValue.capitalized
            
            return cell
        }else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "DropDownCell", for: indexPath) as! DropDownCell
            
            cell.nameLabel.text = JSON(tableArray)[indexPath.row]["name"].stringValue.capitalized
            cell.tickImage.image = nil
            if isCellSelected && selectedCell == indexPath{
                cell.tickImage.image = #imageLiteral(resourceName: "tick")
                cell.nameLabel.textColor = UIColor(named: "Calender Font color")
            }else{
                cell.tickImage.image = nil
                cell.nameLabel.textColor = UIColor(named: "Light Grey Font")
            }
            
            
            return cell
            
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == dropDownTableView {
            selectedCell = indexPath
            selectedValue = JSON(tableArray)[indexPath.row]["name"].stringValue
            switch dropDownType {
            case "names":
                if selectedValue != self.clientButton.title(for: .normal){
                    self.clientButton.setTitle(selectedValue.capitalized, for: .normal)
                    isValueChanged = true
                    selectedClientId = JSON(tableArray)[indexPath.row]["id"].intValue
                    selectedName = selectedValue
                }
                break
            case "category":
                
                if selectedValue != self.categoryButton.title(for: .normal){
                    self.categoryButton.setTitle(selectedValue, for: .normal)
                    isValueChanged = true
                    selectedCategory = selectedValue
                    selectedCategoryId = JSON(tableArray)[indexPath.row]["id"].intValue
                }
                break
            default:
                isValueChanged = false
                break
            }
            isCellSelected = true
            dropDownTableView.reloadData()
            dropDownBlackView.isHidden = true
        }
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        selectedCell = indexPath
        if tableView == self.activityTableView {
            let swipeEditAction = UIContextualAction(style: .normal, title: "Edit") { [weak self] (action, view, completionHandler) in
                
                self?.handleSwipe(indexPath: indexPath, action: "Edit")
                completionHandler(true)
            }
            swipeEditAction.backgroundColor = UIColor(named: "Swipe yellow")
            let swipeDeleteAction = UIContextualAction(style: .normal, title: "Delete") { [weak self] (action, view, completionHandler) in
                self?.handleSwipe(indexPath: indexPath, action: "Delete")
                completionHandler(true)
            }
            swipeDeleteAction.backgroundColor = UIColor.red
            
            
            return UISwipeActionsConfiguration(actions: [swipeDeleteAction,swipeEditAction])
        }else{
            return nil
        }
        
    }
}

extension ActivityLogViewController : UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView == descriptionTextView {
            if textView.text == "Add Text Here"{
                textView.text = ""
            }
        }
    }
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView == descriptionTextView {
            if textView.text == ""{
                textView.text = "Add Text Here"
            }
        }
        if !isKeyboardDismiss {
            self.resignFirstResponder()
        }
        isKeyboardDismiss = false
    }
    
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        return true
    }
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool{
        if textView == descriptionTextView{
            if text == "\n" {
                isKeyboardDismiss = false
                textView.resignFirstResponder()
                return false
            }
        }
        return true
    }
    func textViewDidChange(_ textView: UITextView) {
        if textView == descriptionTextView{
            descriptionString = textView.text
        }
    }
}

class ActivityLogCell : UITableViewCell {
    @IBOutlet weak var startTimeLabel: UILabel!
    @IBOutlet weak var endTimeLabel: UILabel!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var supportWorkerLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    
}
