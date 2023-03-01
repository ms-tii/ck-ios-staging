//
//  AddIncidentViewController.swift
//  CareKernel
//
//  Created by Mohit Sharma on 16/12/21.
//

import UIKit
import SwiftyJSON
import JGProgressHUD
import Alamofire
import SDWebImage
class AddIncidentViewController: UIViewController, UIScrollViewDelegate {
    
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var scrollContentView: UIView!
    @IBOutlet var categoryButton: UIButton!
    @IBOutlet var siteButton: UIButton!
    @IBOutlet var observationDateButton: UIButton!
    @IBOutlet var NDISswitch: UISwitch!
    @IBOutlet var NDISDateButton: UIButton!
    @IBOutlet var descriptionTextView: UITextView!
    @IBOutlet var causeTextView: UITextView!
    @IBOutlet var actionTextView: UITextView!
    @IBOutlet var addWitnessTextView: UITextView!
    @IBOutlet var outcomeTextView: UITextView!
    @IBOutlet var locationTextView: UITextView!
    @IBOutlet var closedOnButton: UIButton!
    @IBOutlet var attachmentButton: UIButton!
    @IBOutlet var fileViewButton: UIButton!
    @IBOutlet var createButton: UIButton!
    @IBOutlet var dropDownBlackView: UIView!
    @IBOutlet var dropDownTableView: UITableView!
    @IBOutlet var dateView: UIView!
    @IBOutlet var datePicker: UIDatePicker!
    @IBOutlet var doneButton: UIButton!
    @IBOutlet weak var priorityButton: UIButton!
    @IBOutlet weak var deleteAttachmentButton: UIButton!
    //    @IBOutlet var dateViewHeightAnchor: NSLayoutConstraint!
    
