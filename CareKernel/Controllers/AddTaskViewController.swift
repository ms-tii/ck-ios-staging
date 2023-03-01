//
//  AddTaskViewController.swift
//  CareKernel
//
//  Created by Mohit Sharma on 03/01/22.
//

import UIKit
import SwiftyJSON
import JGProgressHUD
import Alamofire
import SDWebImage

class AddTaskViewController: UIViewController {
    
    @IBOutlet var titleNameTextView: UITextView!
    @IBOutlet var descriptionTextView: UITextView!
    @IBOutlet var assignToButton: UIButton!
    @IBOutlet var dueDateButton: UIButton!
    @IBOutlet var priorityButton: UIButton!
    @IBOutlet var categoryButton: UIButton!
    @IBOutlet var statusButton: UIButton!
    @IBOutlet var attachmentButton: UIButton!
    @IBOutlet var fileViewButton: UIButton!
    @IBOutlet var createButton: UIButton!
    @IBOutlet var dropDownBlackView: UIView!
    @IBOutlet var dropDownTableView: UITableView!
    @IBOutlet var dateView: UIView!
    @IBOutlet var datePicker: UIDatePicker!
    @IBOutlet var doneButton: UIButton!
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var scrollContentView: UIView!
    @IBOutlet var screenTitleLabel: UILabel!
    @IBOutlet var deleteAttachmentButton: UIButton!
    
