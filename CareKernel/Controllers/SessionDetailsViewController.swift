//
//  SessionDetailsViewController.swift
//  CareKernel
//
//  Created by Mohit Sharma on 26/10/21.
//

import UIKit
import SwiftyJSON
import TagListView
import CoreLocation
import JGProgressHUD
import Photos
import PhotosUI

protocol TabStatusDelegate {
    func tabStatusChanged(status: String)
}


class SessionDetailsViewController: UIViewController {
    
    @IBOutlet var sessionDetailsTableView: UITableView!
    @IBOutlet var attachedFileView: UIView!
    @IBOutlet var fileImageView: UIImageView!
    
    var tabStatusDelegate : TabStatusDelegate?
    var selectedIndex = 0//: IndexPath = IndexPath(row: 0, section: 0)
    var numberOfClients = 0
    var numberOfRows = 1
    var isOpen = Bool()
    var sessionId = 0
    var detailsDict: [String:Any] = [:]
    var clients = NSMutableArray()
    var isCellCollapc = Bool()
    var allTags = [""]
    private var caseNotesImage: UIImage?
    let delegate = UIApplication.shared.delegate as! AppDelegate
    var cvm = CaseViewModel()
    var sessionVM = SessionsViewModel()
    let hud = JGProgressHUD()
    var hasAttachment = false
    var timer:Timer = Timer()
    var timerCount: Int = 0
    var timerCounting: Bool = false
    var sessionUserId = 0
    var isClockedOn = Bool()
    var timeString = "00:00:00"
    var token = ""
    var sessionUpdateVM = SessionsUpdateViewModel()
    var canClockOn = Bool()
    var location = CLLocation()
    var notesText = String()
    var notificationId = 0
    var tasksList = NSMutableArray()
    var totalDuration = Int()
    var hasClockHistory = Bool()
    var totaldurationString = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        sessionDetailsTableView.register(CasenotesHeaderCell.nib(), forHeaderFooterViewReuseIdentifier: "CasenotesHeaderCell")
        sessionDetailsTableView.register(SessionTaskListTableViewCell.nib(), forCellReuseIdentifier: "SessionTaskListTableViewCell")
        sessionDetailsTableView.register(SessionBasicsCell.nib(), forCellReuseIdentifier: "SessionBasicsCell")
        sessionDetailsTableView.register(ClientCasenotesCell.nib(), forCellReuseIdentifier: "ClientCasenotesCell")
        sessionDetailsTableView.estimatedRowHeight = 400
        sessionDetailsTableView.rowHeight = UITableView.automaticDimension
        numberOfRows = numberOfRows + numberOfClients

        self.sessionDetailsTableView.allowsMultipleSelection = true
        self.sessionDetailsTableView.allowsMultipleSelectionDuringEditing = true
       
