//
//  AllowancesViewController.swift
//  CareKernel
//
//  Created by Mohit Sharma on 11/04/22.
//

import UIKit
import SwiftyJSON

class AllowancesViewController: UIViewController {
    
    @IBOutlet weak var noRecordsLabel: UILabel!
    @IBOutlet weak var allowanceView: UIView!
    @IBOutlet weak var travelView: UIView!

    @IBOutlet weak var kmTextView: UITextView!
    @IBOutlet weak var travelLogTextView: UITextView!
    @IBOutlet weak var addTransportButton: UIButton!
    
    @IBOutlet var dropDownBlackView: UIView!
    @IBOutlet var dropDownTableView: UITableView!
    
    @IBOutlet weak var allowancesTableView: UITableView!
    @IBOutlet weak var wakeupTableView: UITableView!
    @IBOutlet weak var timeView: UIView!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var noRecordLabel: UILabel!
    
    @IBOutlet weak var notClaimableLabel: UILabel!
    
    var allowancesItems = NSMutableArray()
    var sessionAllowances = NSMutableArray()
    var wakeupTimesList = NSMutableArray()
    var allowancesVM = AllowancesViewModel()
    var travelKm = String()
    var travelLog = String()
    var allowanceId = Int()
    var amountUnit = Float()
    var isKeyboardDismiss = Bool()
    var sessionId = 0
    var isCellSelected = Bool()
    var selectedCell = IndexPath()
    var unitType = "$"
    var selectedSessionAllowanceId = 0
    var selectedDateType = String()
    var startTime = "00:00"
    var endTime = "00:00"
    var wakeupReason = "Reason"
    var numberOfRows = 1
    var startTimestamp = String()
    var endTimestamp = String()
    var wakeupTimeId = Int()
    var submitType = "Save"
    var tabStatusDelegate : TabStatusDelegate?
    var workerID = Int()
    var isTravelValue = false
    var isTravelClaimable = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.dropDownBlackView.isHidden = true
        self.timeView.isHidden = true
        allowancesTableView.layoutMargins = UIEdgeInsets.zero
        allowancesTableView.separatorInset = UIEdgeInsets.zero
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTapView(_:)))
        let tapGestureRecognizer2 = UITapGestureRecognizer(target: self, action: #selector(didTapView(_:)))

        allowanceView.addGestureRecognizer(tapGestureRecognizer)
        travelView.addGestureRecognizer(tapGestureRecognizer2)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name:UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name:UIResponder.keyboardWillHideNotification, object: nil)
        setupTextFields()
        wakeupTableView.register(WakeupTableViewCell.nib(), forCellReuseIdentifier: "WakeupTableViewCell")
        guard let sessionWorkerId = careKernelDefaults.value(forKey: kUserId) as? Int else {
            careKernelDefaults.set(false, forKey: kIsLoggedIn)
            return ()
        }
        self.workerID = sessionWorkerId
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    @objc func didTapView(_ sender: UITapGestureRecognizer) {
        isKeyboardDismiss = true
        self.resignFirstResponder()
        view.endEditing(true)
    }
    
    @IBAction func dropDownviewCloseButton(_ sender: UIButton) {
        self.dropDownBlackView.isHidden = true
    }
    
    @IBAction func doneButtonAction(_ sender: UIButton) {
        print(startTime)
        print(endTime)
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
        self.wakeupTableView.reloadData()
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
        self.wakeupTableView.reloadData()
    }
    @IBAction func pickerValueChanged(_ sender: UIDatePicker) {
        let selectedTime = datePicker.date
        self.setUITime(selected: selectedTime)
    }
    
    @objc func startButtonAction(){
        datePicker.date = Date()
        startTime = "00:00"
        endTime = "00:00"
        selectedDateType = "Start"
        self.timeView.isHidden = false
    }
    
    @objc func endButtonAction(){
        endTime = "00:00"
        selectedDateType = "End"
        self.timeView.isHidden = false
    }
    
    @objc func submitButtonAction(){
        if submitType == "Edit" {
            self.editWakeUpTimes()
        }else{
            self.saveWakeupTimes()
        }
        
    }
    
    func setUITime(selected: Date){
        let date = getFormattedDate(date: selected, format: "hh:mm a")
        print(date)
        let iso8601DateFormatter = ISO8601DateFormatter()
        iso8601DateFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        let dateString = iso8601DateFormatter.string(from: selected)
        if selectedDateType == "Start" {
            self.startTime = date
            self.startTimestamp = dateString
        }else{
            self.endTime = date
            self.endTimestamp = dateString
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
    
    func setupTextFields(textView: UITextView) {
            let toolbar = UIToolbar()
            let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace,
                                            target: nil, action: nil)
            let doneButton = UIBarButtonItem(title: "Done", style: .done,
                                             target: self, action: #selector(doneButtonTapped))
            
            toolbar.setItems([flexSpace, doneButton], animated: true)
            toolbar.sizeToFit()
            
        textView.inputAccessoryView = toolbar
        }
        
    @objc func doneButtonTapped() {
            view.endEditing(true)
        }
    @IBAction func addAllowanceBButtonAction(_ sender: UIButton) {
//        else if unitTextView.text == "$" || unitTextView.text == "Km"{
//            self.showAlert("Alert!", message: "Unit field cannot be empty.", actions: ["Ok"]) { actionTitle in
//                self.unitTextView.becomeFirstResponder()
//            }
//        }
        if allowanceId == 0 {
            self.showAlert("Alert!", message: "Please select Allowance type.", actions: ["Ok"]) { actionTitle in
               
            }
        }else{
            guard let token = careKernelDefaults.value(forKey: kLoginToken) as? String else {
                careKernelDefaults.set(false, forKey: kIsLoggedIn)
                return }
            allowancesVM.token = token
            allowancesVM.sessionId = self.sessionId
            let encoder = JSONEncoder()
            let  allowance = Allowance(allowanceID: allowanceId, unit: amountUnit)
            let allowances = Allowances(allowances: [allowance])
            let data = try! encoder.encode(allowances)
            let convertedString = try! JSON(data: data).rawValue as! [String:Any]
            print(convertedString)
            
            if sender.titleLabel?.text == "Add"{
                allowancesVM.saveAllowance(params: convertedString) { response, success in
                    if success {
                      self.showAlert("CareKernel", message: "Successfully added.", actions: ["Ok"]) { action in
                        }
                    }else{
                        print(response)
                        let statusCode = JSON(response)["statusCode"].intValue
                        let message = JSON(response)["message"].stringValue
                        self.showAlert("Error! \(statusCode)", message: message, actions: ["Ok"]) { (actionTitle) in
                            print(actionTitle)
                        }
                    }
                    self.allowanceId = 0

                    self.unitType = "$"

                    self.getSessionAllowances()
                }
            }else{
                let editeValuesParam = editAllowances(indexPath: selectedCell)
                print(editeValuesParam)
                allowancesVM.editAllowance(param: editeValuesParam, sessionAllowanceId: selectedSessionAllowanceId) { response, success in
                    if success {
                        self.showAlert("CareKernel", message: "Successfully edited.", actions: ["Ok"]) { action in
                            if action == "Ok" {
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

                    self.allowanceId = 0

                    self.unitType = "$"

                    self.getSessionAllowances()
                }
                
            }
        }
    }
    
    @IBAction func addTravelButtonAction(_ sender: UIButton) {
        
        if kmTextView.text == "" || kmTextView.text == "Km" || kmTextView.text == "0"{
            self.showAlert("Alert!", message: "Field cannot be empty.", actions: ["Ok"]) { actionTitle in
               
            }
        }else{
        let params: [String:Any] = ["travelKm":Int(travelKm) ?? 0,"travelLog":travelLog]
        guard let token = careKernelDefaults.value(forKey: kLoginToken) as? String else {
            careKernelDefaults.set(false, forKey: kIsLoggedIn)
            return }
        guard  let userId = careKernelDefaults.value(forKey: kUserId) as? Int else { return()}
        allowancesVM.token = token
        allowancesVM.sessionId = self.sessionId
            allowancesVM.saveTravelAllowance(sessionUserId: userId, params: params) { response, success in
            if success {
                self.showAlert("CareKernel", message: "Successfully added.", actions: ["Ok"]) { action in
                    if action == "Ok" {
                        self.getSessionAllowances()
                        self.kmTextView.text = "Km"
                        self.travelLogTextView.text = "Add Text Here"
                        self.kmTextView.resignFirstResponder()
                        self.travelLogTextView.resignFirstResponder()
                        
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
    func updateAllowance(){
        guard let token = careKernelDefaults.value(forKey: kLoginToken) as? String else {
            careKernelDefaults.set(false, forKey: kIsLoggedIn)
            return }
        allowancesVM.token = token
        allowancesVM.sessionId = self.sessionId
        let encoder = JSONEncoder()
        let  allowance = Allowance(allowanceID: allowanceId, unit: amountUnit)
        let allowances = Allowances(allowances: [allowance])
        let data = try! encoder.encode(allowances)
        let convertedString = try! JSON(data: data).rawValue as! [String:Any]
        print(convertedString)
        let editeValuesParam = editAllowances(indexPath: selectedCell)
        print(editeValuesParam)
        allowancesVM.editAllowance(param: editeValuesParam, sessionAllowanceId: selectedSessionAllowanceId) { response, success in
            if success {
                self.showAlert("CareKernel", message: "Successfully edited", actions: ["Ok"]) { action in
                    if action == "Ok" {
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

            self.allowanceId = 0

            self.unitType = "$"

            self.getSessionAllowances()
        }
    }
    func setDetails(){
        self.travelView.isUserInteractionEnabled = false
        self.notClaimableLabel.isHidden = false
        kmTextView.isUserInteractionEnabled = false
        travelLogTextView.isUserInteractionEnabled = false
        addTransportButton.isUserInteractionEnabled = false
        addTransportButton.backgroundColor = UIColor(red: 39.0/100, green: 58.0/100, blue: 206.0/100, alpha: 0.5)
        guard let token = careKernelDefaults.value(forKey: kLoginToken) as? String else {
            careKernelDefaults.set(false, forKey: kIsLoggedIn)
            return }
        allowancesVM.token = token
        getAllowancesItems()
        guard let isTransportEnable = careKernelDefaults.value(forKey: "isTransportEnable") as? [String:Any] else {
            return }
        print(isTransportEnable)
        isTravelClaimable = JSON(isTransportEnable)["isTravelClaimable"].boolValue
        
        refreshTableView()
        tabStatusDelegate?.tabStatusChanged(status: "Allowances")
        self.timeView.layer.borderWidth = 1
        self.timeView.layer.borderColor = UIColor(named: "Light Grey Font")?.cgColor
    }
    // MARK: -  Allowance
    func getAllowancesItems(){
        
        allowancesItems.removeAllObjects()
        allowancesVM.getAllowanceItems { response, success in
            if success{
                print(JSON(response)[""])
                
                DispatchQueue.main.async {
                    let tempArray = JSON(response)["data"].arrayValue
                    print(tempArray)
                    if tempArray.count != 0 {
                        
                        for value in tempArray {
                            let defaultValue = JSON(value)["defaultValue"].intValue
                            if defaultValue == 0 {
                                self.allowancesItems.add(value)
                            }
                            
                        }
                        let names = "Select"
                        let namesId = 0
                        let values = ["name": names, "id": namesId] as [String : Any]
                        self.allowancesItems.insert(values, at: 0)
                        print(self.allowancesItems)
                        
                    }
                }
            }else {
                let statusCode = JSON(response)["statusCode"].intValue
                let message = JSON(response)["message"].stringValue
                if statusCode == 401 && message == "Unauthorized" {
                    careKernelDefaults.set(false, forKey: kIsLoggedIn)
                    careKernelDefaults.set("", forKey: kUserEmailId)
                    careKernelDefaults.set("", forKey: kLoginToken)
                    self.dismiss(animated: true, completion: nil)
                }
            }
            self.getSessionAllowances()
        }
    }
    
    func getSessionAllowances(refresh: Bool = false){
        if refresh {
            self.allowancesTableView.refreshControl?.beginRefreshing()
        }
        sessionAllowances.removeAllObjects()
        allowancesVM.sessionId = self.sessionId
        allowancesVM.getSessionAllowances { response, success in
            if success{
                DispatchQueue.main.async {
                    let tempArray = JSON(response)["data"].arrayValue
                    print(tempArray)
                    if tempArray.count != 0 {
                        
                        for value in tempArray {
                            let isVisibleToWorker = JSON(value)["allowance"]["isVisibleToSupportWorker"].boolValue
                            if isVisibleToWorker {
                                self.sessionAllowances.add(value)
                                let isTravel = JSON(value)["allowance"]["isTravel"].boolValue
                                if isTravel {
                                    self.isTravelValue = isTravel
                                    let sessionUserArray = JSON(value)["allowance"]["sessionUserAllowances"].arrayValue
                                    for i in 0...sessionUserArray.count{
                                        let userId = JSON(sessionUserArray)[i]["userId"].intValue
                                        if userId == self.workerID {
                                            self.travelKm = JSON(sessionUserArray)[i]["unit"].stringValue
                                            self.travelLog = JSON(sessionUserArray)[i]["description"].stringValue
                                        }
                                    }
                                    
                                    
                                }
                                
                                if self.isTravelClaimable && self.isTravelValue {
                                    DispatchQueue.main.async { [self] in
                                        self.travelView.isUserInteractionEnabled = true
                                        self.notClaimableLabel.isHidden = true
                                        self.kmTextView.isUserInteractionEnabled = self.isTravelClaimable
                                        self.travelLogTextView.isUserInteractionEnabled = self.isTravelClaimable
                                        self.addTransportButton.isUserInteractionEnabled = self.isTravelClaimable
                                        self.addTransportButton.backgroundColor = UIColor(named: "TurquoiseColor")
                                        self.kmTextView.text = self.travelKm
                                        if self.travelLog == ""{
                                            travelLog = "Add Text Here"
                                        }
                                        self.travelLogTextView.text = self.travelLog
                                    }
                                }
                            }                            
                        }
                        
                        self.noRecordsLabel.isHidden = true
                        self.allowancesTableView.reloadData()
                        
                    }else{
                        self.noRecordsLabel.isHidden = false
                        self.allowancesTableView.isHidden = true
                    }
                    
                    self.allowancesTableView.refreshControl?.endRefreshing()
                    self.numberOfRows = 1
                    self.wakeupTimesList.removeAllObjects()
                    self.getWakeupTimesList()
                }
            }
            
        }
    }
    
    func handleSwipe(indexPath: IndexPath, action: String){
        let selectedAllowanceId = JSON(sessionAllowances)[indexPath.row]["allowanceId"].intValue
        self.allowanceId = selectedAllowanceId
        selectedSessionAllowanceId = JSON(sessionAllowances)[indexPath.row]["id"].intValue
        let selectedSessionAllowanceName = JSON(sessionAllowances)[indexPath.row]["allowance"]["name"].stringValue
        let selectedSessionAllowanceUnitValue = JSON(sessionAllowances)[indexPath.row]["allowance"]["sessionUserAllowances"][0]["unit"].floatValue
        guard let token = careKernelDefaults.value(forKey: kLoginToken) as? String else {
            careKernelDefaults.set(false, forKey: kIsLoggedIn)
            return }
        allowancesVM.token = token
        allowancesVM.sessionId = self.sessionId
        if action == "Edit" {

            self.amountUnit = selectedSessionAllowanceUnitValue

            let alert = UIAlertController(title: "Allowance", message: selectedSessionAllowanceName, preferredStyle: .alert)

            //2. Add the text field. You can configure it however you need.
            alert.addTextField { (textField) in
                textField.keyboardType = .decimalPad
                textField.text = "\(selectedSessionAllowanceUnitValue)"
            }

            alert.setTitlet(font: UIFont(name: "SFProText-Regular", size: 14), color: UIColor(named: "Basic BlueWhite font") ?? UIColor())
            alert.setMessage(font: UIFont(name: "SFProText-Regular", size: 16), color: UIColor(named: "Client Profile text font") ?? UIColor(), message: selectedSessionAllowanceName)
            alert.setTint(color: UIColor(named: "Home calendertable cell") ?? UIColor())
            // 3. Grab the value from the text field, and print it when the user clicks OK.
            // Action.
            let action = UIAlertAction(title: "Update", style: UIAlertAction.Style.default, handler: { [weak alert] (_) in
                let textField = alert?.textFields![0]
                textField?.keyboardType = .decimalPad
                // Force unwrapping because we know it exists.
                
                let amount = textField?.text!
                print("Text field: \(amount ?? "")")
                
                self.isKeyboardDismiss = true
                self.resignFirstResponder()
                self.view.endEditing(true)
                if amount == "" {
                    self.showAlert("Alert!", message: "Allowance cannot be empty.", actions: ["Ok"]) { action in
                        
                    }
                }else{
                    self.amountUnit = Float(amount ?? "") ?? 0.0
                    self.updateAllowance()
                }
            })
                action.setValue(UIColor(named: "Basic BlueWhite font") ?? UIColor(), forKey: "titleTextColor")
            
            alert.addAction(action)
            let action2 = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.default, handler: { [weak alert] (_) in
                
            })
            action2.setValue(UIColor(named: "Basic BlueWhite font") ?? UIColor(), forKey: "titleTextColor")
            alert.addAction(action2)
            // 4. Present the alert.
            self.present(alert, animated: true, completion: nil)
            
        }else{// case of Delete
            
            self.amountUnit = 0.0
            self.updateAllowance()
//            allowancesVM.deleteAllowance(sessionAllowanceId: selectedSessionAllowanceId) { response, success in
//                if success {
//                    self.showAlert("CareKernel", message: "Successfully deleted.", actions: ["Ok"]) { action in
//                        if action == "Ok" {
//                            self.getSessionAllowances()
//                        }
//
//                    }
//                }else{
//                    print(response)
//                    let statusCode = JSON(response)["statusCode"].intValue
//                    let message = JSON(response)["message"].stringValue
//                    self.showAlert("Error! \(statusCode)", message: message, actions: ["Ok"]) { (actionTitle) in
//                        print(actionTitle)
//                    }
//                }
//            }
        }
    }
    
    func editAllowances(indexPath: IndexPath) -> [String:Any]{
        
        let selectedAllowanceId = JSON(sessionAllowances)[indexPath.row]["allowanceId"].intValue
        let clientId = JSON(sessionAllowances)[indexPath.row]["clientId"].intValue
        let startTime = JSON(sessionAllowances)[indexPath.row]["startTime"].stringValue
        let endTime = JSON(sessionAllowances)[indexPath.row]["endTime"].stringValue
        let claimableUnit = JSON(sessionAllowances)[indexPath.row]["claimableUnit"].intValue
        let billingType = JSON(sessionAllowances)[indexPath.row]["billingType"].stringValue
        let params : [String:Any] = ["allowanceId": selectedAllowanceId,
          "unit": self.amountUnit,
          "userId": self.workerID]
        
//        "startTime": startTime,"clientId": clientId,
//        "endTime": endTime,"claimableUnit": "\(claimableUnit)",
        
        return params
    }
    
    // MARK: -  Wakeup Times Methods
    func getWakeupTimesList(refresh: Bool = false){
        startTime = "00:00"
        endTime = "00:00"
        wakeupReason = "Reason"
        if refresh {
            self.wakeupTableView.refreshControl?.beginRefreshing()
        }
        wakeupTimesList.removeAllObjects()
        allowancesVM.sessionId = self.sessionId
        allowancesVM.getWakeupTimesList { response, success in
            if success{
                DispatchQueue.main.async {
                    let tempArray = JSON(response)["data"].arrayValue
                    
                    if tempArray.count != 0 {
                        
                        for value in tempArray {
                            
                            self.wakeupTimesList.add(value)
                        }
                        self.numberOfRows = self.numberOfRows + self.wakeupTimesList.count
                        print(self.wakeupTimesList)
                        
                        
                        self.noRecordLabel.isHidden = true
                    }else{
                        self.noRecordsLabel.isHidden = false
                        
                    }
                    self.wakeupTableView.reloadData()
                    self.wakeupTableView.refreshControl?.endRefreshing()
                }
            }
            
        }
    }
    
    func saveWakeupTimes(){
        
        let startTimeDate = iso860ToString(dateString: startTimestamp)
        let endTimeDate = iso860ToString(dateString: endTimestamp)
        
        if startTimeDate > endTimeDate {
            showAlert("CareKernel", message: "End time can’t be less than the Start time.", actions: ["Ok"]) { result in
                
            }
        }else if wakeupReason == "" || startTimestamp == "" || endTimestamp == "" || wakeupReason == "Reason"{
            showAlert("CareKernel", message: "Fields cannot be empty.", actions: ["Ok"]) { result in
                
            }
        }else {
        let params : [String:Any] = [ "startTime": startTimestamp,
                                      "endTime": endTimestamp,
                                      "reason": wakeupReason ]
        allowancesVM.sessionId = self.sessionId
        allowancesVM.saveWakeupTimes(params: params) { response, success in
            if success {
                print(response)
                self.numberOfRows = 1
                self.startTime = "00:00"
                self.endTime = "00:00"
                self.startTimestamp = ""
                self.endTimestamp = ""
                self.wakeupReason = "Reason"
                self.getWakeupTimesList()
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
    
    func editWakeUpTimes(){
        let startTimeDate = iso860ToString(dateString: startTimestamp)
        let endTimeDate = iso860ToString(dateString: endTimestamp)
        
        if startTimeDate > endTimeDate {
            showAlert("CareKernel", message: "End time can’t be less than the Start time.", actions: ["Ok"]) { result in
                
            }
        }else if wakeupReason == "" || startTimestamp == "" || endTimestamp == "" {
            showAlert("CareKernel", message: "Fields cannot be empty", actions: ["Ok"]) { result in
                
            }
        }else {
        let params : [String:Any] = [ "startTime": startTimestamp,
                                      "endTime": endTimestamp,
                                      "reason": wakeupReason ]
        allowancesVM.sessionId = self.sessionId
        
        allowancesVM.editWakeupTime(param: params, wakeupTimeId: wakeupTimeId) { response, success in
            if success {
                print(response)
                self.numberOfRows = 1
                self.startTime = "00:00"
                self.endTime = "00:00"
                self.startTimestamp = ""
                self.endTimestamp = ""
                self.wakeupReason = "Reason"
                self.getWakeupTimesList()
            }else{
                print(response)
                let statusCode = JSON(response)["statusCode"].intValue
                let message = JSON(response)["message"].stringValue
                self.showAlert("Error! \(statusCode)", message: message, actions: ["Ok"]) { (actionTitle) in
                    print(actionTitle)
                }
            }
            self.submitType = ""
        }
        }
    }
    
    
    func handleWakeupSwipe(indexPath: IndexPath, action: String){
        let wakeupTimeId = JSON(wakeupTimesList)[indexPath.row-1]["id"].intValue
        self.wakeupTimeId = wakeupTimeId
        
        
        guard let token = careKernelDefaults.value(forKey: kLoginToken) as? String else {
            careKernelDefaults.set(false, forKey: kIsLoggedIn)
            return }
        allowancesVM.token = token
        allowancesVM.sessionId = self.sessionId
        if action == "Edit" {
            
            self.wakeupReason = JSON(wakeupTimesList)[indexPath.row - 1]["reason"].stringValue
            let startTimeValue = JSON(wakeupTimesList)[indexPath.row - 1]["startTime"].stringValue
            let endTimeValue = JSON(wakeupTimesList)[indexPath.row - 1]["endTime"].stringValue
            self.startTimestamp = startTimeValue
            self.endTimestamp = endTimeValue
            self.startTime = getFormattedDate(date: iso860ToString(dateString: startTimeValue), format: "hh:mm a")
            self.endTime = getFormattedDate(date: iso860ToString(dateString: endTimeValue), format: "hh:mm a")
            self.submitType = "Edit"
            self.wakeupTableView.reloadData()
            
        }else{// case of Delete
            allowancesVM.deleteWakeupTime(wakeupTimeId: wakeupTimeId) { response, success in
                if success {
                    self.showAlert("CareKernel", message: "Successfully deleted", actions: ["Ok"]) { action in
                        if action == "Ok" {
                            self.numberOfRows = 1
                            self.getWakeupTimesList()
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
    // MARK: -  Set Other Methods
    func setTableHeader(headerTitle: String){
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
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        isKeyboardDismiss = true
        self.resignFirstResponder()
        view.endEditing(true)
        
    }
    
    func setupTextFields() {
            let toolbar = UIToolbar()
            let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace,
                                            target: nil, action: nil)
            let doneButton = UIBarButtonItem(title: "Done", style: .done,
                                             target: self, action: #selector(keyBoardDoneButtonTapped))
            
            toolbar.setItems([flexSpace, doneButton], animated: true)
            toolbar.sizeToFit()
            
            kmTextView.inputAccessoryView = toolbar
            travelLogTextView.inputAccessoryView = toolbar
        }
        
        @objc func keyBoardDoneButtonTapped() {
            print(wakeupReason)
            view.endEditing(true)
        }
    
    @objc func keyboardWillShow(notification:NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
                    if self.view.frame.origin.y == 0 {
                        self.view.frame.origin.y -= keyboardSize.height
                    }
                }
    }

    @objc func keyboardWillHide(notification:NSNotification) {

        if self.view.frame.origin.y != 0 {
                    self.view.frame.origin.y = 0
                }
    }
    
    func refreshTableView(){
        self.allowancesTableView.refreshControl = UIRefreshControl()
        self.allowancesTableView.refreshControl?.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        
    }
    
    @objc private func refreshData(){
        print("Refreshed")
        self.getSessionAllowances(refresh: true)
    }
}

extension AllowancesViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if tableView == self.allowancesTableView {
            return 80
        }else if tableView == self.wakeupTableView {
            if indexPath.row == 0 {
                return 400
            }else{
                return 75
            }
            
        }else{
            return 50
        }
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == self.allowancesTableView {
            return sessionAllowances.count
        }else if tableView == self.wakeupTableView {
            return numberOfRows
        }else{
            return allowancesItems.count
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if tableView == self.allowancesTableView {
            let cell = tableView.dequeueReusableCell(withIdentifier: "SessionAllowancesCell", for: indexPath) as! SessionAllowancesCell
           
            cell.allowanceNameLabel.text = JSON(sessionAllowances)[indexPath.row]["allowance"]["name"].stringValue.capitalized
            
            let defaultValue = JSON(sessionAllowances)[indexPath.row]["allowance"]["defaultValue"].floatValue
            var unitToShow = ""
            var unitValue = Float()
            if defaultValue != 0 {
                unitValue = defaultValue
            }else{
                let sessionUserArray = JSON(sessionAllowances)[indexPath.row]["allowance"]["sessionUserAllowances"].arrayValue
                for i in 0...sessionUserArray.count{
                    let userId = JSON(sessionUserArray)[i]["userId"].intValue
                    if userId == self.workerID {
                        unitValue = JSON(sessionUserArray)[i]["unit"].floatValue
                    }
                }
                
                
            }
            let unitType = JSON(sessionAllowances)[indexPath.row]["allowance"]["unit"].stringValue
            if unitType == "one-Off" {
                unitToShow = "$" + "\(unitValue)"
            }else if unitType == "km" {
                unitToShow = "\(unitValue)" + " Km"
            }else if unitType == "hours" {
                unitToShow = "\(unitValue)" + " Hours"
            }else {
                unitToShow = "\(unitValue)"
            }
            cell.unitLabel.text = unitToShow
            
            return cell
        }else if tableView == self.wakeupTableView {
            if indexPath.row == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "WakeupTableViewCell", for: indexPath) as! WakeupTableViewCell
                cell.parentViewController = self
                cell.delegate = self
                cell.startAtLabel.text = self.startTime
                cell.endAtLabel.text = self.endTime
                cell.reasonTextView.text = self.wakeupReason
                cell.startEditButton.addTarget(self, action: #selector(startButtonAction), for: .touchUpInside)
                cell.endEditButton.addTarget(self, action: #selector(endButtonAction), for: .touchUpInside)
                cell.submitBUtton.addTarget(self, action: #selector(submitButtonAction), for: .touchUpInside)
                cell.reasonTextView.delegate = self
                cell.reasonTextView.isUserInteractionEnabled = true
                setupTextFields(textView: cell.reasonTextView)
                cell.reasonTextView.autocorrectionType = .no
                return cell
            }else{
                let cell = tableView.dequeueReusableCell(withIdentifier: "WakeupDetailsCell", for: indexPath) as! WakeupDetailsCell
                cell.reasonLabel.text = JSON(wakeupTimesList)[indexPath.row - 1]["reason"].stringValue.capitalized
                let startTimeValue = JSON(wakeupTimesList)[indexPath.row - 1]["startTime"].stringValue
                let enTimeValue = JSON(wakeupTimesList)[indexPath.row - 1]["endTime"].stringValue
                let startAt = getFormattedDate(date: iso860ToString(dateString: startTimeValue), format: "hh:mm a")
                let endAt = getFormattedDate(date: iso860ToString(dateString: enTimeValue), format: "hh:mm a")
                cell.startAtLabel.text = startAt
                cell.endAtLabel.text = endAt
                return cell
            }
            
        }else{// If dropDown tableView
            let cell = tableView.dequeueReusableCell(withIdentifier: "DropDownCell", for: indexPath) as! DropDownCell
            let name = JSON(self.allowancesItems)[indexPath.row]["name"].stringValue.capitalized
            cell.nameLabel.text = name
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
    
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        selectedCell = indexPath
        let sessionAllowanceID = JSON(sessionAllowances)[indexPath.row]["id"].intValue
        let defaultValue = JSON(sessionAllowances)[indexPath.row]["allowance"]["defaultValue"].floatValue
        if tableView == self.allowancesTableView {
            
            let swipeEditAction = UIContextualAction(style: .normal, title: "Edit") { [weak self] (action, view, completionHandler) in
                if defaultValue == 0 {
                    self?.handleSwipe(indexPath: indexPath, action: "Edit")
                }else{
                    self?.showAlert("Alert!", message: "You cannot edit this allowance.", actions: ["Ok"]) { action in

                    }
                }
                completionHandler(true)
            }
            swipeEditAction.backgroundColor = UIColor(named: "Swipe yellow")
            let swipeDeleteAction = UIContextualAction(style: .normal, title: "Reset") { [weak self] (action, view, completionHandler) in
                if defaultValue == 0 {
                    self?.handleSwipe(indexPath: indexPath, action: "Delete")
                }else{
                    self?.showAlert("Alert!", message: "You cannot reset this allowance.", actions: ["Ok"]) { action in

                    }
                }
               
                completionHandler(true)
            }
            swipeDeleteAction.backgroundColor = UIColor.red
            return UISwipeActionsConfiguration(actions: [swipeDeleteAction,swipeEditAction])
        }else if tableView == self.wakeupTableView {
            let swipeEditAction = UIContextualAction(style: .normal, title: "Edit") { [weak self] (action, view, completionHandler) in
                if defaultValue == 0 {
//                    self?.allowancesButton.isUserInteractionEnabled = false
                    self?.handleWakeupSwipe(indexPath: indexPath, action: "Edit")
                }else{
                    self?.showAlert("Alert!", message: "You cannot edit this allowance.", actions: ["Ok"]) { action in
                        
                    }
                }
                
                completionHandler(true)
            }
            swipeEditAction.backgroundColor = UIColor(named: "Swipe yellow")
            let swipeDeleteAction = UIContextualAction(style: .normal, title: "Delete") { [weak self] (action, view, completionHandler) in
                self?.handleWakeupSwipe(indexPath: indexPath, action: "Delete")
                completionHandler(true)
            }
            swipeDeleteAction.backgroundColor = UIColor.red
            return UISwipeActionsConfiguration(actions: [swipeDeleteAction,swipeEditAction])
        }else{
            return nil
        }
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == self.dropDownTableView {
            selectedCell = indexPath
            let selectedAllowanceName = JSON(allowancesItems)[indexPath.row]["name"].stringValue
            self.allowanceId = JSON(allowancesItems)[indexPath.row]["id"].intValue
            let unitTypeValue = JSON(allowancesItems)[indexPath.row]["unit"].stringValue
            if unitTypeValue == "one-Off" {
//                self.unitLable.text = "Unit - $"
                unitType = "$"
            }else if unitTypeValue == "km" {
//                self.unitLable.text = "Unit - Km"
                unitType = "Km"
            }else if unitTypeValue == "hour" {
//                self.unitLable.text = "Unit"
                unitType = "Hour"
            }

//            self.allowancesButton.setTitle(selectedAllowanceName, for: .normal)
//            self.unitTextView.text = unitType
            isCellSelected = true
            dropDownTableView.reloadData()
            dropDownBlackView.isHidden = true
        }else if tableView == self.wakeupTableView {
            if indexPath.row != 0{
            let reason = "Reason - " + JSON(wakeupTimesList)[indexPath.row - 1]["reason"].stringValue.capitalized
            let startTimeValue = JSON(wakeupTimesList)[indexPath.row - 1]["startTime"].stringValue
            let enTimeValue = JSON(wakeupTimesList)[indexPath.row - 1]["endTime"].stringValue
            let startAt = "Start At - " + getFormattedDate(date: iso860ToString(dateString: startTimeValue), format: "hh:mm a")
            let endAt = "End At - " + getFormattedDate(date: iso860ToString(dateString: enTimeValue), format: "hh:mm a")
            let details = "\(reason) \n\(startAt) \n\(endAt)"
            showAlertAlligned("Details", message: details, actions: ["Ok"]) { action in
                
            }
            }
        }else if tableView == self.allowancesTableView {
            let allowanceName = JSON(sessionAllowances)[indexPath.row]["allowance"]["name"].stringValue.capitalized
            var unitToShow = ""
            let unitValue = JSON(sessionAllowances)[indexPath.row]["allowance"]["sessionUserAllowances"][0]["unit"].floatValue
            let unitType = JSON(sessionAllowances)[indexPath.row]["allowance"]["unit"].stringValue
            if unitType == "one-Off" {
                unitToShow = "$" + "\(unitValue)"
            }else if unitType == "km" {
                unitToShow = "\(unitValue)" + " Km"
            }else if unitType == "hours" {
                unitToShow = "\(unitValue)" + " Hours"
            }else {
                unitToShow = "\(unitValue)"
            }
            let description = allowanceName + " " + unitToShow
            showAlertAlligned("Details", message: description, actions: ["Ok"]) { action in
                
            }
        }
        else {
            isKeyboardDismiss = true
            self.resignFirstResponder()
            view.endEditing(true)
        }
        
        
    }
}

extension AllowancesViewController: WakeupCellDelegate {
    func cellButtontapped(_ tag: Int, title: String) {
        
        if title == "Start" {
            
        }else if title == "End" {
            
        }else if title == "Submit" {
            
        }
    }
    

    
    
}

extension AllowancesViewController: UITextViewDelegate{
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView == kmTextView {
            if textView.text == "Km"{
                textView.text = ""
            }
        }else if textView == travelLogTextView{
            if textView.text == "Add Text Here"{
                textView.text = ""
            }
        }else {
            if textView.text == "Reason"{
                textView.text = ""
            }
        }
//        else if textView == unitTextView {
//            if textView.text == unitType{
//                textView.text = ""
//            }
//        }
    }
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView == kmTextView {
            if textView.text == ""{
                textView.text = "Km"
            }
        }else if textView == travelLogTextView{
            if textView.text == ""{
                textView.text = "Add Text Here"
            }
        }else{
            if textView.text == ""{
                textView.text = "Reason"
            }
        }

        if !isKeyboardDismiss {
            if textView == kmTextView{
                travelLogTextView.becomeFirstResponder()
            }
        }else{
            self.resignFirstResponder()
        }
        isKeyboardDismiss = false
    }
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        return true
    }
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool{
        if textView == kmTextView{
            if text == "\n" {
                isKeyboardDismiss = false
                textView.resignFirstResponder()
                return false
            }
        }
        return true
    }
    func textViewDidChange(_ textView: UITextView) {
        if textView == kmTextView{
            travelKm = textView.text
        }else if textView == travelLogTextView{
            travelLog = textView.text
        }else{
            wakeupReason = textView.text
        }
//        else if textView == unitTextView{
//            amountUnit = Float(textView.text ?? "") ?? 0.0
//        }
        
    }
    
}

class SessionAllowancesCell : UITableViewCell {
    @IBOutlet weak var allowanceNameLabel: UILabel!
    
    @IBOutlet weak var unitLabel: UILabel!
}

class WakeupDetailsCell: UITableViewCell {
    @IBOutlet weak var reasonLabel: UILabel!
    @IBOutlet weak var startAtLabel: UILabel!
    @IBOutlet weak var endAtLabel: UILabel!
}
