//
//  TaskDetailsViewController.swift
//  CareKernel
//
//  Created by Mohit Sharma on 10/11/21.
//

import UIKit
import SwiftyJSON
import JGProgressHUD


class TaskDetailsViewController: UIViewController {

    
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var descriptionTextView: UITextView!
    @IBOutlet var taskIdLabel: UILabel!
    @IBOutlet var dueDateLabel: UILabel!
    @IBOutlet var priorityLabel: LabelWithProperty!
    @IBOutlet var inquiryLabel: UILabel!
    @IBOutlet var callLabel: UILabel!
    @IBOutlet var assionToButton: UIButton!
    @IBOutlet var taskStatusButton: UIButton!
//    @IBOutlet var priorityImageView: UIImageView!
    @IBOutlet var dropDownBlackView: UIView!
    @IBOutlet var dropDownTableView: UITableView!
    @IBOutlet var commentTextView: UITextView!
    @IBOutlet var CommentUserLabel: UILabel!
    @IBOutlet var commentDateLabel: UILabel!
    @IBOutlet var lastCommentLabel: UILabel!
    @IBOutlet var categoryLabel: UILabel!
    @IBOutlet var editTaskButton: UIButton!
    @IBOutlet var viewOneHeight: UIView!
    @IBOutlet weak var filesButton: UIButton!
    
    @IBOutlet weak var commentButton: UIButton!
    