    let hud = JGProgressHUD()
    var tableArray = NSMutableArray()
    var isCellSelected = Bool()
    var selectedCell = IndexPath()
    var selectedCellAdd = IndexPath()
    var dropDownType = String()
    var selectedValue = String()
    var isValueChanged = Bool()
    var statusArray = ["To Do","In Progress","Blocked","Done"]
    var priorityArray = ["Select", "Low", "High", "Medium"]
    var nameArray = [""]
    var namesId = [0]
    var selectedAssignee = String()
    var selectedAssigneeId = 0
    var selectedCategory = String()
    var selectedCategoryId = 0
    var selectedStatus = String()
    var selectedPriority = String()
    var selectedDate = String()
    var taskTitle = String()
    var taskDescription = String()
    var hasAttachment = Bool()
    var attachedImage = UIImage()
    var isKeyboardDismiss = Bool()
    var taskId = 0
    var hasOldAttachment = Bool()
    var oldAttachedFileName = String()
    var oldAttachedImage = UIImage()
    var hasNewAttachment  = Bool()
    var attachedFilesArray = NSMutableArray()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.view.isUserInteractionEnabled = false
        hud.show(in: self.view)
        configureUI()
    }
    @IBAction func doneButtonAction(_ sender: UIButton) {
        if selectedDate == ""{
            setDateUI(selectedDate: Date())
        }
        dropDownBlackView.isHidden = true
        self.dropDownTableView.isHidden = true
        self.dateView.isHidden = true
    }
    
    @IBAction func backButtonAction(_ sender: UIButton) {
        self.dismiss(animated: true)
    }
    
    @IBAction func cancleButtonAction(_ sender: UIButton) {
        selectedDate = ""
        self.dueDateButton.setTitle("Select", for: .normal)
        dropDownBlackView.isHidden = true
        self.dropDownTableView.isHidden = true
        self.dateView.isHidden = true
    }
    
    @IBAction func notificationButton(_ sender: UIButton) {
        self.performSegue(withIdentifier: "segueToNotification", sender: nil)
    }
    
    @IBAction func addAttachmentAction(_ sender: UIButton) {
        self.hasAttachment = true
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
            }else{
                self.hasAttachment = false
            }
        }
    }
    
    @IBAction func deleteAttachmentAction(_ sender: UIButton) {
        
        if hasOldAttachment {
            self.fileViewButton.setTitle("Files", for: .normal)
            self.attachedImage = oldAttachedImage
            self.fileViewButton.isHidden = false
            hasNewAttachment = false
        }else{
            self.fileViewButton.isHidden = true
            hasAttachment = false
        }
        self.deleteAttachmentButton.isHidden = true
    }
    @IBAction func fileViewButonAction(_ sender: UIButton) {
        if !hasNewAttachment {
            self.performSegue(withIdentifier: "segueToFiles", sender: nil)
        }else{
            if attachedImage.size.width != 0 {
                self.resignFirstResponder()
                self.performSegue(withIdentifier: "segueToShowFile", sender: self.attachedImage)
            }
        }
        
        
    }
    
    @IBAction func createTaskAction(_ sender: UIButton) {
        var hasError = Bool()
        let date = self.iso860ToString(dateString: selectedDate)
        let formatedSelectedDate = self.getFormattedDate(date: date, format: "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'")
        let taskParam =  [
            "title": taskTitle,
            "description": taskDescription,
            "priority": selectedPriority.lowercased(),
            "dueDate": formatedSelectedDate,
            "taskStatus": selectedStatus,
            "categoryId": selectedCategoryId,
            "assigneeId": selectedAssigneeId
        ] as [String : Any]
        let tempArray = NSMutableArray()
        tempArray.insert(["title": taskTitle], at: 0)
        tempArray.insert(["description": taskDescription], at: 1)
        tempArray.insert(["assigneeId": selectedAssigneeId], at: 2)
        tempArray.insert(["dueDate": selectedDate], at: 3)
        tempArray.insert(["priority": selectedPriority], at: 4)
        tempArray.insert(["categoryId": selectedCategoryId], at: 5)
        tempArray.insert(["taskStatus": selectedStatus], at: 6)
        print(taskParam)
        for (key, value) in tempArray.enumerated() {
            
            switch key {
            case 0 :
                if JSON(value)["title"].stringValue == "" {
                    hasError = true
                    self.showAlert("Alert!", message: "Task title cannot be empty.", actions: ["Ok"]) { actionTitle in
                        let cgpoint = CGPoint(x: 0.0, y: self.titleNameTextView.frame.origin.y)
                        self.scrollView.contentOffset = cgpoint
                        self.titleNameTextView.becomeFirstResponder()
                    }
                }
                break
            case 1 :
                if JSON(value)["description"].stringValue == "" {
                    hasError = true
                    self.showAlert("Alert!", message: "Task description cannot be empty.", actions: ["Ok"]) { actionTitle in
                        let cgpoint = CGPoint(x: 0.0, y: self.descriptionTextView.frame.origin.y)
                        self.scrollView.contentOffset = cgpoint
                        self.descriptionTextView.becomeFirstResponder()
                    }
                }
                break
            case 2 :
                if JSON(value)["assigneeId"].intValue == 0 {
                    hasError = true
                    self.showAlert("Alert!", message: "Please select assignee", actions: ["Ok"]) { actionTitle in
                        
                    }
                }
                
                break
            case 3 :
                if JSON(value)["dueDate"].stringValue == "" {
                    hasError = true
                    self.showAlert("Alert!", message: "Please select task due date.", actions: ["Ok"]) { actionTitle in
                        
                    }
                }
                break
            case 4 :
                if JSON(value)["priority"].stringValue == "" ||  JSON(value)["priority"].stringValue == "Select" {
                    hasError = true
                    self.showAlert("Alert!", message: "Please select task priority.", actions: ["Ok"]) { actionTitle in
                        
                    }
                }
                
                break
            case 5 :
                if JSON(value)["categoryId"].intValue == 0 {
                    hasError = true
                    self.showAlert("Alert!", message: "Please select category.", actions: ["Ok"]) { actionTitle in
                        
                    }
                }
                break
                
            default : break
            }
        }
        if taskId == 0 {
            createTaskApiCall(hasError: hasError, apiURL: tasksURL, params: taskParam, method: .post)
            
        }else{
            let url = tasksURL + "/\(taskId)"
            createTaskApiCall(hasError: hasError, apiURL: url, params: taskParam, method: .put)
        }
    }
    
    func createTaskApiCall(hasError: Bool,apiURL: String, params: [String:Any], method: HTTPMethod){
        if !hasError {
            self.view.isUserInteractionEnabled = false
            hud.show(in: self.view)
            var taskVM = TaskListViewModel()
            guard let token = careKernelDefaults.value(forKey: kLoginToken) as? String else {
                careKernelDefaults.set(false, forKey: kIsLoggedIn)
                return }
            taskVM.token = token
            taskVM.createTask(apiURL: apiURL, param: params, method: method) { response, success in
                if success {
                    var sucessMessage = String()
                    if method == HTTPMethod.post{
                        sucessMessage = "Task added successfully"
                    }else{
                        sucessMessage = "Task edited successfully"
                    }
                    if self.hasAttachment {
                        let taskId = JSON(response)["id"].intValue
                        var fileName = JSON(response)["displayId"].stringValue
                        fileName = fileName + ".jpg"
                        let fileData = self.attachedImage.jpegData(compressionQuality: 0.3)
                        
                        taskVM.uploadDocuments(fileName: fileName, fileData: fileData ?? Data(), entity: "tasks", entityId: taskId){ success in
                            if success {
                                self.showAlert("CareKernel", message: sucessMessage, actions: ["Ok"]) { action in
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
                        self.showAlert("CareKernel", message: sucessMessage, actions: ["Ok"]) { action in
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
    }
    
    func getIndexFromArray(selectedName: String) -> Int {
        for i in 0...tableArray.count{
            let name = JSON(tableArray)[i]["name"].stringValue
            if name == selectedName{
                return i
            }
        }
        return Int()
    }
    
    @IBAction func assignToAction(_ sender: UIButton) {
        isKeyboardDismiss = true
        view.endEditing(true)
        setTableHeader(headerTitle: "Assign to")
        self.tableArray.removeAllObjects()
        self.dropDownType = "AssignTo"
        self.fetchUsers()
        
    }
    @IBAction func dueDateAction(_ sender: UIButton) {
        isKeyboardDismiss = true
        view.endEditing(true)
        dropDownBlackView.isHidden = false
        self.dropDownTableView.isHidden = true
        self.dateView.isHidden = false
        datePicker.minimumDate = Date()
    }
    @IBAction func priorityAction(_ sender: UIButton) {
        isKeyboardDismiss = true
        view.endEditing(true)
        setTableHeader(headerTitle: "Priority")
        self.dropDownType = "Priority"
        
        self.tableArray.removeAllObjects()
        for value in priorityArray {
            let values = ["name": value, "id": "0"] as [String : Any]
            self.tableArray.add(values)
        }
        self.dropDownTableView.reloadData()
        self.dropDownBlackView.isHidden = false
        self.dropDownTableView.isHidden = false
        self.dateView.isHidden = true
        if selectedPriority != "" {
            let indexOfItem = getIndexFromArray(selectedName: selectedPriority)
            print(indexOfItem)
            self.selectedCell = IndexPath(row: indexOfItem, section: 0)
            self.isCellSelected = true
        }
    }
    @IBAction func categoryAction(_ sender: UIButton) {
        isKeyboardDismiss = true
        view.endEditing(true)
        setTableHeader(headerTitle: "Category")
        self.dropDownType = "Category"
        self.tableArray.removeAllObjects()
        self.fetchCategories()
        
        
    }
    
    @IBAction func hideBlackViewAction(_ sender: UIButton) {
        dropDownBlackView.isHidden = true
        self.dropDownTableView.isHidden = true
        self.dateView.isHidden = true
        
    }
    @IBAction func datePickerValueChanged(_ sender: UIDatePicker) {
        setDateUI(selectedDate: datePicker.date)
    }
    
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
    
    func setDateUI(selectedDate: Date){
        let date = getFormattedDate(date: selectedDate, format: "dd/MM/yyyy")
        print(date)
        let iso8601DateFormatter = ISO8601DateFormatter()
        iso8601DateFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        let dateString = iso8601DateFormatter.string(from: selectedDate)
        self.selectedDate = dateString
        self.dueDateButton.setTitle(date, for: .normal)
        
    }
    func configureUI(){
        dropDownBlackView.isHidden = true
        self.dropDownTableView.isHidden = true
        self.dateView.isHidden = true
        assignToButton.addBorderCorner(cornerRadius: 8, borderColor: UIColor(named: "Light Grey Font") ?? UIColor(), borderWidth: 1)
        dueDateButton.addBorderCorner(cornerRadius: 8, borderColor: UIColor(named: "Light Grey Font") ?? UIColor(), borderWidth: 1)
        priorityButton.addBorderCorner(cornerRadius: 8, borderColor: UIColor(named: "Light Grey Font") ?? UIColor(), borderWidth: 1)
        categoryButton.addBorderCorner(cornerRadius: 8, borderColor: UIColor(named: "Light Grey Font") ?? UIColor(), borderWidth: 1)
        
        attachmentButton.addBorderCorner(cornerRadius: 15)
        attachmentButton.titleLabel?.numberOfLines = 1;
        attachmentButton.titleLabel?.adjustsFontSizeToFitWidth = true
        createButton.addBorderCorner(cornerRadius: 4)
        
        
        
        //        if !isReportedNdis {
        //            NDISDateButton.isUserInteractionEnabled = false
        //        }
        
        categoryButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: (self.categoryButton.bounds.width - 50), bottom: 0, right: 0)
        categoryButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: (-10), bottom: 0, right: 0)
        assignToButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: (self.assignToButton.bounds.width - 50), bottom: 0, right: 0)
        assignToButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: (-10), bottom: 0, right: 0)
        priorityButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: (self.priorityButton.bounds.width - 50), bottom: 0, right: 0)
        priorityButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: (-10), bottom: 0, right: 0)
        dueDateButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: (self.dueDateButton.bounds.width - 50), bottom: 0, right: 0)
        dueDateButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: (-10), bottom: 0, right: 0)
        
        if taskId != 0 {
            
            self.fetchTaskData()
        }else{
            if !hasAttachment {
                self.deleteAttachmentButton.isHidden = true
                fileViewButton.isHidden = true
                taskTitle = ""
                taskDescription = ""
                selectedPriority = ""
                selectedDate = ""
                selectedStatus = "todo"
                selectedCategoryId = 0
                selectedAssigneeId = 0
            }
            
            self.view.isUserInteractionEnabled = true
            self.hud.dismiss()
        }
        self.deleteAttachmentButton.setTitle("", for: .normal)
        setupTextFields()
        
    }
    
    func fetchTaskData(){
        var taskDetailsVM = TaskDetailsViewModel()
        guard let token = careKernelDefaults.value(forKey: kLoginToken) as? String else {
            careKernelDefaults.set(false, forKey: kIsLoggedIn)
            
            return }
        taskDetailsVM.token = token
        taskDetailsVM.taskId = taskId
        taskDetailsVM.getTaskDetails { response, success in
            if success {
                let tempDict = JSON(response).dictionaryValue
                print(tempDict)
                //                self.detailsDict = tempDict as [String:Any]
                //                print(self.detailsDict)
                let dateValue = JSON(tempDict)["dueDate"].stringValue
                let date = self.iso860ToString(dateString: dateValue)
                self.selectedDate = self.getFormattedDate(date: date, format: "dd/MM/yyy")
                self.dueDateButton.setTitle(self.selectedDate, for: .normal)
                self.datePicker.setDate(date, animated: true)
                
                self.selectedPriority = JSON(tempDict)["priority"].stringValue
                self.priorityButton.setTitle(self.selectedPriority.capitalized, for: .normal)
                
                self.taskTitle = JSON(tempDict)["title"].stringValue
                self.titleNameTextView.text = self.taskTitle
                
                let displayID = JSON(tempDict)["displayId"].stringValue
                self.screenTitleLabel.text = "Edit: " + displayID
                
                self.selectedStatus = JSON(tempDict)["taskStatus"].stringValue
                
                self.taskDescription = JSON(tempDict)["description"].stringValue
                let htmlText = "<font color=\"#959A9D\">" + self.taskDescription + "</font>"
                if let htmlData = htmlText.data(using: String.Encoding.unicode) {
                    do {
                        let attributedText = try NSAttributedString(data: htmlData,
                                                                    options: [.documentType: NSAttributedString.DocumentType.html],
                                                                    documentAttributes: nil)
                        //Setting htmltext to uilable
                        self.descriptionTextView.attributedText = attributedText
                        
                    } catch let e as NSError {
                        //setting plane text to uilable cause of err
                        self.descriptionTextView.attributedText = self.taskDescription.htmlAttributedString()
                        print("Couldn't translate \(htmlText): \(e.localizedDescription) ")
                    }
                }
                
                self.selectedAssignee = JSON(tempDict)["assignee"]["fullName"].stringValue
                self.assignToButton.setTitle(self.selectedAssignee, for: .normal)
                self.selectedAssigneeId = JSON(tempDict)["assignee"]["id"].intValue
                
                self.selectedCategory = JSON(tempDict)["category"]["name"].stringValue
                self.categoryButton.setTitle(self.selectedCategory, for: .normal)
                self.selectedCategoryId = JSON(tempDict)["category"]["id"].intValue
                self.createButton.setTitle("Edit Task", for: .normal)
                if self.hasAttachment {
                    self.fileViewButton.isHidden = false
//                    self.deleteAttachmentButton.isHidden = false
                    
                }else{
                    let attachemets = JSON(tempDict)["taskFiles"].arrayValue
                    self.deleteAttachmentButton.isHidden = true
                    self.fileViewButton.isHidden = true
                    if attachemets.count > 0 {
                        self.attachedFilesArray.removeAllObjects()
                        for arr in attachemets {
                            self.attachedFilesArray.add(arr.dictionaryObject!)
                        }
                        self.deleteAttachmentButton.isHidden = true
                        self.fileViewButton.isHidden = false
                        let fileURL = JSON(attachemets)[0]["url"].stringValue
                        let fileName = JSON(attachemets)[0]["name"].stringValue
                        self.fileViewButton.setTitle("Files", for: .normal)
                        self.hasOldAttachment = true
                        self.oldAttachedFileName = fileName
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
                                self?.oldAttachedImage = image ?? UIImage(named: "FilesPlaceholder")!
                            }
                        )
                        
                        
                    }else{
                        self.hasOldAttachment = false
                    }
                }
                
                
                
                self.view.isUserInteractionEnabled = true
                self.hud.dismiss()
                
            }
        }
    }
    
    func taskTitleToShow(receivedTitle: String?) -> String {
        switch receivedTitle {
        case "todo":
            return "To Do"
        case "done":
            return "Done"
        case "in-progress":
            return "In Progress"
        case "blocked":
            return "Blocked"
        default :
            return "NA"
            
        }
    }
    
    func taskTitleToSend(receivedTitle: String?) -> String {
        switch receivedTitle {
        case "To Do":
            return "todo"
        case "Done":
            return "done"
        case "In Progress":
            return "in-progress"
        case "Blocked":
            return "blocked"
        default :
            return "NA"
            
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
    
    func fetchUsers(){
        var taskDetailsVM = TaskDetailsViewModel()
        guard let token = careKernelDefaults.value(forKey: kLoginToken) as? String else {
            careKernelDefaults.set(false, forKey: kIsLoggedIn)
            return }
        taskDetailsVM.token = token
        taskDetailsVM.getUser { response, success in
            if success {
                self.tableArray.removeAllObjects()
                let tempArray = JSON(response)["data"].arrayValue
                for value in tempArray {
                    let names = JSON(value)["fullName"].stringValue
                    let namesId = JSON(value)["id"].intValue
                    let values = ["name": names, "id": namesId] as [String : Any]
                    self.tableArray.add(values)
                }
                let names = "Select"
                let namesId = 0
                let values = ["name": names, "id": namesId] as [String : Any]
                self.tableArray.insert(values, at: 0)
                print(self.tableArray)
                self.dropDownTableView.reloadData()
                self.dropDownBlackView.isHidden = false
                self.dropDownTableView.isHidden = false
                self.dateView.isHidden = true
                if self.selectedAssignee != "" {
                    let indexOfItem = self.getIndexFromArray(selectedName: self.selectedAssignee)
                    print(indexOfItem)
                    self.selectedCell = IndexPath(row: indexOfItem, section: 0)
                    self.isCellSelected = true
                }else{
                    self.isCellSelected = false
                }
            }else{
                
            }
        }
    }
    
    func fetchCategories(){
        var filtersVM = FiltersViewModel()
        guard let token = careKernelDefaults.value(forKey: kLoginToken) as? String else {
            careKernelDefaults.set(false, forKey: kIsLoggedIn)
            return }
        filtersVM.token = token
        filtersVM.getCategories { response, success in
            if success {
                let tempArray = JSON(response)["data"].arrayValue
                if tempArray.count != 0 {
                    let categorieData = NSMutableArray()
                    for value in tempArray {
                        categorieData.add(value)
                        var keyValue : [String:String] = [:]
                        let catName = JSON(value)["name"].stringValue
                        let catID = JSON(value)["id"].intValue
                        keyValue = ["id":"\(catID)", "name": catName]
                        self.tableArray.add(keyValue)
                    }
                    let names = "Select"
                    let namesId = 0
                    let values = ["name": names, "id": namesId] as [String : Any]
                    self.tableArray.insert(values, at: 0)
                    print(self.tableArray)
                    self.dropDownTableView.reloadData()
                    self.dropDownBlackView.isHidden = false
                    self.dropDownTableView.isHidden = false
                    self.dateView.isHidden = true
                    if self.selectedCategory != "" {
                        let indexOfItem = self.getIndexFromArray(selectedName: self.selectedCategory)
                        print(indexOfItem)
                        self.selectedCell = IndexPath(row: indexOfItem, section: 0)
                        self.isCellSelected = true
                    }else{
                        self.isCellSelected = false
                    }
                }
                
            }
        }
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        isKeyboardDismiss = true
        isCellSelected = false
        self.resignFirstResponder()
        view.endEditing(true)
        
    }
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? FilesImageViewController {
            vc.fileImage = sender as! UIImage
        }else if let vc = segue.destination as? FilesListViewController {
            vc.filesArray = attachedFilesArray
            vc.titleName = "Task Files"
        }
    }
    
    func setupTextFields() {
            let toolbar = UIToolbar()
            let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace,
                                            target: nil, action: nil)
            let doneButton = UIBarButtonItem(title: "Done", style: .done,
                                             target: self, action: #selector(doneButtonTapped))
            
            toolbar.setItems([flexSpace, doneButton], animated: true)
            toolbar.sizeToFit()
            
            titleNameTextView.inputAccessoryView = toolbar
            descriptionTextView.inputAccessoryView = toolbar
        }
        
        @objc func doneButtonTapped() {
            view.endEditing(true)
        }
}