        tabStatusDelegate?.tabStatusChanged(status: "Details")
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.timer.invalidate()
    }
    
    func setDetails(){
        fetchData()
        LocationManager.shared.getUserLocation { location in
//            print(location.coordinate.latitude, location.coordinate.longitude)
            self.location = location
        }
//        fileImageView.layer.borderWidth = 4
//        fileImageView.layer.borderColor = UIColor(named: "Basic Blue")?.cgColor
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        guard  let userId = careKernelDefaults.value(forKey: kUserId) as? Int else { return()}
        sessionUserId = userId
        guard let token = careKernelDefaults.value(forKey: kLoginToken) as? String else {
            careKernelDefaults.set(false, forKey: kIsLoggedIn)
            return }
        self.token = token
        guard let clockON = careKernelDefaults.value(forKey: "isClockOn") as? Bool else { return()}
        isClockedOn = clockON
                
    }
    
    func presentStoryboard(segue: String, sender: Any?){
//        hud.dismiss()
//        self.view.isUserInteractionEnabled = true
        DispatchQueue.main.async {
            self.performSegue(withIdentifier: segue, sender: sender)
        }
        
    }
    @IBAction func backBUttonAction(_ sender: UIButton) {
        self.timer.invalidate()
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func fileViewCloseButtonAction(_ sender: UIButton) {
    }
    @objc func keyboardWillShow(notification: NSNotification) {
            
        guard let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else {
           // if keyboard size is not available for some reason, dont do anything
           return
        }
      
      // move the root view up by the distance of keyboard height
      self.view.frame.origin.y = 0 - keyboardSize.height
    }
    @objc func keyboardWillHide(notification: NSNotification) {
      // move back the root view origin to zero
      self.view.frame.origin.y = 0
    }
    
    
    func fetchData(){
        guard let token = careKernelDefaults.value(forKey: kLoginToken) as? String else {
            careKernelDefaults.set(false, forKey: kIsLoggedIn)
            return }
        sessionVM.token = token
        
        sessionVM.getSessionDetails(sessionId: sessionId) { response, success in
            if success {
                print(response)
                DispatchQueue.main.async {
                    self.clients.removeAllObjects()
                    let dict = JSON(response).dictionaryValue
                    self.detailsDict = dict  as [String : Any]
                    self.totalDuration = 0
                    let sessionUsers = JSON(self.detailsDict)["sessionUsers"].arrayValue as NSArray
                    for sessionValues in sessionUsers {
                        let clockHistory = JSON(sessionValues)["history"].arrayValue as NSArray
                        
                        if clockHistory.count != 0 {
                            for value in clockHistory {
                                let userId = JSON(value)["userId"].intValue
                                if userId == self.sessionUserId {
                                    self.hasClockHistory = true
                                }
                            }
                        }else{
                            self.hasClockHistory = false
                        }
                    }
                   
                    
                    
                    let lineItems = JSON(self.detailsDict)["items"].arrayValue
                    var lineItemsArr = [[Int:String]]()
                    for lineItems in lineItems{
                        let clientId = JSON(lineItems)["clientId"].intValue
                        let itemName = JSON(lineItems)["scheduleOfSupportItem"]["name"].stringValue
                        let itt = [clientId:itemName]
                        lineItemsArr.append(itt)
                    }
                    let tempArray = JSON(self.detailsDict)["clients"].arrayValue as NSArray
                    for value in tempArray {
                        let clientId = JSON(value)["id"].intValue
                        let clientName = JSON(value)["fullName"].stringValue
                        let hasAlert = JSON(value)["hasAlerts"].boolValue
                        var lineItems = [String]()
                        for dict in lineItemsArr{
                            for (itemsID,itemName) in dict {
                                if itemsID == clientId {
                                    lineItems.append(itemName)
                                }
                            }
                        }

                        let clientModelDic : [String:Any] = ["id": clientId, "fullName": clientName, "hasAlerts": hasAlert, "lineItem": lineItems]
                        self.clients.add(clientModelDic)
                        
                        
                        
                    }
                    
                    let encoder = JSONEncoder()
                    
                    do {
                        let clientData = try! encoder.encode(JSON(self.clients))
                        let documentUrl = Storage.getURL(for: .documents).appendingPathComponent("clientLineDetails", isDirectory: false)
                        Storage.writeToFile(clientData, documentsURL: documentUrl) { success in

                        }
                    } catch {
                        fatalError(error.localizedDescription)
                    }
                    
                    careKernelDefaults.set(self.clients, forKey: "clientLineDetails")

                    self.sessionDetailsTableView.reloadData()
                    self.getSessionTasksList()
                    let sessionTime = ["start": JSON(self.detailsDict)["startDate"].stringValue, "end": JSON(self.detailsDict)["endDate"].stringValue]
                    careKernelDefaults.set(sessionTime, forKey: "sessionTime")
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
            if self.notificationId != 0 {
                self.deleteNotification(notificationId: self.notificationId)
            }
        }
    }
    
    func getSessionTasksList(){
        self.sessionVM.getSessionTasks(sessionId: sessionId) { response, success in
            if success {
                
                let dictArr = JSON(response).arrayValue as NSArray
                
                if dictArr.count != 0 {
                    self.tasksList.removeAllObjects()
                    for value in dictArr {
                        self.tasksList.add(value)
                    }
                }

                UIView.setAnimationsEnabled(false)
                self.sessionDetailsTableView.beginUpdates()
                self.sessionDetailsTableView.reloadSections(NSIndexSet(index: 1) as IndexSet, with: .none)
                self.sessionDetailsTableView.endUpdates()

            }
    }
    }
    
    func postCaseNotesData(clientId: Int, title: String, description: String, hasAttachment: Bool, completion: @escaping (JSON,Bool) -> Void){
        guard let token = careKernelDefaults.value(forKey: kLoginToken) as? String else {
            careKernelDefaults.set(false, forKey: kIsLoggedIn)
            return }
        cvm.token = token
        cvm.title = title
        cvm.description = description
        cvm.clientId = clientId
        let currentDate = getFormattedDate(date: Date(), format: "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'")
        cvm.recordedAt = currentDate
        cvm.postCaseNotes { response in
            if response.success {

                self.view.isUserInteractionEnabled = true
                self.hud.dismiss()
                if !hasAttachment{
                    self.showAlert("CareKernel", message: "Case notes updated.", actions: ["OK"]) { actionTitle in
                        
                    }
                    return completion(JSON(response.data!),false)
                }else{
                    return completion(JSON(response.data!),true)
                }

            }else{
                self.showAlert("Error!", message: response.successMessage ?? "", actions: ["OK"]) { actionTitle in
                    
                }
                return completion(JSON(response.data!),false)
            }
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
    
    func deleteNotification(notificationId: Int){
        var notificationVM = NotificationViewModel()
        guard let token = careKernelDefaults.value(forKey: kLoginToken) as? String else {
            careKernelDefaults.set(false, forKey: kIsLoggedIn)
            return }
        notificationVM.token = token
        notificationVM.updateNotificationStatus(isRead: true, notificationId: notificationId) { response, success in
            if success {
                self.fetchData()
            }
        }
    }
    
    func changeFormat(str:String) -> Date {// hh:mm a string to Date
        let dateFormatter = DateFormatter()

        dateFormatter.dateFormat = "hh:mm a" // input format
        let date = dateFormatter.date(from: str) ?? Date()

        return date
    }
    
    func changeSessionStatus(selectedDate: Date) -> String{
        var dateStatus = String()
        let selectedDateString = getFormattedDate(date: selectedDate, format: "dd, MMMM, yyyy")
        let todayDate = getFormattedDate(date: Date(), format: "dd, MMMM, yyyy")
        let date = iso860ToString(dateString: todayDate)
//        print(date, selectedDate)
        let dateFormatter = DateFormatter()
        dateFormatter.timeStyle = .none
        dateFormatter.dateStyle = .medium

        let today = dateFormatter.string(from: date)
        let asked = dateFormatter.string(from: selectedDate)
//        print(today, asked)
        
        if today == asked {
            dateStatus = "Today Sessions"
        }else if today > asked {
            if todayDate == selectedDateString{
                dateStatus = "Today Sessions"
            }else{
                let minmumTimeString = "11:50 PM"
                let maximumTimeString = "12:00 AM"
                let minmumTime = changeFormat(str: minmumTimeString)
                let maximumTime = changeFormat(str: maximumTimeString)
                let sessionStartTimeString = getFormattedDate(date: selectedDate, format: "hh:mm a")
                let sessionStartTime = changeFormat(str: sessionStartTimeString)

                if sessionStartTime.isBetween(maximumTime, minmumTime){
//                    print("Not a night case")
                    dateStatus = "Previous Sessions"
                }else{
//                    print("Case of night")
                    if canClockOn{
                        dateStatus = "Today Sessions"
                    }else{
                        dateStatus = "Previous Sessions"
                    }
                }
                
            }
        }else if today < asked {
            
            let minmumTimeString = "11:50 PM"
            let maximumTimeString = "12:00 AM"
            let minmumTime = changeFormat(str: minmumTimeString)
            let maximumTime = changeFormat(str: maximumTimeString)
            let sessionStartTimeString = getFormattedDate(date: selectedDate, format: "hh:mm a")
            let sessionStartTime = changeFormat(str: sessionStartTimeString)

            if sessionStartTime.isBetween(maximumTime, minmumTime){
//                    print("Not a night case")
                dateStatus = "Upcoming Sessions"
            }else{
//                    print("Case of night")
                if canClockOn{
                    dateStatus = "Today Sessions"
                }else{
                    dateStatus = "Upcoming Sessions"
                }
            }
            
        }
        
//        if date == selectedDate {
//            dateStatus = "Today's Sessions"
//        }else if date > selectedDate {
//            if todayDate == selectedDateString{
//                dateStatus = "Today's Sessions"
//            }else{
//                dateStatus = "Previous Sessions"
//            }
//        }else if date < selectedDate{
//            dateStatus = "Upcoming Sessions"
//        }
        careKernelDefaults.setValue(dateStatus, forKey: "sessionStatus")
        return dateStatus
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
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let vc = segue.destination as? ClientMainViewController {
            vc.clientId = sender as! Int
        }
    }
}
extension Date {
    func isBetween(_ start: Date, _ end: Date) -> Bool {
        start...end ~= self
    }
}
extension SessionDetailsViewController : UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0 {
            return UITableViewCell()
        }else if section == 1{
        
            guard let cell = tableView.dequeueReusableHeaderFooterView(withIdentifier: "CasenotesHeaderCell") as? CasenotesHeaderCell else {
              return nil
              }
            cell.headerTitleLabel.text = "Task List"
            cell.iconImageView.image = UIImage(named: "icon-files")
            cell.clipsToBounds = true
            cell.layer.cornerRadius = 8
            cell.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
              return cell
        }else{
            
            guard let cell = tableView.dequeueReusableHeaderFooterView(withIdentifier: "CasenotesHeaderCell") as? CasenotesHeaderCell else {
              return nil
              }
            cell.headerTitleLabel.text = "Comments"
            cell.iconImageView.image = UIImage(named: "icon-comments")
            cell.clipsToBounds = true
            cell.layer.cornerRadius = 8
            cell.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
              return cell
        }
        
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 0
        }else{
            return 66
        }
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        switch indexPath {
        case IndexPath(row: 0, section: 0):
            return 720
        case IndexPath(row: 0, section: 1):
            return 40
        case IndexPath(row: 0, section: 2):
            return 365
        default:
            return 40
        }
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if section == 1{
            return self.tasksList.count
        }else{
            return 1
        }
        
        
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "SessionBasicsCell", for: indexPath) as! SessionBasicsCell
//            cell.clientsDetailsArray.removeAllObjects()
            cell.parentViewController = self
            cell.delegate = self
            cell.dataDict = self.detailsDict
            cell.contentView.layer.cornerRadius = 8
            cell.deliveredButton.onTintColor = .white
            cell.deliveredButton.thumbTintColor = .green
            cell.deliveredButton.layer.borderWidth = 1
            cell.deliveredButton.layer.borderColor = UIColor.lightGray.cgColor
            cell.deliveredButton.layer.cornerRadius = 16
            let startTime = getFormattedDate(date: iso860ToString(dateString: JSON(self.detailsDict)["startDate"].stringValue), format: "dd/MM/yyyy hh:mm a")
            let endTime = getFormattedDate(date: iso860ToString(dateString: JSON(self.detailsDict)["endDate"].stringValue), format: "dd/MM/yyyy hh:mm a")
            
            cell.startTimelbl.text = startTime
            cell.endtimelbl.text = endTime
            //            cell.workerNamelbl.text = JSON(self.detailsDict)["startDate"].stringValue
            cell.locationLbl.text = JSON(self.detailsDict)["site"]["name"].stringValue
            let instructions = JSON(self.detailsDict)["serviceWorkerMessage"].stringValue
            if self.clients.count == 0 {
                cell.descriptionView.isHidden = false
                
                let description = JSON(self.detailsDict)["description"].stringValue
                let sessionType = JSON(self.detailsDict)["sessionType"].stringValue
                if description == "" {
                    
                    cell.descriptionDataLabel.text = sessionType
                }else{
                    cell.descriptionDataLabel.text = description
                }
                
            }else{
                cell.descriptionView.isHidden = true
                
            }
            
            if instructions != "" {
                cell.instructionDataLabel.text = instructions
            }else{
                cell.instructionDataLabel.text = "NA"
            }
            let isTravelClaimable = JSON(self.detailsDict)["isTravelClaimable"].boolValue
            if isTravelClaimable {
                cell.travelLbl.text = "Yes"
            }else{
                cell.travelLbl.text = "No"
            }
            cell.clientsDetailsArray = self.clients
            //Delivered Switch Functionality
            cell.callback = { (switch) -> Void in
                // DO stuff here.
                self.showAlert("CareKernel", message: "Are you sure to mark the session delivered?", actions: ["Yes","Cancel"]) { action in

                    if action == "Yes"{
                        self.sessionUpdateVM.sessionStatus = "delivered"
                        self.sessionUpdateVM.sessionId = self.sessionId
                        
                        self.sessionUpdateVM.token = self.token
                        self.sessionUpdateVM.sessionUserId = self.sessionUserId
                        self.sessionUpdateVM.deliveredSession { response, success in
                            
                            self.showAlert("CareKernel", message: "Session delivered successfully.", actions: ["Ok"]) { action in
                                let isTransportEnable = ["isDelivered": true, "isTravelClaimable": isTravelClaimable]
                                careKernelDefaults.set(isTransportEnable, forKey: "isTransportEnable")
                                cell.deliveredButton.isEnabled = false
                                cell.deliveredButton.thumbTintColor = .green

                            }
                           
                            
                        }
                    }else{
                        cell.deliveredButton.isOn = false
                    }
                }
            }
            let today = Date()
            var serviceWorkerName = ""
            let sessionUsers = JSON(self.detailsDict)["sessionUsers"].arrayValue as NSArray
            var clockOnAt = ""
            var clockOffAt = ""
            self.totalDuration = 0
            self.totaldurationString = ""
            if hasClockHistory {
                for sessionValues in sessionUsers{
                    let clockHistoryArray = JSON(sessionValues)["history"].arrayValue
                    
                        for values in clockHistoryArray {
                            let userId = JSON(values)["userId"].intValue
                            if userId == self.sessionUserId {
                                clockOnAt = JSON(values)["clockOnAt"].stringValue
                                clockOffAt = JSON(values)["clockOffAt"].stringValue
                                if clockOffAt != "" {
                                    let clockOnDateTime = iso860ToString(dateString: clockOnAt)
                                    let clockOffDateTime = iso860ToString(dateString: clockOffAt)
                                    
                                    var clockOnOffduration: String {
                                        return clockOffDateTime.offset(from: clockOnDateTime).dateComponentsToTimeString()
                                    }
                                    print(clockOnOffduration)
                                    let oldDurat = clockOnOffduration.secondFromString
                                    self.totalDuration = totalDuration + oldDurat
                                }else {
                                    let clockOnDateTime = iso860ToString(dateString: clockOnAt)
                                    print(clockOnDateTime)
                                    var durationString: String {
                                        return today.offset(from: clockOnDateTime).dateComponentsToTimeString()
                                    }
                                    print(durationString)
                                    let newDuration = durationString.secondFromString
                                    self.totalDuration = totalDuration + newDuration
                                }
                            }
                        }
                }

                

                let time = secondsToHoursMinutesSecons(seconds: self.totalDuration)
                self.totaldurationString = timeString(hours: time.0, minutes: time.1, seconds: time.2)
            }
            
            for value in sessionUsers {
                let id = JSON(value)["id"].intValue
                let serviceWorkerNamevalue = JSON(value)["fullName"].stringValue
                serviceWorkerName = "\(serviceWorkerName)\(serviceWorkerNamevalue) \n"
                cell.workerNamelbl.text = serviceWorkerName
                if id == sessionUserId {

                    let sessionUser = JSON(value)["SessionUser"].dictionaryValue //["sessionId"].intValue
                    let sessionId = JSON(sessionUser)["sessionId"].intValue
                    if sessionId == JSON(self.detailsDict)["id"].intValue{
                        let sessionStatus = JSON(self.detailsDict)["sessionStatus"].stringValue
                        var isDelivered = Bool()
                        if sessionStatus == "delivered"{
                            isDelivered = true
                        }else{
                            isDelivered = false
                        }
                        let isTransportEnable = ["isDelivered": isDelivered, "isTravelClaimable": isTravelClaimable]
                        careKernelDefaults.set(isTransportEnable, forKey: "isTransportEnable")
                        
//                        clockOnAt = JSON(sessionUser)["clockOnAt"].stringValue
//                        clockOffAt = JSON(sessionUser)["clockOffAt"].stringValue
                       
//                        let clockOnDateTime = iso860ToString(dateString: clockOnAt)
//                        let today = Date()
//                        var durationString: String {
//                            return today.offset(from: clockOnDateTime).dateComponentsToTimeString()
//                        }
//                        print(durationString)
                        if isDelivered {
                            cell.deliveredButton.setOn(true, animated: true)
                            cell.deliveredButton.isEnabled = false
                            cell.deliveredButton.thumbTintColor = .green
                        }else{
                            if timerCounting {
                                cell.deliveredButton.isEnabled = false
                            }else{
                                cell.deliveredButton.isEnabled = true
                            }
                            cell.deliveredButton.tintColor = .white
                            cell.deliveredButton.setOn(false, animated: true)
                            cell.deliveredButton.thumbTintColor = .white
                        }
                        if clockOnAt != "" && clockOffAt != ""{// clockOnAt hasdata && clockOffAt hasdata
                            if isDelivered {
                                self.timeString = self.totaldurationString
                                showAlert("Alert!", message: "Session is completed & delivered.", actions: ["Ok"]) { action in
                                    
                                }
                            }else{
//                                isClockedOn = careKernelDefaults.value(forKey: "isClockOn") as! Bool
                                var runningSessionId = 0
                                if let clockedStatus = careKernelDefaults.value(forKey: "clockedStatus") as? [String : Any]{
                                    runningSessionId = JSON(clockedStatus)["sessionID"].intValue
                                    isClockedOn = JSON(clockedStatus)["isClockOn"].boolValue
                                }
                                 
                                if isClockedOn && sessionId == runningSessionId{
                                    self.timeString = self.totaldurationString
                                    self.timerCount = self.totaldurationString.secondFromString
                                    self.timerCounting = true
                                    
                                    self.timer.invalidate()
                                    
                                    self.timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.timerCounter), userInfo: nil, repeats: false)
                                    
                                    cell.clockOnButton.setTitle("Clock Off", for: .normal)
                                }else if !isClockedOn && sessionId == runningSessionId{
                                    showAlert("Alert!", message: "Session will be set to clocked off and is not yet set to delivered. Do you want to continue as clocked on?", actions: ["Yes","No"]) { action in
                                        if action == "Yes"{
                                            self.timeString = self.totaldurationString
                                            cell.timerLbl.text = self.timeString
                                            self.timerCount = self.totaldurationString.secondFromString
                                            cell.clockOnButton.setTitle("Clock Off", for: .normal)
                                            self.canClockOn = self.clockOnStartTimer(startTime: JSON(self.detailsDict)["startDate"].stringValue, endTime: JSON(self.detailsDict)["endDate"].stringValue, clockOffTime: clockOffAt, currentDate: today)
                                            self.didTapButton(for: cell, cellData: self.detailsDict, title: "Clock Off")
                                        }else{
//                                            cell.clockOnButton.isEnabled = false
                                            cell.clockOnButton.setTitle("Clock On", for: .normal)
                                            self.timerCounting = false
                                            self.timeString = self.totaldurationString
                                            cell.timerLbl.text = self.timeString
                                            cell.clockOnButton.isUserInteractionEnabled = true
                                        }
                                    }
                                }else if isClockedOn && sessionId != runningSessionId{
                                    showAlert("Alert!", message: "Session is on clock off but is not set to delivered. Session \(runningSessionId) is active right now.", actions: ["Ok"]) { action in
                                        self.timeString = self.totaldurationString
                                        cell.timerLbl.text = self.timeString
                                    }
                                }else if !isClockedOn && sessionId != runningSessionId{
                                    showAlert("Alert!", message: "Session is on clock off but is not set to delivered.", actions: ["Ok"]) { action in
                                        self.timeString = self.totaldurationString
                                        cell.timerLbl.text = self.timeString
                                        cell.clockOnButton.setTitle("Clock On", for: .normal)
                                        self.canClockOn = self.clockOnStartTimer(startTime: JSON(self.detailsDict)["startDate"].stringValue, endTime: JSON(self.detailsDict)["endDate"].stringValue, clockOffTime: clockOffAt, currentDate: today)
                                    }
                                }
                            }
                            
                                                        
                        }else if clockOnAt == "" && clockOffAt == "" {//clockOnAt nodata && clockOffAt nodata

                            self.canClockOn = self.clockOnStartTimer(startTime: JSON(self.detailsDict)["startDate"].stringValue, endTime: JSON(self.detailsDict)["endDate"].stringValue, clockOffTime: clockOffAt, currentDate: today)
                            timeString = "00:00:00"
                            cell.clockOnButton.setTitle("Clock On", for: .normal)
                        }else if clockOnAt != "" && clockOffAt == "" {//clockOnAt hasdata && clockOffAt nodata
                            timeString = self.totaldurationString
                            timerCount = self.totaldurationString.secondFromString
                            timerCounting = true
                            
                            self.timer.invalidate()
                            
                            self.timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(timerCounter), userInfo: nil, repeats: false)
                            
                            cell.clockOnButton.setTitle("Clock Off", for: .normal)
                        }
                    }
                }
            }
            cell.timerLbl.text = timeString
            cell.clipsToBounds = true
            cell.layer.cornerRadius = 8