    let hud = JGProgressHUD()
    var taskID = 0
    var detailsDict = [String:Any]()
    var statusArray = ["To Do","In Progress","Blocked","Done"]
    var nameArray = [""]
    var namesId = [0]
    var tableArray = [""]
    var isCellSelected = Bool()
    var selectedCell = IndexPath()
    var headerTitle = String()
    var selectedValue = String()
    var taskDetailsVM = TaskDetailsViewModel()
    var dropDownType = String()
    var isValueChanged = Bool()
    var selectedId = 0
    var selectedStatus = String()
    var selectedName = String()
    var taskComment = String()
    var commentsArray = NSMutableArray()
    var creatorId = 0
    var notificationId = 0
    var filesURL = String()
    var attachedFilesArray = NSMutableArray()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if notificationId != 0 {
            deleteNotification(notificationId: notificationId)
        }
        self.filesButton.isHidden = true
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.view.isUserInteractionEnabled = false
        hud.show(in: self.view)
        assionToButton.addBorderCorner(cornerRadius: 8, borderColor: UIColor(named: "Light Grey Font") ?? UIColor(), borderWidth: 1)
        taskStatusButton.addBorderCorner(cornerRadius: 8, borderColor: UIColor(named: "Light Grey Font") ?? UIColor(), borderWidth: 1)
        assionToButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: (self.assionToButton.bounds.width - 60), bottom: 0, right: 0)
        assionToButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: (-10), bottom: 0, right: 0)
        taskStatusButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: (self.taskStatusButton.bounds.width - 60), bottom: 0, right: 0)
        taskStatusButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: (-10), bottom: 0, right: 0)
        fetchData()
        tableArray = statusArray
        dropDownBlackView.isHidden = true
        descriptionTextView.delegate = self
        // Set a header for the table view
        setTableHeader()
        
    }
    
    
    func setUI(){
        guard  let userId = careKernelDefaults.value(forKey: kUserId) as? Int else { return()}
        if userId == creatorId {
            editTaskButton.isHidden = false
            editTaskButton.layer.borderWidth = 1
            editTaskButton.layer.borderColor = UIColor(named: "Basic Blue")?.cgColor
        }else{
            editTaskButton.isHidden = true
        }
        
        setupTextFields()
        
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
    
    func deleteNotification(notificationId: Int){
        var notificationVM = NotificationViewModel()
        guard let token = careKernelDefaults.value(forKey: kLoginToken) as? String else {
            careKernelDefaults.set(false, forKey: kIsLoggedIn)
            return }
        notificationVM.token = token
        notificationVM.updateNotificationStatus(isRead: true, notificationId: notificationId) { response, success in
            if success {
                
            }
        }
    }
    
    func presentStoryboard(segue: String, sender: Any?){
//        hud.dismiss()
//        self.view.isUserInteractionEnabled = true
        DispatchQueue.main.async {
            self.performSegue(withIdentifier: segue, sender: sender)
        }
        
    }

    @IBAction func filesButtonAction(_ sender: UIButton) {
//        let imageurl = JSON(filesArray)[indexPath.row ]["url"].stringValue
        print(filesURL)
        self.performSegue(withIdentifier: "segueToFiles", sender: filesURL)
    }
    
    @IBAction func backButtonActiom(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func dropDownviewCloseButton(_ sender: UIButton) {
        self.dropDownBlackView.isHidden = true
    }
    @IBAction func assionToButtonAction(_ sender: UIButton) {
       
        let indexOfItem = self.nameArray.firstIndex(where: {$0 == selectedName})

        self.selectedCell = IndexPath(row: indexOfItem ?? 0, section: 0)
        self.isCellSelected = true
        headerTitle = "Assign to"
        setTableHeader()
        tableArray = nameArray
        dropDownType = "names"
        dropDownTableView.reloadData()
        dropDownBlackView.isHidden = false
    }
    
    
    @IBAction func assignUpdateButtonAction(_ sender: UIButton) {
        if isValueChanged {
            let params = ["assigneeId":selectedId]
            taskDetailsVM.updateDetails(params: params) { response, success in
                if success {
                    self.showAlert("CareKernel", message: "Assignee Updated.", actions: ["ok"]) { action in
                    }
                }else{
                    
                }
            }
        }
    }
    
    @IBAction func taskStatusButtonAction(_ sender: UIButton) {
                
        let indexOfItem = self.statusArray.firstIndex(where: {$0 == selectedStatus})
        self.selectedCell = IndexPath(row: indexOfItem ?? 0, section: 0)
        self.isCellSelected = true
        headerTitle = "Task Status"
        setTableHeader()
        tableArray = statusArray
        dropDownType = "status"
        dropDownTableView.reloadData()
        dropDownBlackView.isHidden = false

    }
    
    @IBAction func statusUpdateButton(_ sender: UIButton) {
        if isValueChanged {
            let statusTitle = self.taskStatusButton.title(for: .normal)
            let formatedStatusTitle = self.taskTitleToSend(receivedTitle: statusTitle)
            let assignTitle = self.assionToButton.title(for: .normal)
            let indexOfItem = self.nameArray.firstIndex(where: {$0 == assignTitle})!
            print(indexOfItem)
            selectedId = JSON(namesId)[indexOfItem].intValue
            print(selectedId)
            let params = ["taskStatus":formatedStatusTitle,"assigneeId": selectedId ] as [String : Any]
            taskDetailsVM.updateDetails(params: params) { response, success in
                if success {
                    self.showAlert("CareKernel", message: "Task Status Updated.", actions: ["ok"]) { action in
                        
                    }
                }else{
                    self.showAlert("CareKernel", message:response.description, actions: ["ok"]) { action in
                        
                    }
                }
            }
        }
    }
    
    @IBAction func viewAllCommentsAction(_ sender: UIButton) {
        presentStoryboard(segue: "segueToAllComments", sender: nil)
    }
    
    @IBAction func addCommentAction(_ sender: UIButton) {
        view.endEditing(true)
        if taskComment != ""{
        let params: [String:Any] = ["description": taskComment]
        
        taskDetailsVM.createTaskComment(taskId: taskID, param: params) { response, success in
            if success {
                self.taskComment = ""
                self.commentTextView.text = "Add Text Here"
                self.fetchComments()
                self.showAlert("CareKernel", message: "Comment added successfully.", actions: ["Ok"]) { (actionTitle) in
                    print(actionTitle)
                }
            }
        }
        }else{
            self.showAlert("CareKernel", message: "Please add comment first.", actions: ["Ok"]) { (actionTitle) in
                print(actionTitle)
            }
        }
    }
    @IBAction func editTaskAction(_ sender: UIButton) {
        presentStoryboard(segue: "segueToAddTask", sender: taskID)
    }
    
    @IBAction func commentViewAction(_ sender: UIButton) {
        
        
        let details = self.lastCommentLabel.text ?? ""
        showAlertAlligned("Details", message: details, actions: ["Ok"]) { action in
            
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
    
    
    func fetchData(){
        guard let token = careKernelDefaults.value(forKey: kLoginToken) as? String else {
            careKernelDefaults.set(false, forKey: kIsLoggedIn)
            
            return }
        taskDetailsVM.token = token
        taskDetailsVM.taskId = taskID
        taskDetailsVM.getTaskDetails { response, success in
            if success {
                let tempDict = JSON(response).dictionaryValue
                self.detailsDict = tempDict as [String:Any]
                
                let date = JSON(tempDict)["dueDate"].stringValue
                let dueDatString = self.getFormattedDate(date: self.iso860ToString(dateString: date), format: "dd/MM/yyy")
                self.dueDateLabel.text = dueDatString
                let priority = JSON(tempDict)["priority"].stringValue
                self.priorityLabel.text = priority.capitalized
                self.titleLabel.text = JSON(tempDict)["title"].stringValue.capitalized
                self.taskIdLabel.text = JSON(tempDict)["displayId"].stringValue
                let taskStatus = JSON(tempDict)["taskStatus"].stringValue
                let desc = JSON(tempDict)["description"].stringValue
                let assignee = JSON(tempDict)["assignee"]["fullName"].stringValue
                self.selectedName = assignee
                self.assionToButton.setTitle(assignee, for: .normal)
                
                let htmlText = "<font color=\"#959A9D\">" + desc + "</font>"
                if let htmlData = htmlText.data(using: String.Encoding.unicode) {
                    do {
                         let attributedText = try NSAttributedString(data: htmlData,
                                                                     options: [.documentType: NSAttributedString.DocumentType.html],
                                                                     documentAttributes: nil)
                         //Setting htmltext to uilable
                        self.descriptionTextView.attributedText = attributedText

                       } catch let e as NSError {
                         //setting plane text to uilable cause of err
                           self.descriptionTextView.attributedText = desc.htmlAttributedString()
                         print("Couldn't translate \(htmlText): \(e.localizedDescription) ")
                       }
                }
//                self.descriptionTextView.attributedText = attributedString
                let formatedStatus = self.taskTitleToShow(receivedTitle: taskStatus)
                self.selectedStatus = formatedStatus
                self.taskStatusButton.setTitle(formatedStatus, for: .normal)
                let entity = JSON(tempDict)["entity"].stringValue.capitalized
                let entityID = JSON(tempDict)["entityId"].intValue
                let subEntity = JSON(tempDict)["subEntity"].stringValue.capitalized
                let subEntityId = JSON(tempDict)["subEntityId"].intValue
                let category = JSON(tempDict)["category"]["name"].stringValue
                self.creatorId = JSON(tempDict)["creator"]["id"].intValue
                
                self.categoryLabel.text = category
                if entity == "" {
                    self.inquiryLabel.text = "NA"
                    self.inquiryLabel.textColor = UIColor(named: "Light Grey Font")
                }else{
                    self.inquiryLabel.text = "\(entity)" + " - " + "\(entityID)"
                }
                if entity == "" && subEntity == "" {
                    self.callLabel.text = ""
                }else if subEntity == ""{
                    self.callLabel.text = "NA"
                }else{
                    self.callLabel.text = "\(subEntity)" + " - " + "\(subEntityId)"
                }
//                if entityID == 0 {
//                    self.inquiryLabel.text = "\(entity)" + " - " + "N/A"
//                }else{
//                    self.inquiryLabel.text = "\(entity)" + " - " + "\(entityID)"
//                }
//                if subEntityId == 0 {
//                    self.callLabel.text = "\(subEntity)" + " - " + "N/A"
//                }else{
//                    self.callLabel.text = "\(subEntity)" + " - " + "\(subEntityId)"
//                }
                if entity == "Client" && entityID != 0{
                    self.inquiryLabel.isUserInteractionEnabled = true
                    let guestureRecognizer = CustomTapGestureRecognizer(target: self, action: #selector(self.labelClicked(sender:)))
                    guestureRecognizer.ourCustomValue = entityID
                    self.inquiryLabel.addGestureRecognizer(guestureRecognizer)
                }

                switch priority {
                case "low":

                    let greenColor = self.hexStringToUIColor(hex: "#3CBE91")
                    self.priorityLabel.showBadge(color: greenColor)
                    break
                case "medium":

                    let yellowColor = self.hexStringToUIColor(hex: "#FFBA38")
                    self.priorityLabel.showBadge(color: yellowColor)
                    break
                case "high":

                    let redColor = self.hexStringToUIColor(hex: "#FF5063")
                    self.priorityLabel.showBadge(color: redColor)
                    break
                default:
                    let greenColor = self.hexStringToUIColor(hex: "#3CBE91")
                    self.priorityLabel.showBadge(color: greenColor)
                }
                
                 let attachemets = JSON(tempDict)["taskFiles"].arrayValue
                
                if attachemets.count > 0 {
                    self.attachedFilesArray.removeAllObjects()
                    for arr in attachemets {
                        self.attachedFilesArray.add(arr.dictionaryObject!)
                    }
                    self.filesURL = JSON(attachemets)[0]["url"].stringValue
                    self.filesButton.isHidden = false
                }
                self.setUI()
                self.fetchUsers()
                self.fetchComments()
                
            }
            self.view.isUserInteractionEnabled = true
            self.hud.dismiss()
            
        }
    }
    
    @objc func labelClicked(sender: CustomTapGestureRecognizer) {
        let clientId = sender.ourCustomValue
        print(clientId!)
        careKernelDefaults.set(clientId!, forKey: "clientID")
        self.performSegue(withIdentifier: "segueToClientDetails", sender: clientId!)
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
    
    func fetchUsers(){
        taskDetailsVM.getUser { response, success in
            if success {
                self.nameArray.removeAll()
                self.namesId.removeAll()
                let tempArray = JSON(response)["data"].arrayValue
                for value in tempArray {
                    let names = JSON(value)["fullName"].stringValue
                    let namesId = JSON(value)["id"].intValue
                    self.nameArray.append(names)
                    self.namesId.append(namesId)
                }
                print(self.nameArray)
            }else{
                
            }
        }
    }
    
    func fetchComments(){
        self.commentsArray.removeAllObjects()
        var taskDetailsVM = TaskDetailsViewModel()
        guard let token = careKernelDefaults.value(forKey: kLoginToken) as? String else {
            careKernelDefaults.set(false, forKey: kIsLoggedIn)
            
            return }
        taskDetailsVM.token = token
        taskDetailsVM.taskId = taskID
        taskDetailsVM.getTaskComments { response, success in
            if success {
                DispatchQueue.main.async {
                    let tempArray = JSON(response)["data"].arrayValue
                    if tempArray.count != 0 {
                        
                        for value in tempArray {
                            self.commentsArray.add(value)
                        }
                        self.CommentUserLabel.text = JSON(self.commentsArray)[0]["creator"]["fullName"].stringValue
                        let createDate = JSON(self.commentsArray)[0]["createdAt"].stringValue
                        self.commentDateLabel.text = self.getFormattedDate(date: self.iso860ToString(dateString: createDate), format: "dd/MM/yyyy hh:mm a")
                        self.lastCommentLabel.text = JSON(self.commentsArray)[0]["description"].stringValue
                        self.CommentUserLabel.isHidden = false
                        self.commentDateLabel.isHidden = false
                        self.commentButton.isUserInteractionEnabled = true
                        self.lastCommentLabel.textAlignment = .justified
                    }else{
                        self.CommentUserLabel.isHidden = true
                        self.commentDateLabel.isHidden = true
                        self.commentButton.isUserInteractionEnabled = false
                        self.lastCommentLabel.text = "No records for comments!"
                        self.lastCommentLabel.textAlignment = .center
                    }
                }
            }
        }
    }
    
    func calculateHeight(inString:String) -> CGFloat{
               let messageString = inString
               let attributes : [NSAttributedString.Key : Any] = [NSAttributedString.Key(rawValue:
       NSAttributedString.Key.font.rawValue) : UIFont.systemFont(ofSize:
       15.0)]

               let attributedString : NSAttributedString = NSAttributedString(string: messageString, attributes: attributes)
               let rect : CGRect = attributedString.boundingRect(with: CGSize(width: 222.0, height: CGFloat.greatestFiniteMagnitude),
       options: .usesLineFragmentOrigin, context: nil)

               let requredSize:CGRect = rect
               return requredSize.height
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? ViewCommentsViewController {
            vc.taskId = taskID
        }else if let vc = segue.destination as? AddTaskViewController {
            vc.taskId = taskID
        }else if let vc = segue.destination as? ClientMainViewController {
            vc.clientId = sender as! Int
        }else if let vc = segue.destination as? FilesListViewController {
            vc.filesArray = attachedFilesArray
            vc.titleName = "Task Files"
        }
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.resignFirstResponder()
        view.endEditing(true)
        
    }
    
    func setupTextFields() {
            let toolbar = UIToolbar()
            let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace,
                                            target: nil, action: nil)
            let doneButton = UIBarButtonItem(title: "Done", style: .done,
                                             target: self, action: #selector(doneButtonTapped))
            
            toolbar.setItems([flexSpace, doneButton], animated: true)
            toolbar.sizeToFit()
            
            commentTextView.inputAccessoryView = toolbar
        }
        
        @objc func doneButtonTapped() {
            view.endEditing(true)
        }
}

extension TaskDetailsViewController : UITableViewDelegate, UITableViewDataSource {
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        tableArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DropDownCell", for: indexPath) as! DropDownCell
        
        cell.nameLabel.text = JSON(tableArray)[indexPath.row].stringValue.capitalized
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedCell = indexPath
        selectedValue = JSON(tableArray)[indexPath.row].stringValue
        switch dropDownType {
        case "names":
            if selectedValue != self.assionToButton.title(for: .normal){
                self.assionToButton.setTitle(selectedValue.capitalized, for: .normal)
                isValueChanged = true
                selectedId = JSON(namesId)[indexPath.row].intValue
                selectedName = selectedValue
            }
            break
        case "status":
           
            if selectedValue != self.taskStatusButton.title(for: .normal){
                self.taskStatusButton.setTitle(selectedValue, for: .normal)
                isValueChanged = true
                selectedStatus = selectedValue
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

extension TaskDetailsViewController: UITextViewDelegate{
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == "Add Text Here"{
            textView.text = ""
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text == ""{
            textView.text = "Add Text Here"
        }
        
    }
    
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        return true
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool{
//        if text == "\n" {
//            textView.resignFirstResponder()
//            return false
//        }
        return true
    }
    
    func textViewDidChange(_ textView: UITextView) {
        taskComment = textView.text
    }
}
class CustomTapGestureRecognizer: UITapGestureRecognizer {
    var ourCustomValue: Int?
}