extension AddTaskViewController : UITableViewDelegate, UITableViewDataSource {
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DropDownCell", for: indexPath) as! DropDownCell
        
        let nameValue = JSON(tableArray)[indexPath.row]["name"].stringValue
        cell.nameLabel.text = nameValue.capitalized
        cell.tickImage.image = nil
        
        
        
        switch dropDownType {
        case "AssignTo":
            if taskId != 0 {
                isCellSelected = false
                if nameValue == selectedAssignee {
                    isCellSelected = true
                    self.selectedCell = indexPath
                }
            }else{
                
            }
            
            break
        case "Priority":
            if taskId != 0 {
                isCellSelected = false
                if nameValue == selectedPriority {
                    isCellSelected = true
                    self.selectedCell = indexPath
                }
            }else{
                
            }
            
            break
            
        case "Category":
            if taskId != 0 {
                isCellSelected = false
                if nameValue == selectedCategory {
                    isCellSelected = true
                    self.selectedCell = indexPath
                }
            }else{
                
            }
            
            break
        default:
            break
        }
        
        if isCellSelected && selectedCell == indexPath{
            cell.tickImage.image = #imageLiteral(resourceName: "tick")
            cell.nameLabel.textColor = UIColor(named: "Calender Font color")
        }else{
            cell.tickImage.image = nil
            cell.nameLabel.textColor = UIColor(named: "Light Grey Font")
        }
        //        isCellSelected = false
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
        selectedValue = JSON(tableArray)[indexPath.row]["name"].stringValue
        switch dropDownType {
            
        case "AssignTo":
            
            if selectedValue != self.assignToButton.title(for: .normal){
                isValueChanged = true
                selectedAssigneeId = JSON(tableArray)[indexPath.row]["id"].intValue
                selectedAssignee = JSON(tableArray)[indexPath.row]["name"].stringValue
                self.assignToButton.setTitle(selectedAssignee.capitalized, for: .normal)
                
            }
            break
        case "Priority":
            if selectedValue != self.priorityButton.title(for: .normal){
                isValueChanged = true
                selectedPriority = JSON(tableArray)[indexPath.row]["name"].stringValue
                self.priorityButton.setTitle(selectedPriority, for: .normal)
            }
            break
            
        case "Category":
            if selectedValue != self.categoryButton.title(for: .normal){
                isValueChanged = true
                selectedCategoryId = JSON(tableArray)[indexPath.row]["id"].intValue
                selectedCategory = JSON(tableArray)[indexPath.row]["name"].stringValue
                self.categoryButton.setTitle(selectedCategory, for: .normal)
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
extension AddTaskViewController: UITextViewDelegate{
    
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
            if textView == titleNameTextView{
                descriptionTextView.becomeFirstResponder()
            }else if textView == descriptionTextView{
//                self.resignFirstResponder()
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
        if textView == titleNameTextView{
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
        if textView == titleNameTextView{
            taskTitle = textView.text
        }else if textView == descriptionTextView{
            taskDescription = textView.text
        }
        
    }
    
}