    let hud = JGProgressHUD()
    var tableArray = NSMutableArray()
    var isCellSelected = Bool()
    var selectedCell = IndexPath()
    var dropDownType = String()
    var isValueChanged = Bool()
    var selectedCatId = Int()
    var selectedSiteId = Int()
    var selectedStatus = String()
    var selectedCatName = String()
    var selectedSiteName = String()
    var selectedValue = String()
    var headerTitle = String()
    var selectedDateType = String()
    var observationDate = String()
    var ndisReportDate = String()
    var closeDate = String()
    var incidentDescription = String()
    var cause = String()
    var action = String()
    var witness = String()
    var outcome = String()
    var locationName = String()
    var attachedImage = UIImage()
    var isReportedNdis = Bool()
    var clientId = 0
    var hasAttachment = Bool()
    var minimumDate = Date()
    var incidentsArray = [String:Any]()
    var isEditIncident = Bool()
    var incidentId = 0
    var scrollOffset : CGFloat = 0
    var distance : CGFloat = 0
    var isKeyboardDismiss = Bool()
    var priorityArray = ["Select", "Low", "High", "Medium"]
    var selectedPriority = String()
    var hasOldAttachment = Bool()
    var hasNewAttachment  = Bool()
    var oldAttachedFileName = String()
    var oldAttachedImage = UIImage()
    var attachedFilesArray = NSMutableArray()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        clientId = careKernelDefaults.value(forKey: "clientID") as! Int
        configureUI()
        siteButton.titleLabel?.lineBreakMode = .byTruncatingTail
        scrollView.isDirectionalLockEnabled = true
        if incidentsArray.count != 0 {
            self.view.isUserInteractionEnabled = false
            hud.show(in: self.view)
            print(incidentsArray)
            isEditIncident = true
            setEditUI()
        }
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        setupTextFields()
        deleteAttachmentButton.isHidden = true
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        switch UIDevice().type {
        case .iPhone5, .iPhone5C, .iPhone5S, .iPhoneSE, .iPhoneSE2, .iPhone6, .iPhone6S, .iPhone7, .iPhone8 :
            scrollView.contentSize.height = scrollContentView.frame.size.height + 100
            
        case .iPhone6SPlus, .iPhone7Plus, .iPhone8Plus :
            scrollView.contentSize.height = scrollContentView.frame.size.height + 100
            //            dateViewHeightAnchor.constant = doneButton.frame.origin.y + doneButton.frame.size.height
            //            dateViewHeightAnchor.isActive = true
        default:
            //            scrollView.contentSize.height = scrollContentView.frame.size.height + 100
            break
        }
        self.view.layoutIfNeeded()
    }
    
    @IBAction func deleteAttachmentButton(_ sender: UIButton) {
  
        deleteAttachmentButton.isHidden = true
            if hasOldAttachment {
                    self.fileViewButton.setTitle("Files", for: .normal)
                    self.attachedImage = oldAttachedImage
                    hasNewAttachment = false
            }else{
                self.fileViewButton.isHidden = true
                hasAttachment = false
            }
        
    }
    @IBAction func priorityButtonAction(_ sender: UIButton) {
        isKeyboardDismiss = true
        view.endEditing(true)
        headerTitle = "Priority"
        dropDownType = "Priority"
        setTableHeader()
        self.tableArray.removeAllObjects()
        for value in priorityArray {
            let values = ["name": value, "id": "0"] as [String : Any]
            self.tableArray.add(values)
        }
        self.dropDownTableView.reloadData()
        self.dropDownBlackView.isHidden = false
        self.dropDownTableView.isHidden = false
        self.dateView.isHidden = true
        
    }
    
    @IBAction func dropDownviewCloseButton(_ sender: UIButton) {
        self.dropDownBlackView.isHidden = true
        self.dropDownTableView.isHidden = true
        self.dateView.isHidden = true
    }
    
    @IBAction func backButtonAction(_ sender: UIButton) {
        self.dismiss(animated: true)
        
    }
    
    @IBAction func categoryButton(_ sender: UIButton) {
        isKeyboardDismiss = true
        view.endEditing(true)
        headerTitle = "Category"
        dropDownType = "Category"
        setTableHeader()
        callValuesApi(type: "incident-categories")
        
    }
    
    @IBAction func siteButtonAction(_ sender: UIButton) {
        isKeyboardDismiss = true
        view.endEditing(true)
        headerTitle = "Site"
        dropDownType = "Site"
        setTableHeader()
        callValuesApi(type: "sites")
        
    }
    
    @IBAction func observationButtonAction(_ sender: UIButton) {
        isKeyboardDismiss = true
        view.endEditing(true)
        self.dropDownBlackView.isHidden = false
        self.dropDownTableView.isHidden = true
        self.dateView.isHidden = false
        self.selectedDateType = "observation"
        self.datePicker.minimumDate = .distantPast
        self.datePicker.maximumDate = Date()
        if isEditIncident {
            let date = iso860ToString(dateString: observationDate)
            self.datePicker.setDate(date, animated: true)
        }
        
        //        dateView.heightAnchor.constraint(equalToConstant: (doneButton.frame.origin.y + doneButton.frame.size.height)).isActive = true
        //        dateViewHeightAnchor.constant = doneButton.frame.origin.y + doneButton.frame.size.height
        //        dateViewHeightAnchor.isActive = true
        self.view.layoutIfNeeded()
        
    }
    
    @IBAction func ndisButtonAction(_ sender: UIButton) {
        isKeyboardDismiss = true
        view.endEditing(true)
        self.dropDownBlackView.isHidden = false
        self.dropDownTableView.isHidden = true
        self.dateView.isHidden = false
        self.selectedDateType = "ndisreport"
        self.datePicker.minimumDate = minimumDate
        
        if isEditIncident {
            let date = iso860ToString(dateString: ndisReportDate)
            self.datePicker.setDate(date, animated: true)
        }else{
            self.datePicker.maximumDate = Date()
        }
    }
    
    @IBAction func closeButtonAction(_ sender: UIButton) {
        isKeyboardDismiss = true
        view.endEditing(true)
        self.dropDownBlackView.isHidden = false
        self.dropDownTableView.isHidden = true
        self.dateView.isHidden = false
        self.selectedDateType = "closeon"
        self.datePicker.minimumDate = minimumDate
        
        self.view.layoutIfNeeded()
        if isEditIncident {
            let date = iso860ToString(dateString: closeDate)
            self.datePicker.setDate(date, animated: true)
        }else{
            self.datePicker.maximumDate = Date()
        }
    }
    
    @IBAction func attachmentButtonAction(_ sender: UIButton) {
        AttachmentHandler.shared.showAttachmentActionSheet(vc: self)
        AttachmentHandler.shared.imagePickedBlock = { (image) in
            /* get your image here */
            if image.size.width != 0 {
                DispatchQueue.main.async {
                    self.fileViewButton.isHidden = false
                    self.fileViewButton.setTitle("CN-00.png", for: .normal)
                    self.deleteAttachmentButton.isHidden = false
                    self.attachedImage = image
                    self.hasAttachment = true
                    self.hasNewAttachment = true
                }
            }
        }
    }
    
    @IBAction func createButtonAction(_ sender: UIButton) {
        var hasError = Bool()
        
        
        let param : [String:Any] = ["categoryId":selectedCatId, "siteId":selectedSiteId,
                                    "observationDate":observationDate, "isReportableToNdis": isReportedNdis, "reportedToNdisAt":ndisReportDate, "description":incidentDescription, "causeDetails":cause, "actionDetails":action, "witness":witness, "outcomeDetails":outcome, "exactLocationOfClient":locationName,
                                    "priority": selectedPriority.lowercased(),
                                    "closedAt":closeDate, "clientId":self.clientId]
        
        let tempArray = NSMutableArray()
        tempArray.insert(["categoryId": selectedCatId], at: 0)
        tempArray.insert(["observationDate": observationDate], at: 1)
        tempArray.insert(["description": incidentDescription], at: 2)
        tempArray.insert(["priority": selectedPriority], at: 3)
        for (key, value) in tempArray.enumerated() {
            
            switch key {
            case 0 :
                if JSON(value)["categoryId"].intValue == 0 {
                    print("Category cannot be empty")
                    hasError = true
                    self.showAlert("Alert!", message: "Category cannot be empty", actions: ["Ok"]) { actionTitle in
                        let cgpoint = CGPoint(x: 0.0, y: 0.0)
                        self.scrollView.contentOffset = cgpoint
                    }
                }
                break
            case 1 :
                if JSON(value)["observationDate"].stringValue == "" {
                    print("Observation date cannot be empty")
                    hasError = true
                    self.showAlert("Alert!", message: "Observation date cannot be empty", actions: ["Ok"]) { actionTitle in
                        let cgpoint = CGPoint(x: 0.0, y: self.siteButton.frame.origin.y)
                        self.scrollView.contentOffset = cgpoint
                    }
                }
                break
            case 2 :
                if JSON(value)["description"].stringValue == "" {
                    print("Description cannot be empty")
                    hasError = true
                    self.showAlert("Alert!", message: "Description cannot be empty", actions: ["Ok"]) { actionTitle in
                        let cgpoint = self.descriptionTextView.frame.origin
                        self.scrollView.contentOffset = cgpoint
                        self.descriptionTextView.becomeFirstResponder()
                    }
                }
                break
            case 3 :
                if JSON(value)["priority"].stringValue == "" {
                    print("Description cannot be empty")
                    hasError = true
                    self.showAlert("Alert!", message: "Priority cannot be empty", actions: ["Ok"]) { actionTitle in
                        let cgpoint = CGPoint(x: 0.0, y: self.locationTextView.frame.origin.y)
                        self.scrollView.contentOffset = cgpoint
                    }
                }
                break
            default : break
                
            }
        }
        if !hasError {
            self.view.isUserInteractionEnabled = false
            hud.show(in: self.view)
            if isEditIncident {
                callToUpdateApi(params: param)
            }else{
                callToCreateApi(params: param)
            }
            
        }
        
        
        
    }
    
    
    
    @IBAction func fileViewButtonAction(_ sender: UIButton) {
        if !hasNewAttachment {
                self.performSegue(withIdentifier: "segueToFiles", sender: nil)
        }else{
            self.performSegue(withIdentifier: "segueToShowFile", sender: self.attachedImage)
        }
    }
    
    @IBAction func addTaskButtonAction(_ sender: UIButton) {
        self.performSegue(withIdentifier: "segueToAddTask", sender: self.attachedImage)
    }
    
    @IBAction func doneButtonAction(_ sender: UIButton) {
        if selectedDateType == "observation" {
            if observationDate == "" {
                setDateUI(selectedDate: Date())
            }
        }else if selectedDateType == "ndisreport"{
            if ndisReportDate == "" {
                setDateUI(selectedDate: Date())
            }
        }else{
            if closeDate == "" {
                setDateUI(selectedDate: Date())
            }
        }
        
        self.dropDownBlackView.isHidden = true
        self.dropDownTableView.isHidden = true
        self.dateView.isHidden = true
    }
    
    @IBAction func cancleButtonAction(_ sender: UIButton) {
        
        if selectedDateType == "observation" {
            observationDate = ""
            self.observationDateButton.setTitle("Select", for: .normal)
        }else if selectedDateType == "ndisreport"{
            ndisReportDate = ""
            NDISDateButton.setTitle("Select", for: .normal)
        }else{
            closeDate = ""
            closedOnButton.setTitle("Select", for: .normal)
        }
        self.dropDownBlackView.isHidden = true
        self.dropDownTableView.isHidden = true
        self.dateView.isHidden = true
    }
    
    @IBAction func datePickerValueChanged(_ sender: UIDatePicker) {
        setDateUI(selectedDate: datePicker.date)
    }
    @IBAction func ndisReportSwitch(_ sender: UISwitch) {
        isKeyboardDismiss = true
        view.endEditing(true)
        if sender.isOn {
            isReportedNdis = true
        }else{
            isReportedNdis = false
        }
    }
    
    func callToCreateApi(params: [String: Any]){
        var incidentVM = IncidentViewModel()
        guard let token = careKernelDefaults.value(forKey: kLoginToken) as? String else {
            careKernelDefaults.set(false, forKey: kIsLoggedIn)
            return }
        incidentVM.token = token
        incidentVM.clientId = self.clientId
        
        incidentVM.createIncident(param: params) { response, success in
            if success {
                if self.hasAttachment {
                    var fileName = JSON(response)["displayId"].stringValue
                    var incId = JSON(response)["id"].intValue
                    fileName = fileName + ".jpg"
                    let fileData = self.attachedImage.jpegData(compressionQuality: 0.3)
                    
                    incidentVM.uploadDocuments(fileName: fileName, fileData: fileData ?? Data(), entity: "incidents", clientID: self.clientId, entityID: incId){ success in
                        if success {
                            self.showAlert("CareKernel", message: "Incident added successfully.", actions: ["Ok"]) { action in
                                if action == "Ok" {
                                    self.hasAttachment = false
                                    self.dismiss(animated: true)
                                }
                            }
                            self.view.isUserInteractionEnabled = true
                            self.hud.dismiss()
                        }
                    }
                }else{
                    self.showAlert("CareKernel", message: "Incident added successfully.", actions: ["Ok"]) { action in
                        if action == "Ok" {
                            self.view.isUserInteractionEnabled = true
                            self.hud.dismiss()
                            self.dismiss(animated: true)
                            
                        }
                    }
                    
                }
            }else{
                self.view.isUserInteractionEnabled = true
                self.hud.dismiss()
                let error = JSON(response)["message"].stringValue
                self.showAlert("CareKernel", message: error, actions: ["OK"]) { actionTitle in
                }
            }
        }
    }
    
    func callToUpdateApi(params: [String: Any]){
        var incidentVM = IncidentViewModel()
        guard let token = careKernelDefaults.value(forKey: kLoginToken) as? String else {
            careKernelDefaults.set(false, forKey: kIsLoggedIn)
            return }
        incidentVM.token = token
        incidentVM.clientId = self.clientId
        
        incidentVM.updateIncident(incidentId: self.incidentId,param: params) { response, success in
            self.view.isUserInteractionEnabled = true
            self.hud.dismiss()
            if success {
                if self.hasAttachment {
                    var fileName = JSON(response)["displayId"].stringValue
                    var incId = JSON(response)["id"].intValue
                    fileName = fileName + ".jpg"
                    let fileData = self.attachedImage.jpegData(compressionQuality: 0.3)
                    
                    incidentVM.uploadDocuments(fileName: fileName, fileData: fileData ?? Data(), entity: "incidents", clientID: self.clientId, entityID: incId){ success in
                        if success {
                            self.showAlert("CareKernel", message: "Incident added successfully", actions: ["Ok"]) { action in
                                if action == "Ok" {
                                    self.hasAttachment = false
                                    self.dismiss(animated: true)
                                }
                            }
                            self.view.isUserInteractionEnabled = true
                            self.hud.dismiss()
                        }
                    }
                }else{
                    self.showAlert("CareKernel", message: "Incident added successfully", actions: ["Ok"]) { action in
                        if action == "Ok" {
                            self.view.isUserInteractionEnabled = true
                            self.hud.dismiss()
                            self.dismiss(animated: true)
                            
                        }
                    }
                    
                }
            }else{
                let error = JSON(response)["message"].stringValue
                self.showAlert("CareKernel", message: error, actions: ["OK"]) { actionTitle in
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
    
    func configureUI(){
        dropDownBlackView.isHidden = true
        self.dropDownTableView.isHidden = true
        self.dateView.isHidden = true
        categoryButton.addBorderCorner(cornerRadius: 8, borderColor: UIColor(named: "Light Grey Font") ?? UIColor(), borderWidth: 1)
        siteButton.addBorderCorner(cornerRadius: 8, borderColor: UIColor(named: "Light Grey Font") ?? UIColor(), borderWidth: 1)
        observationDateButton.addBorderCorner(cornerRadius: 8, borderColor: UIColor(named: "Light Grey Font") ?? UIColor(), borderWidth: 1)
        NDISDateButton.addBorderCorner(cornerRadius: 8, borderColor: UIColor(named: "Light Grey Font") ?? UIColor(), borderWidth: 1)
        closedOnButton.addBorderCorner(cornerRadius: 8, borderColor: UIColor(named: "Light Grey Font") ?? UIColor(), borderWidth: 1)
        priorityButton.addBorderCorner(cornerRadius: 8, borderColor: UIColor(named: "Light Grey Font") ?? UIColor(), borderWidth: 1)
        attachmentButton.addBorderCorner(cornerRadius: 15)
        attachmentButton.titleLabel?.numberOfLines = 1;
        attachmentButton.titleLabel?.adjustsFontSizeToFitWidth = true
        createButton.addBorderCorner(cornerRadius: 4)
        
        
        //        if !isReportedNdis {
        //            NDISDateButton.isUserInteractionEnabled = false
        //        }
        
        categoryButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: (self.categoryButton.bounds.width - 50), bottom: 0, right: 0)
        categoryButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: (-10), bottom: 0, right: 0)
        siteButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: (self.siteButton.bounds.width - 50), bottom: 0, right: 0)
        siteButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: (-10), bottom: 0, right: 60)
        observationDateButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: (self.observationDateButton.bounds.width - 50), bottom: 0, right: 0)
        observationDateButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: (-10), bottom: 0, right: 0)
        NDISDateButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: (self.NDISDateButton.bounds.width - 50), bottom: 0, right: 0)
        NDISDateButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: (-10), bottom: 0, right: 0)
        priorityButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: (self.priorityButton.bounds.width - 50), bottom: 0, right: 0)
        priorityButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: (-10), bottom: 0, right: 0)
        closedOnButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: (self.closedOnButton.bounds.width - 50), bottom: 0, right: 0)
        closedOnButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: (-10), bottom: 0, right: 0)
        
        if !hasAttachment {
            fileViewButton.isHidden = true
        }
    }
    
    func setEditUI(){
        
        selectedCatId = JSON(incidentsArray)["category"]["id"].intValue
        selectedCatName = JSON(incidentsArray)["category"]["name"].stringValue
        self.categoryButton.setTitle(selectedCatName, for: .normal)
        selectedSiteId = JSON(incidentsArray)["site"]["id"].intValue
        selectedSiteName = JSON(incidentsArray)["site"]["name"].stringValue
        if selectedSiteName != "" {
            self.siteButton.setTitle(selectedSiteName, for: .normal)
        }
        observationDate = JSON(incidentsArray)["observationDate"].stringValue
        if observationDate != "" {
            let observationDateString = getFormattedDate(date: iso860ToString(dateString: observationDate), format: "dd/MM/yyyy")
            self.observationDateButton.setTitle(observationDateString, for: .normal)
        }
        isReportedNdis = JSON(incidentsArray)["isReportableToNdis"].boolValue
        if isReportedNdis {
            NDISswitch.isOn = true
            
        }else{
            NDISswitch.isOn = false
            
        }
        ndisReportDate = JSON(incidentsArray)["reportedToNdisAt"].stringValue
        if ndisReportDate != "" {
            let ndisReportDateString = getFormattedDate(date: iso860ToString(dateString: ndisReportDate), format: "dd/MM/yyyy")
            self.NDISDateButton.setTitle(ndisReportDateString, for: .normal)
        }
        incidentDescription = JSON(incidentsArray)["description"].stringValue
        if incidentDescription != "" {
            descriptionTextView.text = incidentDescription
        }
        action = JSON(incidentsArray)["actionDetails"].stringValue
        if action != "" {
            actionTextView.text = action
        }
        witness =  JSON(incidentsArray)["witness"].stringValue
        if witness != "" {
            addWitnessTextView.text = witness
        }
        cause =  JSON(incidentsArray)["causeDetails"].stringValue
        if cause != "" {
            causeTextView.text = cause
        }
        outcome = JSON(incidentsArray)["outcomeDetails"].stringValue
        if outcome != "" {
            outcomeTextView.text = outcome
        }
        locationName = JSON(incidentsArray)["exactLocationOfClient"].stringValue
        if locationName != "" {
            locationTextView.text = locationName
        }
        self.selectedPriority = JSON(incidentsArray)["priority"].stringValue
        if selectedPriority != "" {
            self.priorityButton.setTitle(self.selectedPriority.capitalized, for: .normal)
        }
        
        closeDate = JSON(incidentsArray)["closedAt"].stringValue
        if closeDate != "" {
            let closedONDateString = getFormattedDate(date: iso860ToString(dateString: closeDate), format: "dd/MM/yyyy")
            self.closedOnButton.setTitle(closedONDateString, for: .normal)
        }
        let displayID = JSON(incidentsArray)["displayId"].stringValue
        titleLabel.text = "\(displayID)"
        let selectedIncidentId = JSON(incidentsArray)["id"].intValue
        self.incidentId = selectedIncidentId
        createButton.setTitle("Update", for: .normal)
//        attachmentButton.isHidden = true
//        fileViewButton.isHidden = true
        let attachedFiles = JSON(incidentsArray)["files"].arrayValue
        
        if attachedFiles.count > 0 {
            for arr in attachedFiles {
                self.attachedFilesArray.add(arr.dictionaryObject!)
            }
            self.hasOldAttachment = true
            self.deleteAttachmentButton.isHidden = true
            self.hasAttachment = true
            self.fileViewButton.isHidden = false
            let fileURL = JSON(attachedFiles)[0]["url"].stringValue
            let fileName = JSON(attachedFiles)[0]["name"].stringValue
            self.oldAttachedFileName = fileName
            self.fileViewButton.setTitle("Files", for: .normal)
            
            SDWebImageManager.shared.loadImage(
                with:URL(string: fileURL),
                options: .continueInBackground, // or .highPriority
                progress: nil,
                completed: { [weak self] (image, data, error, cacheType, finished, url) in
                    guard self != nil else { return }
                    
                    if error != nil {
                        // Do something with the error
                        return
                    }
                    
                    guard image != nil else {
                        // No image handle this error
                        return
                    }
                    
                    // Do something with image
                    self?.attachedImage = image ?? UIImage(named: "FilesPlaceholder")!
                    self?.oldAttachedImage = self?.attachedImage ?? UIImage(named: "FilesPlaceholder")!
                    self?.view.isUserInteractionEnabled = true
                    self?.hud.dismiss()
                }
            )
            
            
        }else{
            self.hasOldAttachment = false

        }
//        createButton.topAnchor.constraint(equalTo: closedOnButton.bottomAnchor, constant: 24).isActive = true
        
    }
    
    
    func callValuesApi(type: String){
        self.tableArray.removeAllObjects()
        var incidentVM = IncidentViewModel()
        guard let token = careKernelDefaults.value(forKey: kLoginToken) as? String else {
            careKernelDefaults.set(false, forKey: kIsLoggedIn)
            return }
        incidentVM.token = token
        incidentVM.getCategorySiteList(type: type) { response, success in
            if success {
                DispatchQueue.main.async {
                    let tempArray = JSON(response)["data"].arrayValue
                    var arr = [[String:Any]]()
                    let names = "Select"
                    let namesId = 0
                    let values = ["name": names, "id": namesId] as [String : Any]
                    arr.insert(values, at: 0)
                    self.tableArray.insert(values, at: 0)
                    if tempArray.count != 0 {
                        for value in tempArray {
                            //                            self.incidentsArray.add(value)
                            let names = JSON(value)["name"].stringValue
                            let ids = JSON(value)["id"].intValue
                            let values = ["name": names, "id": ids] as [String : Any]
                            self.tableArray.add(values)
                            arr.append(values)
                        }
                        
                        if self.isEditIncident {
                            self.isCellSelected = true
                            if type == "incident-categories" {
                                if self.selectedCatName != ""{
                                    let indexOfItem = arr.firstIndex(where: { ( $0["name"] as? String == self.selectedCatName ) })! as Int
                                    self.selectedCell = IndexPath(row: indexOfItem, section: 0)
                                }
                            }else{
                                if self.selectedSiteName != ""{
                                    let indexOfItem = arr.firstIndex(where: { ( $0["name"] as? String == self.selectedSiteName ) })! as Int
                                    self.selectedCell = IndexPath(row: indexOfItem, section: 0)
                                }
                            }
                        }else{
                            if type == "incident-categories" {
                                if self.selectedCatName == ""{
                                    self.isCellSelected = false
                                }
                            }else{
                                if self.selectedSiteName == ""{
                                    self.isCellSelected = false
                                }
                            }
                            
                        }
                        
                        //                        self.tableArray.insert(values, at: 0)
                        print(self.tableArray)
                        
                        self.dropDownTableView.reloadData()
                        self.dropDownBlackView.isHidden = false
                        self.dropDownTableView.isHidden = false
                    }
                }
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
    
    func setDateUI(selectedDate: Date){
        let date = getFormattedDate(date: selectedDate, format: "dd/MM/yyyy")
        print(date)
        let iso8601DateFormatter = ISO8601DateFormatter()
        iso8601DateFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        let dateString = iso8601DateFormatter.string(from: selectedDate)
        if selectedDateType == "observation" {
            minimumDate = selectedDate
            self.observationDate = dateString
            observationDateButton.setTitle(date, for: .normal)
            //            observationDateButton.setTitleColor(UIColor(named: "Basic BlueWhite font"), for: .normal)
            
        }else if selectedDateType == "ndisreport"{
            self.ndisReportDate = dateString
            NDISDateButton.setTitle(date, for: .normal)
            //            toDateButton.setTitleColor(UIColor(named: "Basic BlueWhite font"), for: .normal)
            //            toDateButton.backgroundColor = #colorLiteral(red: 0.1529411765, green: 0.2274509804, blue: 0.8078431373, alpha: 0.2574060705)
            
        }else{
            self.closeDate = dateString
            closedOnButton.setTitle(date, for: .normal)
        }
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let vc = segue.destination as? FilesImageViewController {
            vc.fileImage = sender as! UIImage
            
        }else if let vc = segue.destination as? FilesListViewController {
            vc.filesArray = attachedFilesArray
            vc.titleName = "Incident Files"
        }
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            
            
            
            let activeField: UIView? = [descriptionTextView, causeTextView, actionTextView, addWitnessTextView, outcomeTextView, locationTextView].first { $0.isFirstResponder }
            if let activeField = activeField {
                
                let distanceToBottom = self.scrollView.frame.size.height - (activeField.frame.origin.y) - (activeField.frame.size.height)
                let collapseSpace = keyboardSize.height - distanceToBottom
                if collapseSpace < 0 {
                    // no collapse
                    return
                }
                // set new offset for scroll view
                UIView.animate(withDuration: 0.3, animations: {
                    // scroll to the position above keyboard 10 points
                    self.scrollView.contentOffset = CGPoint(x:0, y: collapseSpace + 10)
                })
            }
            // prevent scrolling while typing
            
            //            scrollView.isScrollEnabled = false
        }
    }
    @objc func keyboardWillHide(notification: NSNotification) {
        if distance == 0 {
            return
        }
        // return to origin scrollOffset
        self.scrollView.setContentOffset(CGPoint(x: 0, y: scrollOffset), animated: true)
        scrollOffset = 0
        distance = 0
        scrollView.isScrollEnabled = true
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        isKeyboardDismiss = true
        view.endEditing(true)
        
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        scrollView.contentOffset.x = 0.0
    }
    
    func setupTextFields() {
        let toolbar = UIToolbar()
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace,
                                        target: nil, action: nil)
        let doneButton = UIBarButtonItem(title: "Done", style: .done,
                                         target: self, action: #selector(doneButtonTapped))
        
        toolbar.setItems([flexSpace, doneButton], animated: true)
        toolbar.sizeToFit()
        
            descriptionTextView.inputAccessoryView = toolbar
            causeTextView.inputAccessoryView = toolbar
            actionTextView.inputAccessoryView = toolbar
            addWitnessTextView.inputAccessoryView = toolbar
            outcomeTextView.inputAccessoryView = toolbar
            locationTextView.inputAccessoryView = toolbar
    }
    
    @objc func doneButtonTapped() {
        view.endEditing(true)
    }
}

extension AddIncidentViewController : UITableViewDelegate, UITableViewDataSource {
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DropDownCell", for: indexPath) as! DropDownCell
        
        let nameValue = JSON(tableArray)[indexPath.row]["name"].stringValue
        cell.nameLabel.text = nameValue
        cell.tickImage.image = nil
        
        switch dropDownType {
        case "Category":
            if incidentId == 0 {
                isCellSelected = false
                if nameValue == selectedCatName {
                    isCellSelected = true
                    self.selectedCell = indexPath
                }
            }
            
            break
        case "Site":
            if incidentId == 0 {
                isCellSelected = false
                if nameValue == selectedSiteName {
                    isCellSelected = true
                    self.selectedCell = indexPath
                }
            }
            break
        case "Priority":
            if incidentId == 0 {
                isCellSelected = false
                if nameValue == selectedPriority {
                    isCellSelected = true
                    self.selectedCell = indexPath
                }
            }
            
            break
        default:
            break
        }
        
        if isCellSelected && selectedCell == indexPath{
            cell.tickImage.image = #imageLiteral(resourceName: "tick")
        }else{
            cell.tickImage.image = nil
        }
        if indexPath.row == tableArray.count - 1 {
            cell.layer.cornerRadius = 8
            cell.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        }else{
            cell.layer.cornerRadius = 0
            cell.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedCell = indexPath
        switch dropDownType {
        case "Category":
            if selectedValue != self.categoryButton.title(for: .normal){
                isValueChanged = true
                selectedCatId = JSON(tableArray)[indexPath.row]["id"].intValue
                selectedCatName = JSON(tableArray)[indexPath.row]["name"].stringValue
                self.categoryButton.setTitle(selectedCatName, for: .normal)
                
            }
            break
        case "Site":
            
            if selectedValue != self.siteButton.title(for: .normal){
                isValueChanged = true
                selectedSiteId = JSON(tableArray)[indexPath.row]["id"].intValue
                selectedSiteName = JSON(tableArray)[indexPath.row]["name"].stringValue
                self.siteButton.setTitle(selectedSiteName, for: .normal)
                
            }
            break
        case "Priority":
            if selectedValue != self.priorityButton.title(for: .normal){
                isValueChanged = true
                selectedPriority = JSON(tableArray)[indexPath.row]["name"].stringValue
                self.priorityButton.setTitle(selectedPriority, for: .normal)
                
                
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
extension AddIncidentViewController: UITextViewDelegate{
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == "Add Text Here"{
            textView.text = ""
        }
    }
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text == ""{
            textView.text = "Add Text Here"
        }
        if !isKeyboardDismiss {
            if textView == descriptionTextView{
                causeTextView.becomeFirstResponder()
            }else if textView == causeTextView{
                actionTextView.becomeFirstResponder()
            }else if textView == actionTextView{
                addWitnessTextView.becomeFirstResponder()
            }else if textView == addWitnessTextView{
                outcomeTextView.becomeFirstResponder()
            }else if textView == outcomeTextView{
                locationTextView.becomeFirstResponder()
            }else if textView == locationTextView{
                self.resignFirstResponder()
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
        if textView == locationTextView{
            if text == "\n" {
                isKeyboardDismiss = false
                textView.resignFirstResponder()
                
                return false
            }
        }
        
        return true
    }
    func textViewDidChange(_ textView: UITextView) {
        print(textView)
        if textView == descriptionTextView{
            incidentDescription = textView.text
        }else if textView == causeTextView{
            cause = textView.text
        }else if textView == actionTextView{
            action = textView.text
        }else if textView == addWitnessTextView{
            witness = textView.text
        }else if textView == outcomeTextView{
            outcome = textView.text
        }else if textView == locationTextView{
            locationName = textView.text
        }
        
    }
    
}

//extension AddIncidentViewController: UIScrollViewDelegate {
//    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
//        let bottomEdge = scrollView.contentOffset.y + scrollView.frame.size.height;
//        if (bottomEdge >= scrollView.contentSize.height) {
//
//            switch UIDevice().type {
//            case .iPhone5, .iPhone5C, .iPhone5S, .iPhoneSE, .iPhoneSE2, .iPhone6, .iPhone6S, .iPhone7, .iPhone8 :
//                scrollContentView.heightAnchor.constraint(equalToConstant: scrollView.contentSize.height + 1000).isActive = true
//                scrollView.contentSize.height = scrollContentView.frame.size.height + 100
//
//            case .iPhone6SPlus, .iPhone7Plus, .iPhone8Plus :
//                scrollContentView.heightAnchor.constraint(equalToConstant: scrollView.contentSize.height + 800).isActive = true
//                scrollView.contentSize.height = scrollContentView.frame.size.height + 100
//            default:
//                scrollContentView.heightAnchor.constraint(equalToConstant: scrollView.contentSize.height + 800).isActive = true
//                break
//            }
//
//            self.view.layoutIfNeeded()
//        }
//    }
//}