//            cell.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
            return cell
        }else if indexPath.section == 1 {
                    
            let cell = tableView.dequeueReusableCell(withIdentifier: "SessionTaskListTableViewCell", for: indexPath) as! SessionTaskListTableViewCell
            cell.delegate = self
            cell.tickButton.tag = indexPath.row
            cell.tickImageView.image = #imageLiteral(resourceName: "circle")
            cell.taskNameLabel.text = JSON(self.tasksList)[indexPath.row]["task"].stringValue.capitalized
            let taskStatus = JSON(self.tasksList)[indexPath.row]["isDone"].boolValue
            if taskStatus {
            cell.tickImageView.image = #imageLiteral(resourceName: "tick")
            }
            if tasksList.count-1 == indexPath.row {
                cell.clipsToBounds = true
                cell.layer.cornerRadius = 8
                cell.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
            }
//            cell.clipsToBounds = true
//            cell.layer.cornerRadius = 8
//            cell.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
            return cell
        }else{
    
            let cell = tableView.dequeueReusableCell(withIdentifier: "ClientCasenotesCell", for: indexPath) as! ClientCasenotesCell
               
                cell.indexPath = indexPath
            cell.delegate = self
                
                cell.notesTextView.delegate = self
                cell.notesTextView.isUserInteractionEnabled = true
                self.setupTextFields(textView: cell.notesTextView)
                cell.addAttachmentButton.isHidden = true
                cell.fileNameButton.isHidden = true
                let comments = JSON(self.detailsDict)["comments"].stringValue
            if comments != ""{
                cell.notesTextView.text = comments.capitalized
            }
            
            cell.submitButton.setTitle("Add Comment", for: .normal)
                cell.submitButton.topAnchor.constraint(equalTo: cell.notesTextView.bottomAnchor, constant: 24).isActive = true
            cell.clipsToBounds = true
            cell.layer.cornerRadius = 8
            cell.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
                return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 1 {
            
            tableView.deselectRow(at: indexPath, animated: true)
            let description = JSON(self.tasksList)[indexPath.row]["task"].stringValue.capitalized
            showAlertAlligned("Details", message: description, actions: ["Ok"]) { action in
                
            }
//            let taskId = JSON(self.tasksList)[indexPath.row]["id"].intValue
//            let task = JSON(self.tasksList)[indexPath.row]["task"].stringValue
//            var isDone = Bool()
//            let taskStatus = JSON(self.tasksList)[indexPath.row]["isDone"].boolValue
//            if taskStatus {
//                isDone = false
//            }else{
//                isDone = true
//            }
//            sessionUpdateVM.sessionId = self.sessionId
//            sessionUpdateVM.token = token
//            sessionUpdateVM.sessionUserId = self.sessionUserId
//            let params:[String: Any] = ["isDone": isDone, "task": task]
//            sessionUpdateVM.updateTaskStatus(taskId: taskId, params: params) { response, success in
//                if success {
//                    print(response)
//                    self.getSessionTasksList()
//                }
//            }
        }
       
    }
    
}


