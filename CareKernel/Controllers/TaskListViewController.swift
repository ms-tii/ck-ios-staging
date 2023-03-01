//
//  TaskListViewController.swift
//  CareKernel
//
//  Created by Mohit Sharma on 30/08/21.
//

import UIKit
import SwiftyJSON
import JGProgressHUD

class TaskListViewController: UIViewController {
    
    @IBOutlet var tasksTableView: UITableView!
    @IBOutlet var noTaskLabel: UILabel!
    @IBOutlet var taskAssignToLabel: UILabel!
    @IBOutlet var filtersCollectionView: UICollectionView!
    @IBOutlet var clearAllButton: UIButton!
    @IBOutlet var tableViewTopConstraint: NSLayoutConstraint!
    @IBOutlet var filtersCollectionViewHeight: NSLayoutConstraint!
    @IBOutlet var notificationButton: ButtonWithProperty!
    @IBOutlet weak var topBarContainer: UIView!
    
    let hud = JGProgressHUD()
    var offset = "0"
    var totalPage = 1
    var currentPage = 1
    var tasksArray = NSMutableArray()
    var filtersDict : [String:Any] = [:]
    var sessionUserId = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.view.isUserInteractionEnabled = false        
        hud.show(in: self.view)
        tasksTableView.isHidden = true
        noTaskLabel.isHidden = false
        taskAssignToLabel.isHidden = true
        guard  let userId = careKernelDefaults.value(forKey: kUserId) as? Int else { return()}
        sessionUserId = userId
        self.tasksArray.removeAllObjects()
        checkFilters()
        notificationButton.isBadgeShow = true
        guard  let isNotificationAvailable = careKernelDefaults.value(forKey: "isNotificationAvailable") as? Bool else { return()}
        if isNotificationAvailable {
            notificationButton.isRead = false
        }else{
            notificationButton.isRead = true
        }
        refreshTableView()
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        offset = "0"
        totalPage = 1
        currentPage = 1
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let height = filtersCollectionView.collectionViewLayout.collectionViewContentSize.height
        filtersCollectionViewHeight.constant = height
        self.view.layoutIfNeeded()
    }
    
    func checkFilters(refresh: Bool = false){
        if let filters = careKernelDefaults.value(forKey: "tasksFiltersValue") as? NSDictionary{
            clearAllButton.isHidden = false
            clearAllButton.setTitle("Clear All", for: .normal)
            let values = JSON(filters).dictionaryValue
            filtersDict = values as [String:Any]
            var statusArr = [String]()
            filtersDict.removeValue(forKey: "Status")
            let todoStatus = JSON(filters)["TodoStatus"].stringValue
            _ = todoStatus == "" ? filtersDict.removeValue(forKey: "TodoStatus") : statusArr.append(todoStatus)
            let inprogressStatus = JSON(filters)["InprogressStatus"].stringValue
            _ = inprogressStatus == "" ? filtersDict.removeValue(forKey: "InprogressStatus") : statusArr.append(inprogressStatus)
            let doneStatus = JSON(filters)["DoneStatus"].stringValue
            _ = doneStatus == "" ? filtersDict.removeValue(forKey: "DoneStatus") : statusArr.append(doneStatus)
            let blockedStatus = JSON(filters)["BlockedStatus"].stringValue
            _ = blockedStatus == "" ? filtersDict.removeValue(forKey: "BlockedStatus") : statusArr.append(blockedStatus)
            let priority = JSON(filters)["Priority"].stringValue
            _ = priority == "" ? filtersDict.removeValue(forKey: "Priority") : ""
            let isArchived = JSON(filters)["Is Archived"].stringValue
            _ = isArchived == "" ? filtersDict.removeValue(forKey: "Is Archived") : ""
            let category = JSON(filters)["Category"].stringValue
            _ = category == "" ? filtersDict.removeValue(forKey: "Category") : ""
            let fromDate = JSON(filters)["From"].stringValue
            _ = fromDate == "" ? filtersDict.removeValue(forKey: "From") : ""
            let toDate = JSON(filters)["To"].stringValue
            _ = toDate == "" ? filtersDict.removeValue(forKey: "To") : ""
            var convertedFromDateStr = ""
            var convertedToDateStr = ""
            if !refresh {
                filtersCollectionView.isHidden = false
                filtersCollectionView.reloadData()
            }
            
            self.viewDidLayoutSubviews()
            if fromDate != ""{
            let dateFormatter = DateFormatter()
                    dateFormatter.dateStyle = DateFormatter.Style.long
                    dateFormatter.dateFormat = "dd/MM/yyyy"
            let convertedFromDate = dateFormatter.date(from: fromDate) ?? Date()
            let convertedToDate = dateFormatter.date(from: toDate) ?? Date()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            convertedFromDateStr = dateFormatter.string(from: convertedFromDate)
            convertedToDateStr = dateFormatter.string(from: convertedToDate)
            }
            var avatarURLComponents = URLComponents(string: tasksURL)
            
            avatarURLComponents?.queryItems = statusArr.map({ (arrValue) -> URLQueryItem in
                URLQueryItem(name: "taskStatus[]", value: arrValue)
            })
            let queryEncodedString = avatarURLComponents?.url?.absoluteString
            let queryDecodestring = queryEncodedString?.removingPercentEncoding
            var finalUrlString = queryDecodestring ?? ""
            
            let parameters = "&priority=\(String(describing: priority))&isArchived=\(String(describing: isArchived))&categoryId=\(String(describing: category))&startDate=\(String(describing: convertedFromDateStr))&endDate=\(String(describing: convertedToDateStr))"
            finalUrlString = finalUrlString + "&assigneeId=" + "\(String(describing: self.sessionUserId))\(parameters)"

            print(finalUrlString)
            self.tasksArray.removeAllObjects()
            fetchData(url: finalUrlString, page: 1)
        } else {
            clearAllButton.isHidden = true

            tableViewTopConstraint.constant = taskAssignToLabel.frame.height
            filtersCollectionView.isHidden = true
            self.view.layoutIfNeeded()
//            let url = tasksURL + "?assigneeId=" + "\(String(describing: self.sessionUserId))"
            var avatarURLComponents = URLComponents(string: tasksURL)
            let statusArr = ["todo","in-progress"]
            avatarURLComponents?.queryItems = statusArr.map({ (value) -> URLQueryItem in
                URLQueryItem(name: "taskStatus[]", value: String(value))
            })
            let queryEncodedString = avatarURLComponents?.url?.absoluteString
            let queryDecodestring = queryEncodedString?.removingPercentEncoding
            var finalUrlString = queryDecodestring ?? ""
            finalUrlString = finalUrlString + "&assigneeId=" + "\(String(describing: self.sessionUserId))"
            print(finalUrlString)
            self.tasksArray.removeAllObjects()
            fetchData(url: finalUrlString, page: 1)
        }
        
        
        
    }
    @IBAction func clearAllAction(_ sender: UIButton) {
        
        careKernelDefaults.set(nil, forKey: "tasksFiltersValue")
//        tasksTableView.translatesAutoresizingMaskIntoConstraints = false
        tableViewTopConstraint.constant = taskAssignToLabel.frame.height
        filtersCollectionView.isHidden = true
        clearAllButton.isHidden = true
        self.view.layoutIfNeeded()
        checkFilters()
    }
    
    @IBAction func adTaskButtonAction(_ sender: UIButton) {
        presentStoryboard(segue: "segueToAddTask", sender: nil)
    }
    
    
    @IBAction func notificationButtonAction(_ sender: UIButton) {
        presentStoryboard(segue: "segueToNotification", sender: nil)
        
    }
    
    @IBAction func filterButtonAction(_ sender: UIButton) {
        presentStoryboard(segue: "segueToFilters", sender: nil)
    }
    
    
    
    
    func presentStoryboard(segue: String, sender: Any?){
        //        hud.dismiss()
        //        self.view.isUserInteractionEnabled = true
        DispatchQueue.main.async {
            self.performSegue(withIdentifier: segue, sender: sender)
        }
        
    }
    
    func refreshTableView(){
        self.tasksTableView.refreshControl = UIRefreshControl()
        self.tasksTableView.refreshControl?.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        
    }
    
    @objc private func refreshData(){
        print("Refreshed")
        self.checkFilters(refresh: true)
    }
    
    func fetchData(url: String, page: Int, refresh: Bool = false){
        guard let token = careKernelDefaults.value(forKey: kLoginToken) as? String else {
            careKernelDefaults.set(false, forKey: kIsLoggedIn)
            
            return }
        var taskVM = TaskListViewModel()
        taskVM.token = token
        taskVM.sessionUserId = sessionUserId
        
        let limitPerPage = 10
        self.offset = "\((page - 1) * limitPerPage)"
        taskVM.getAllTaskList(url: url, offset: self.offset, limit: "\(limitPerPage)") { response, success in
            if success {
                let tempArray = JSON(response)["data"].arrayValue
                if tempArray.count != 0 {
                    for value in tempArray {
                        self.tasksArray.add(value)
                    }
                    let metaResponse = JSON(response)["meta"].dictionaryValue
                    self.totalPage = metaResponse["pages"]!.intValue
                    self.tasksTableView.reloadData()
                    self.tasksTableView.isHidden = false
                    self.noTaskLabel.isHidden = true
                    self.taskAssignToLabel.isHidden = false
                }
                
                let metaResponse = JSON(response)["meta"].dictionaryValue
                self.totalPage = metaResponse["pages"]!.intValue
            }else{
                
                let statusCode = JSON(response)["statusCode"].intValue
                let message = JSON(response)["message"].stringValue
                if statusCode == 401 && message == "Unauthorized" {
                    careKernelDefaults.set(false, forKey: kIsLoggedIn)
                    careKernelDefaults.set("", forKey: kUserEmailId)
                    careKernelDefaults.set("", forKey: kLoginToken)
                    self.presentStoryboard(segue: "segueToLogin", sender: nil)
                }
                
//                self.hud.dismiss()
                self.tasksTableView.isHidden = true
                self.noTaskLabel.isHidden = false
            }
            self.tasksTableView.refreshControl?.endRefreshing()
            self.view.isUserInteractionEnabled = true
            self.hud.dismiss()
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
    
    @objc func labelClicked(sender: CustomTapGestureRecognizer) {
        let clientId = sender.ourCustomValue
        print(clientId!)
        careKernelDefaults.set(clientId!, forKey: "clientID")
        self.performSegue(withIdentifier: "segueToClientDetails", sender: clientId!)
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? TaskDetailsViewController {
            vc.taskID = sender as? Int ?? 1
        }else if let vc = segue.destination as? ClientMainViewController {
            vc.clientId = sender as! Int
        }
    }

    
}
extension Date {
    func withAddedMinutes(minutes: Double) -> Date {
         addingTimeInterval(minutes * 60)
    }

    func withAddedHours(hours: Double) -> Date {
         withAddedMinutes(minutes: hours * 60)
    }
}
extension TaskListViewController : UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        filtersDict.count
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FiltersCell", for: indexPath) as! FiltersCell
        var keyName = Array(filtersDict)[indexPath.row].key
        var keyValue = ""
        if keyName == "Category"{
            let categoriesArray = careKernelDefaults.value(forKey: "categoriesToShow") as? NSArray
            
            let catId = JSON(filtersDict)[keyName].stringValue
            for i in categoriesArray ?? [] {
                let catDict = i as! Dictionary<String,Any>
                if catDict["id"] as! String == catId{
                    keyValue = catDict["name"] as! String
                }
            }
        }else if keyName == "Is Archived"{
            keyValue = JSON(filtersDict)[keyName].stringValue
            if keyValue == "true"{
                keyValue = "Yes"
            }else{
                keyValue = "No"
            }
        }else if keyName == "TodoStatus"{
            keyValue = "To Do"
            keyName = "Status"
        }else if keyName == "InprogressStatus"{
            keyValue = "In Progress"
            keyName = "Status"
        }else if keyName == "DoneStatus"{
            keyValue = JSON(filtersDict)[keyName].stringValue.capitalized
            keyName = "Status"
        }else if keyName == "BlockedStatus"{
            keyValue = JSON(filtersDict)[keyName].stringValue.capitalized
            keyName = "Status"
        }else{
            keyValue = JSON(filtersDict)[keyName].stringValue.capitalized
        }
//        else if keyName == "Status"{
////            keyValue = JSON(filtersDict)[keyName].stringValue.capitalized
//            let statusArr = JSON(filtersDict)[keyName].arrayValue
//            for statusName in statusArr{
//                if statusName.stringValue.capitalized == "Todo"{
//                    keyValue = keyValue + "To Do,"
//                }else if statusName.stringValue.capitalized == "In-Progress"{
//                    keyValue = keyValue + "In Progress,"
//                }else {
//                    keyValue = keyValue + statusName.stringValue.capitalized + ","
//                }
//            }
//
//        }
        
        
        cell.filterName.text = "\(keyName):"
        cell.filterValue.text = "\(keyValue) x"

        cell.filterValue.layer.cornerRadius = 12
        cell.filterValue.layer.masksToBounds = true

        let height = filtersCollectionView.collectionViewLayout.collectionViewContentSize.height
        filtersCollectionViewHeight.constant = height
        tableViewTopConstraint.constant = height + 20
        
        self.view.layoutIfNeeded()
        if keyValue == "To Do"{
            keyName = "TodoStatus"
        }else if keyValue == "In Progress"{
            keyName = "InprogressStatus"
        }else if keyValue == "Done"{
            keyName = "DoneStatus"
        }else if keyValue == "Blocked"{
            keyName = "BlockedStatus"
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let keyName = Array(filtersDict)[indexPath.row].key
        print(filtersDict)
//        var status = JSON(filtersDict)["Status"].arrayValue
//        if keyName == "todoStatus"{
//            let index = status.firstIndex(of: "todo")
//            status.remove(at: index!)
//            filtersDict.removeValue(forKey: "Status")
//            filtersDict["Status"] = status
//        }else if keyName == "inprogressStatus"{
//            let index = status.firstIndex(of: "in-Progress")
//            status.remove(at: index!)
//            filtersDict.removeValue(forKey: "Status")
//            filtersDict["Status"] = status
//        }else if keyName == "doneStatus"{
//            let index = status.firstIndex(of: "done")
//            status.remove(at: index!)
//            filtersDict.removeValue(forKey: "Status")
//            filtersDict["Status"] = status
//        }else if keyName == "blockedStatus"{
//            let index = status.firstIndex(of: "blocked")
//            status.remove(at: index!)
//            filtersDict.removeValue(forKey: "Status")
//            filtersDict["Status"] = status
//        }
        filtersDict.removeValue(forKey: keyName)
        
        print(filtersDict)
        if filtersDict.count != 0 {
            self.filtersCollectionView.reloadData()
            careKernelDefaults.set(nil, forKey: "tasksFiltersValue")
            let status = JSON(filtersDict)["Status"].arrayValue
            var statusArr = [String]()
            for statusValue in status{
                statusArr.append(statusValue.stringValue)
            }
            let priority = JSON(filtersDict)["Priority"].stringValue
            let isArchived = JSON(filtersDict)["Is Archived"].stringValue
            let category = JSON(filtersDict)["Category"].stringValue
            let from = JSON(filtersDict)["From"].stringValue
            let to = JSON(filtersDict)["To"].stringValue
            let todoStatus = JSON(filtersDict)["TodoStatus"].stringValue
            let inprogressStatus = JSON(filtersDict)["InprogressStatus"].stringValue
            let doneStatus = JSON(filtersDict)["DoneStatus"].stringValue
            let blockedStatus = JSON(filtersDict)["BlockedStatus"].stringValue
            let filterModel = FiltersModel(todoStatus: todoStatus, inprogressStatus: inprogressStatus, doneStatus: doneStatus, blockedStatus: blockedStatus, priority: priority, isArchived: isArchived, category: category, fromDate: from, toDate: to)
            
            print(filterModel.getJson())
            careKernelDefaults.set(filterModel.getJson(), forKey: "tasksFiltersValue")
            checkFilters()
            let height = filtersCollectionView.collectionViewLayout.collectionViewContentSize.height
            filtersCollectionViewHeight.constant = height
            self.view.layoutIfNeeded()
        }else{
            careKernelDefaults.set(nil, forKey: "tasksFiltersValue")
            clearAllButton.isHidden = true
            checkFilters()
        }
    }
    
    
}