extension SessionDetailsViewController: ClientcCaseNotesCellDelegate, SessionTaskListCellDelegate{
    func didTapTaskButton(for cell: SessionTaskListTableViewCell, tag: Int) {
        
        let taskId = JSON(self.tasksList)[tag]["id"].intValue
        let task = JSON(self.tasksList)[tag]["task"].stringValue
        var isDone = Bool()
        let taskStatus = JSON(self.tasksList)[tag]["isDone"].boolValue
        if taskStatus {
            isDone = false
        }else{
            isDone = true
        }
        sessionUpdateVM.sessionId = self.sessionId
        sessionUpdateVM.token = token
        sessionUpdateVM.sessionUserId = self.sessionUserId
        let params:[String: Any] = ["isDone": isDone, "task": task]
        sessionUpdateVM.updateTaskStatus(taskId: taskId, params: params) { response, success in
            if success {
//                print(response)
                self.getSessionTasksList()
            }
        }
        
        
    }
    
   
    

    func didTapButton(for cell: ClientCasenotesCell, cellData: [String : Any], title: String) {
        if title == "Add Comment"{
            if cell.notesTextView.text != "Message" && cell.notesTextView.text != "" {
            
            self.view.isUserInteractionEnabled = false
            hud.show(in: self.view)
                let comment = self.notesText
                let params: [String:Any] = ["comments": comment ]
                
                guard let token = careKernelDefaults.value(forKey: kLoginToken) as? String else {
                    careKernelDefaults.set(false, forKey: kIsLoggedIn)
                    return }
                var allowancesVM = AllowancesViewModel()
                allowancesVM.token = token
                allowancesVM.sessionId = self.sessionId
                allowancesVM.saveAllowance(params: params) { response, success in
                    if success {
//                        print(response)
                        self.showAlert("CareKernel", message: "Successfully added.", actions: ["Ok"]) { action in
                            if action == "Ok" {
                                
                            }
                            
                        }
                    }else{
//                        print(response)
                        let statusCode = JSON(response)["statusCode"].intValue
                        let message = JSON(response)["message"].stringValue
                        self.showAlert("Error! \(statusCode)", message: message, actions: ["Ok"]) { (actionTitle) in
//                            print(actionTitle)
                        }
                    }
                    self.view.isUserInteractionEnabled = true
                    self.hud.dismiss()
                }

            }else{
                showAlert("Alert!", message: "Comment message cannot be blank.", actions: ["Ok"]) { action in
                    
                }
            }
        }
    }
    
}

extension SessionBasicsCell : TagListViewDelegate {

    func tagPressed(_ title: String, tagView: TagView, sender: TagListView) {
//        print("Tag pressed: \(title), \(sender.tag)")
        var clientId = Int()
        var clientsArr = NSArray()
        if let pvc = self.parentViewController as? SessionDetailsViewController {
            clientsArr = pvc.clients
        }
                    if clientsArr.count != 0 {
                        for (value) in clientsArr {
                            let clientNames = JSON(value)["fullName"].stringValue
                            if clientNames == title {
                                clientId = JSON(value)["id"].intValue
                            }
                        }
                    }else{
                        clientId = sender.tag
                    }
        


        careKernelDefaults.set(clientId, forKey: "clientID")

        DispatchQueue.main.async {

            self.parentViewController?.performSegue(withIdentifier: "segueToClientDetails", sender: clientId)
        }
    }

}

extension SessionDetailsViewController : SessionDetailsDelegate {
    func buttonInCollectionCellTapped(_ tag: Int, title: String) {
        if title == "ClientButton" {
            let clientID = JSON(self.clients)[tag]["id"].intValue
            careKernelDefaults.set(clientID, forKey: "clientID")
            self.parent?.performSegue(withIdentifier: "segueToClientDetails", sender: clientID)
        }else{
            var arrString = String()
            let lineItemArray = JSON(self.clients)[tag]["lineItem"].arrayValue
            for value in lineItemArray {
                arrString = "\(arrString)*\(value) \n\n"
//                print(arrString)
                
            }
            showAlertAlligned("Line Items", message: arrString, actions: ["Ok"]) { action in
                
            }
            
        }
        
    }
    

    
    func didTapButton(for cell: SessionBasicsCell, cellData: [String : Any], title: String) {
        self.view.isUserInteractionEnabled = false
        self.hud.show(in: self.view)
        if title == "Clock On" || title == "Clock Off"{
            //            self.view.isUserInteractionEnabled = false
            //            hud.show(in: self.view)
            //            var name = JSON(cellData)["fullName"].stringValue
            sessionUpdateVM.isDelivered = true
            sessionUpdateVM.sessionId = JSON(cellData)["id"].intValue
            sessionUpdateVM.token = token
            sessionUpdateVM.sessionUserId = self.sessionUserId
            if timerCounting {
                if isClockedOn {
                    self.view.isUserInteractionEnabled = true
                    self.hud.dismiss()
                    showAlert("Alert!", message: "Are you sure, you want to clock Off?", actions: ["Ok","Cancel"]) { action in
                        if action == "Ok"{
                            self.sessionUpdateVM.clockOffAt = true
                            self.timer.invalidate()
                            let params:[String: Any] = ["clockOffAt": true, "clockOffLat": self.location.coordinate.latitude, "clockOffLong": self.location.coordinate.longitude]
                            self.sessionUpdateVM.updateClock(params: params) { response, success in
                                if success {
                                    cell.clockOnButton.setTitle("Clock On", for: .normal)
                                    self.isClockedOn = false
                                    careKernelDefaults.setValue(self.isClockedOn, forKey: "isClockOn")
                                    self.timerCounting = false
                                    self.timerCount = 0
                                    let sessionID = JSON(cellData)["id"].intValue
                                    let displayID = JSON(self.detailsDict)["displayId"].stringValue
                                    let dbParam = ["isClockOn": self.isClockedOn, "sessionID": 0, "displayId": "0"] as [String : Any]
                                    careKernelDefaults.setValue(dbParam, forKey: "clockedStatus")
                                    
                                    self.fetchData()
                                }else{
                                    
                                }
                            }
                            
                        }
                    }
                }
                
            }else{
                if !isClockedOn {
                    let startDateTime = self.iso860ToString(dateString: JSON(self.detailsDict)["startDate"].stringValue)
                    let sessioStatus = changeSessionStatus(selectedDate: startDateTime)
//                   print(canClockOn)
                    if sessioStatus != "Previous Sessions" && sessioStatus != "Upcoming Sessions" && sessioStatus == "Today Sessions" && canClockOn{
                        showAlert("Alert!", message: "Are you sure, you want to clock On?", actions: ["Ok","Cancel"]) { action in
                            if action == "Ok"{
                                self.sessionUpdateVM.clockOnAt = true
                                let params:[String: Any] = ["clockOnAt": true, "clockOnLat": self.location.coordinate.latitude, "clockOnLong": self.location.coordinate.longitude]
                                self.sessionUpdateVM.updateClock(params: params) { response, success in
                                    if success {
                                        self.timerCounting = true
                                        self.isClockedOn = true
                                        careKernelDefaults.setValue(self.isClockedOn, forKey: "isClockOn")
                                        cell.clockOnButton.setTitle("Clock Off", for: .normal)
                                        let sessionID = JSON(cellData)["id"].intValue
                                        let displayID = JSON(self.detailsDict)["displayId"].stringValue
                                        let dbParam = ["isClockOn": self.isClockedOn, "sessionID": sessionID, "displayId": displayID] as [String : Any]
                                        careKernelDefaults.setValue(dbParam, forKey: "clockedStatus")
                                        self.detailsDict.removeAll()
                                        self.clients.removeAllObjects()
                                        self.fetchData()
                                    }
                                }
                            }else{
                                cell.clockOnButton.setTitle("Clock On", for: .normal)
                            }
                        }
                    }else{
                        cell.clockOnButton.setTitle("Clock On", for: .normal)
                        showAlert("Alert!", message: "You cannot start previous/upcoming session.", actions: ["Ok"]) { action in
                        }
                    }
                }else{
                    showAlert("Alert!", message: "Any other session is running.", actions: ["Ok"]) { action in
                        
                    }
                }
                
                self.view.isUserInteractionEnabled = true
                self.hud.dismiss()
            }
        }
        else if title == "Delivered Button"{
            self.showAlert("CareKernel", message: "Are you sure to mark the session delivered?", actions: ["Yes","Cancel"]) { action in

                if action == "Yes"{
                    self.sessionUpdateVM.sessionStatus = "delivered"
                    self.sessionUpdateVM.sessionId = JSON(cellData)["id"].intValue
                    
                    self.sessionUpdateVM.token = self.token
                    self.sessionUpdateVM.sessionUserId = self.sessionUserId
                    self.sessionUpdateVM.deliveredSession { response, success in
                        
                        self.showAlert("CareKernel", message: "Session delivered successfully.", actions: ["Ok"]) { action in
        //                    cell.deliveredButton.thumbTintColor = .green
        //                    cell.deliveredButton.isUserInteractionEnabled = false
//                            cell.deliveredButton.setOn(true, animated: true)
                            cell.deliveredButton.isEnabled = false
                            cell.deliveredButton.thumbTintColor = .green
                            self.sessionDetailsTableView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .none)
//                            self.fetchData()
                        }
                        self.view.isUserInteractionEnabled = true
                        self.hud.dismiss()
                        
                    }
                }
            }

        }
    }
    
    func clockOnStartTimer(startTime: String, endTime: String, clockOffTime: String, currentDate: Date) -> Bool{

        let startDateTime = iso860ToString(dateString: startTime)
        let endDateTime = iso860ToString(dateString: endTime)

        let startTimeMaxValue = startDateTime.addingTimeInterval(600)
        let startTimeMinValue = startDateTime.addingTimeInterval(-600)
//        print(startDateTime, endDateTime, currentDate, startTimeMaxValue, startTimeMinValue)
        let range = startTimeMinValue...startTimeMaxValue
        
        if range.contains(currentDate) {
//            print("The date is inside the range")
            if clockOffTime == ""{
                return true
            }else if currentDate <= endDateTime && clockOffTime != ""{
                return true
            }else{
                return false
            }
        }else{
//            print("The date is outside the range")
            return false
        }
        

    }
    
    @objc func timerCounter (cell: SessionBasicsCell) -> Void{
        timerCount = timerCount + 1
        let time = secondsToHoursMinutesSecons(seconds: timerCount)
        timeString = timeString(hours: time.0, minutes: time.1, seconds: time.2)
        let indexpath = IndexPath(row: 0, section: 0)
        sessionDetailsTableView.reloadRows(at: [indexpath], with: .none)
        
    }
    
    func secondsToHoursMinutesSecons(seconds: Int) -> (Int,Int,Int) {
        return ((seconds / 3600), ((seconds % 3600) / 60), ((seconds % 3600) % 60))
    }
    
    private func timeString(hours: Int, minutes: Int, seconds: Int) -> String {
        var timeString = ""
        timeString += String(format: "%02d", hours)
        timeString += " : "
        timeString += String(format: "%02d", minutes)
        timeString += " : "
        timeString += String(format: "%02d", seconds)
        return timeString
    }
    
}