extension TaskListViewController : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        tasksArray.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TaskListTableViewCell", for: indexPath) as! TaskListTableViewCell
        
        
        let date = JSON(tasksArray)[indexPath.row]["dueDate"].stringValue
        let dueDatString = getFormattedDate(date: iso860ToString(dateString: date), format: "dd/MM/yyy")
        let priority = JSON(tasksArray)[indexPath.row]["priority"].stringValue
        let taskStatus = JSON(tasksArray)[indexPath.row]["taskStatus"].stringValue
        cell.titleLabel.text = JSON(tasksArray)[indexPath.row]["title"].stringValue.capitalized
        cell.taskIdlbl.text = JSON(tasksArray)[indexPath.row]["displayId"].stringValue
        cell.statusLbl.text = taskTitleToShow(receivedTitle: taskStatus)
        cell.dueDateLbl.text = dueDatString
        let hasAttachemets = JSON(tasksArray)[indexPath.row]["taskFiles"].arrayValue
        if hasAttachemets.count > 0 {
            cell.attachmentIcon.isHidden = false
        }else{
            cell.attachmentIcon.isHidden = true
        }
        let entity = JSON(tasksArray)[indexPath.row]["entity"].stringValue.capitalized
        let entityID = JSON(tasksArray)[indexPath.row]["entityId"].intValue
        let subEntity = JSON(tasksArray)[indexPath.row]["subEntity"].stringValue.capitalized
        let subEntityId = JSON(tasksArray)[indexPath.row]["subEntityId"].intValue
        
        if entity == "" {
            cell.clientIdLabel.text = "NA"
            cell.clientIdLabel.textColor = UIColor(named: "Light Grey Font")
            cell.clientIdLabel.isUserInteractionEnabled = false
        }else{
            cell.clientIdLabel.text = "\(entity)" + "-" + "\(entityID)"
        }
        if entity == "" && subEntity == "" {
            cell.relatedtoClientLabel.text = ""
        }else if subEntity == ""{
            cell.relatedtoClientLabel.text = "NA"
        }else{
            cell.relatedtoClientLabel.text = "\(subEntity)" + " - " + "\(subEntityId)"
        }
        if entity == "Client" && entityID != 0{
            cell.clientIdLabel.textColor = UIColor(named: "Basic Blue")
            cell.clientIdLabel.isUserInteractionEnabled = true
            let guestureRecognizer = CustomTapGestureRecognizer(target: self, action: #selector(self.labelClicked(sender:)))
            guestureRecognizer.ourCustomValue = entityID
            cell.clientIdLabel.addGestureRecognizer(guestureRecognizer)
        }

        let category = JSON(tasksArray)[indexPath.row]["category"]["name"].stringValue
        cell.categoryLabel.text = category
        
        cell.priorityLbl.text = priority.capitalized
        let badgeView = UIView()
        badgeView.layer.cornerRadius = 4
        cell.priorityLbl.addSubview(badgeView)
        badgeView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            badgeView.rightAnchor.constraint(equalTo: cell.priorityLbl.leftAnchor, constant: -4),
            badgeView.topAnchor.constraint(equalTo: cell.priorityLbl.topAnchor, constant: 5),
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
        
        let dueDateF = iso860ToString(dateString: date)
        let currentDateTime = Date()
        let add12Hours = currentDateTime.withAddedHours(hours: 12)
        let add24Hours = currentDateTime.withAddedHours(hours: 24)
        let difference = dueDateF.timeIntervalSince(currentDateTime)
        let c12dif = currentDateTime.timeIntervalSince(add12Hours)
        let c24dif = currentDateTime.timeIntervalSince(add24Hours)

        if difference > c12dif {
            cell.dueDateLbl.backgroundColor = UIColor(named: "Home calendertable cell")
            cell.dueDateLbl.textColor = UIColor(named: "Light Grey Font")
            cell.dueDateLbl.setMargins(0)
        }else if difference >= c24dif {
            cell.dueDateLbl.backgroundColor = .orange
            cell.dueDateLbl.textColor = .white
            cell.dueDateLbl.setMargins(5)
        }else{
            cell.dueDateLbl.backgroundColor = .red
            cell.dueDateLbl.textColor = .white
            cell.dueDateLbl.setMargins(5)
        }
        
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let taskId = JSON(tasksArray)[indexPath.row]["id"].intValue
        self.performSegue(withIdentifier: "segueToTaskDetails", sender: taskId)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {

        if currentPage < totalPage && indexPath.row == self.tasksArray.count - 1 {
            currentPage = currentPage + 1
            let url = tasksURL + "?assigneeId=" + "\(String(describing: self.sessionUserId))"
            self.fetchData(url: url, page: currentPage, refresh: false)
            
        }
    }
}