extension DateComponents {
    
    func dateComponentsToTimeString() -> String {
        
        var hour = "\(self.hour!)"
        var minute = "\(self.minute!)"
        var second = "\(self.second!)"
        
        if self.hour! < 10 { hour = "0" + hour }
        if self.minute! < 10 { minute = "0" + minute }
        if self.second! < 10 { second = "0" + second }
        
        let str = "\(hour):\(minute):\(second)"
        return str
    }
    
}

extension Date {
    
    func offset(from date: Date)-> DateComponents {
        let components = Set<Calendar.Component>([.second, .minute, .hour, .day, .month, .year])
        let differenceOfDate = Calendar.current.dateComponents(components, from: date, to: self)
        return differenceOfDate
    }
}
extension String{
    
    var integer: Int {
        return Int(self) ?? 0
    }
    
    var secondFromString : Int{
        let components: Array = self.components(separatedBy: ":")
        let hours = components[0].integer
        let minutes = components[1].integer
        let seconds = components[2].integer
        return Int((hours * 60 * 60) + (minutes * 60) + seconds)
    }
}
extension SessionDetailsViewController: UITextViewDelegate{
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == "Message"{
            textView.text = ""
        }
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text == ""{
            textView.text = "Message"
        }
    }
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        return true
    }
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool{

        return true
    }
    func textViewDidChange(_ textView: UITextView) {
        self.notesText = textView.text
    }
}

