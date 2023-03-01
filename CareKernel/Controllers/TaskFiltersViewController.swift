//
//  TaskFiltersViewController.swift
//  CareKernel
//
//  Created by Mohit Sharma on 22/11/21.
//

import UIKit
import SwiftyJSON
import TagListView

class TaskFiltersViewController: UIViewController {
    
    @IBOutlet var todoButton: UIButton!
    @IBOutlet var inProgressButton: UIButton!
    @IBOutlet var doneButton: UIButton!
    @IBOutlet var blockedButton: UIButton!
    @IBOutlet var fromDateButton: UIButton!
    @IBOutlet var toDateButton: UIButton!
    @IBOutlet var highPriorityButton: UIButton!
    @IBOutlet var mediumPriorityButton: UIButton!
    @IBOutlet var lowPriorityButton: UIButton!
    @IBOutlet var nameTagsView: TagListView!
    @IBOutlet var scrollContentView: UIView!
    @IBOutlet var datePicker: UIDatePicker!
    @IBOutlet var dateView: UIView!
    @IBOutlet var applyButton: UIButton!
    @IBOutlet var isArchivedSwitch: UISwitch!
    
    
    
    var todoStatus = ""
    var inprogressStatus = ""
    var doneStatus = ""
    var blockedStatus = ""
    var priority = ""
    var isArchived = ""
    var category = ""
    var fromDate = ""
    var toDate = ""
    var categoriesArray = NSMutableArray()
    var selectedDateType = ""
    var minimumToDate = Date()
    var maximumFromDate = Date()
    var isTodoOn = Bool()
    var isInProgressOn = Bool()
    var isDoneOn = Bool()
    var isBlocked = Bool()
    var statusArr = [String]()
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchData()
        // Do any additional setup after loading the view.
        scrollContentView.heightAnchor.constraint(equalToConstant: scrollContentView.frame.height).isActive = true
        datePicker.locale = .current
        datePicker.date = Date()
        dateView.isHidden = true
        applyButton.layer.cornerRadius = 8
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.fromDate = ""
        self.toDate = ""
        let categoriesArray = careKernelDefaults.value(forKey: "categoriesToShow") as? NSArray
        isArchivedSwitch.isOn = false
        isArchivedSwitch.onTintColor = .white
        isArchivedSwitch.thumbTintColor = .white
        isArchivedSwitch.layer.borderWidth = 1
        isArchivedSwitch.layer.borderColor = UIColor.lightGray.cgColor
        isArchivedSwitch.layer.cornerRadius = 16
    }
    
    @IBAction func backButtonAction(_ sender: UIButton) {
        self.dismiss(animated: true)
    }
    
    @IBAction func statusButtonAction(_ sender: UIButton) {
        switch sender {
        case todoButton :
            
            if isTodoOn {
                todoButton.setTitleColor(UIColor(named: "Calender Font color"), for: .normal)
                todoButton.backgroundColor = UIColor(named: "Filters Button Background")
                isTodoOn = false
                self.todoStatus = ""
                if statusArr.contains("todo") {
                   let index = statusArr.firstIndex(of: "todo")
                    statusArr.remove(at: index!)
                   print(statusArr)
                }
            }else{
                todoButton.setTitleColor(UIColor(named: "Basic BlueWhite font"), for: .normal)
                todoButton.backgroundColor = #colorLiteral(red: 0.1529411765, green: 0.2274509804, blue: 0.8078431373, alpha: 0.2870000005)
                isTodoOn = true
                self.todoStatus = "todo"
            }

            break
        case inProgressButton :
            
            if isInProgressOn {
                inProgressButton.setTitleColor(UIColor(named: "Calender Font color"), for: .normal)
                inProgressButton.backgroundColor = UIColor(named: "Filters Button Background")
                isInProgressOn = false
                self.inprogressStatus = ""
                if statusArr.contains("in-progress") {
                   let index = statusArr.firstIndex(of: "in-progress")
                    statusArr.remove(at: index!)
                   print(statusArr)
                }
            }else{
                inProgressButton.setTitleColor(UIColor(named: "Basic BlueWhite font"), for: .normal)
                inProgressButton.backgroundColor = #colorLiteral(red: 0.1529411765, green: 0.2274509804, blue: 0.8078431373, alpha: 0.2870000005)
                isInProgressOn = true
                self.inprogressStatus = "in-progress"
            }

            break
        case doneButton :
            self.doneStatus = "done"
            if isDoneOn {
                doneButton.setTitleColor(UIColor(named: "Calender Font color"), for: .normal)
                doneButton.backgroundColor = UIColor(named: "Filters Button Background")
                isDoneOn = false
                self.doneStatus = ""
                if statusArr.contains("done") {
                   let index = statusArr.firstIndex(of: "done")
                    statusArr.remove(at: index!)
                   print(statusArr)
                }
            }else{
                doneButton.setTitleColor(UIColor(named: "Basic BlueWhite font"), for: .normal)
                doneButton.backgroundColor = #colorLiteral(red: 0.1529411765, green: 0.2274509804, blue: 0.8078431373, alpha: 0.2870000005)
                isDoneOn = true
                self.doneStatus = "done"
            }

            break
        case blockedButton :
            self.blockedStatus = "blocked"
            if isBlocked {
                blockedButton.setTitleColor(UIColor(named: "Calender Font color"), for: .normal)
                blockedButton.backgroundColor = UIColor(named: "Filters Button Background")
                isBlocked = false
                self.blockedStatus = ""
                if statusArr.contains("blocked") {
                   let index = statusArr.firstIndex(of: "blocked")
                    statusArr.remove(at: index!)
                   print(statusArr)
                }
            }else{
                blockedButton.setTitleColor(UIColor(named: "Basic BlueWhite font"), for: .normal)
                blockedButton.backgroundColor = #colorLiteral(red: 0.1529411765, green: 0.2274509804, blue: 0.8078431373, alpha: 0.2870000005)
                isBlocked = true
                self.blockedStatus = "blocked"
            }

            break
        default :
            
            break
        }
    }
    
    @IBAction func dateButtonAction(_ sender: UIButton) {
        
        switch sender {
        case fromDateButton :
            datePicker.minimumDate = .distantPast
            selectedDateType = "from"
            if self.toDate != "" {
                datePicker.maximumDate = maximumFromDate
            }
            
            dateView.isHidden = false
            break
        case toDateButton :
            
            selectedDateType = "to"
            datePicker.minimumDate = minimumToDate
            dateView.isHidden = false
            
            break
            
        default : break
        }
    }
    
    @IBAction func priorityButtonAction(_ sender: UIButton) {
        
        switch sender {
        case highPriorityButton :
            self.priority = "high"
            highPriorityButton.setTitleColor(UIColor(named: "Basic BlueWhite font"), for: .normal)
            highPriorityButton.backgroundColor = #colorLiteral(red: 0.1529411765, green: 0.2274509804, blue: 0.8078431373, alpha: 0.2870000005)
            mediumPriorityButton.setTitleColor(UIColor(named: "Calender Font color"), for: .normal)
            mediumPriorityButton.backgroundColor = UIColor(named: "Filters Button Background")
            lowPriorityButton.setTitleColor(UIColor(named: "Calender Font color"), for: .normal)
            lowPriorityButton.backgroundColor = UIColor(named: "Filters Button Background")
            break
        case mediumPriorityButton :
            self.priority = "medium"
            highPriorityButton.setTitleColor(UIColor(named: "Calender Font color"), for: .normal)
            highPriorityButton.backgroundColor = UIColor(named: "Filters Button Background")
            mediumPriorityButton.setTitleColor(UIColor(named: "Basic BlueWhite font"), for: .normal)
            mediumPriorityButton.backgroundColor = #colorLiteral(red: 0.1529411765, green: 0.2274509804, blue: 0.8078431373, alpha: 0.2870000005)
            lowPriorityButton.setTitleColor(UIColor(named: "Calender Font color"), for: .normal)
            lowPriorityButton.backgroundColor = UIColor(named: "Filters Button Background")
            break
        case lowPriorityButton :
            self.priority = "low"
            highPriorityButton.setTitleColor(UIColor(named: "Calender Font color"), for: .normal)
            highPriorityButton.backgroundColor = UIColor(named: "Filters Button Background")
            mediumPriorityButton.setTitleColor(UIColor(named: "Calender Font color"), for: .normal)
            mediumPriorityButton.backgroundColor = UIColor(named: "Filters Button Background")
            lowPriorityButton.setTitleColor(UIColor(named: "Basic BlueWhite font"), for: .normal)
            lowPriorityButton.backgroundColor = #colorLiteral(red: 0.1529411765, green: 0.2274509804, blue: 0.8078431373, alpha: 0.2870000005)
            break
        default : break
        }
        
    }
    
    @IBAction func isArchiveSwitchAction(_ sender: UISwitch) {
        if sender.isOn{
            self.isArchived = "true"
            isArchivedSwitch.onTintColor = .white
            isArchivedSwitch.thumbTintColor = .green
            isArchivedSwitch.layer.borderWidth = 1
            isArchivedSwitch.layer.borderColor = UIColor(named: "Filters Button Background")?.cgColor
            isArchivedSwitch.layer.cornerRadius = 16
        }else{
            self.isArchived = "false"
            isArchivedSwitch.onTintColor = .white
            isArchivedSwitch.thumbTintColor = .white
            isArchivedSwitch.layer.borderWidth = 1
            isArchivedSwitch.layer.borderColor = UIColor(named: "Filters Button Background")?.cgColor
            isArchivedSwitch.layer.cornerRadius = 16
        }
    }
    

    
    @IBAction func applyButtonAction(_ sender: UIButton) {
        
        if (self.fromDate != "" && self.toDate == "") {
            self.showAlert("Alert!", message: "Please select 'To date'", actions: ["Ok"]) { actionTitle in

            }
        }else if (self.fromDate == "" && self.toDate != "") {
            self.showAlert("Alert!", message: "Please select 'From date'", actions: ["Ok"]) { actionTitle in

            }
        }else{
           
            let filterModel = FiltersModel(todoStatus: self.todoStatus, inprogressStatus: self.inprogressStatus, doneStatus: self.doneStatus, blockedStatus: self.blockedStatus, priority: self.priority, isArchived: self.isArchived, category: self.category, fromDate: self.fromDate, toDate: self.toDate)
            
            print(filterModel.getJson())
//            var filtersData = filterModel.getJson()
//
//            for statusValue in statusArr{
//                if statusValue == "todo"{
//                    filtersData["todoStatus"] = statusValue
//                }else if statusValue == "in-progress"{
//                    filtersData["inprogressStatus"] = statusValue
//                }else if statusValue == "done"{
//                    filtersData["doneStatus"] = statusValue
//                }else if statusValue == "blocked"{
//                    filtersData["blockedStatus"] = statusValue
//                }
//            }
//            print(filtersData)
            careKernelDefaults.set(filterModel.getJson(), forKey: "tasksFiltersValue")
            careKernelDefaults.setValue(self.categoriesArray, forKey: "categoriesToShow")
            self.dismiss(animated: true, completion: nil)
        }

        
    }

    func presentStoryboard(segue: String, sender: Any?){
        //        hud.dismiss()
        //        self.view.isUserInteractionEnabled = true
        DispatchQueue.main.async {
            self.performSegue(withIdentifier: segue, sender: sender)
        }
        
    }
    func fetchData(){
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
                        self.nameTagsView.addTag(catName)
                        self.categoriesArray.add(keyValue)
                    }
                    self.nameTagsView.reloadInputViews()
                    careKernelDefaults.set(self.categoriesArray, forKey: "categories")
                    
                    self.setUI()
                }
                
            }
        }
    }
    
    func setUI(){
        if let filters = careKernelDefaults.value(forKey: "tasksFiltersValue") as? NSDictionary{
            
            let values = JSON(filters).dictionaryValue
            let statusArr = JSON(filters)["Status"].arrayValue

            for arrValue in statusArr {
                let status = arrValue.stringValue
                switch status {
                case "todo" :
//                    self.status = "todo"
//                    self.statusArr.append("todo")
//                    todoButton.setTitleColor(UIColor(named: "Basic BlueWhite font"), for: .normal)
//                    todoButton.backgroundColor = #colorLiteral(red: 0.1529411765, green: 0.2274509804, blue: 0.8078431373, alpha: 0.2870000005)
//                    todoButton.clipsToBounds = true
//                    isTodoOn = true
                    break
                case "in-progress" :
//                    self.status = "in-progress"
//                    self.statusArr.append("in-progress")
//                    inProgressButton.setTitleColor(UIColor(named: "Basic BlueWhite font"), for: .normal)
//                    inProgressButton.backgroundColor = #colorLiteral(red: 0.1529411765, green: 0.2274509804, blue: 0.8078431373, alpha: 0.2870000005)
//                    isInProgressOn = true
                    break
                case "done" :
//                    self.status = "done"
//                    self.statusArr.append("done")
//                    doneButton.setTitleColor(UIColor(named: "Basic BlueWhite font"), for: .normal)
//                    doneButton.backgroundColor = #colorLiteral(red: 0.1529411765, green: 0.2274509804, blue: 0.8078431373, alpha: 0.2870000005)
//                    isDoneOn = true
                    break
                case "blocked" :
//                    self.status = "blocked"
//                    self.statusArr.append("blocked")
//                    blockedButton.setTitleColor(UIColor(named: "Basic BlueWhite font"), for: .normal)
//                    blockedButton.backgroundColor = #colorLiteral(red: 0.1529411765, green: 0.2274509804, blue: 0.8078431373, alpha: 0.2870000005)
//                    isBlocked = true
                    break
                default :
                    
                    break
                }
            }
            let todoStatus = JSON(filters)["TodoStatus"].stringValue
            if todoStatus != ""{
                self.todoStatus = "todo"
                todoButton.setTitleColor(UIColor(named: "Basic BlueWhite font"), for: .normal)
                todoButton.backgroundColor = #colorLiteral(red: 0.1529411765, green: 0.2274509804, blue: 0.8078431373, alpha: 0.2870000005)
                todoButton.clipsToBounds = true
                isTodoOn = true
            }
            
            let doneStatus = JSON(filters)["DoneStatus"].stringValue
            if doneStatus != ""{
                self.doneStatus = "done"
                doneButton.setTitleColor(UIColor(named: "Basic BlueWhite font"), for: .normal)
                doneButton.backgroundColor = #colorLiteral(red: 0.1529411765, green: 0.2274509804, blue: 0.8078431373, alpha: 0.2870000005)
                isDoneOn = true
            }
            
            let inprogressStatus = JSON(filters)["InprogressStatus"].stringValue
            if inprogressStatus != ""{
                self.inprogressStatus = "in-progress"
                inProgressButton.setTitleColor(UIColor(named: "Basic BlueWhite font"), for: .normal)
                inProgressButton.backgroundColor = #colorLiteral(red: 0.1529411765, green: 0.2274509804, blue: 0.8078431373, alpha: 0.2870000005)
                isInProgressOn = true
            }
            
            let blockedStatus = JSON(filters)["BlockedStatus"].stringValue
            if blockedStatus != ""{
                self.blockedStatus = "blocked"
                blockedButton.setTitleColor(UIColor(named: "Basic BlueWhite font"), for: .normal)
                blockedButton.backgroundColor = #colorLiteral(red: 0.1529411765, green: 0.2274509804, blue: 0.8078431373, alpha: 0.2870000005)
                isBlocked = true
            }
            
            let priority = JSON(filters)["Priority"].stringValue
            switch priority {
            case "high" :
                self.priority = "high"
                highPriorityButton.setTitleColor(UIColor(named: "Basic BlueWhite font"), for: .normal)
                highPriorityButton.backgroundColor = #colorLiteral(red: 0.1529411765, green: 0.2274509804, blue: 0.8078431373, alpha: 0.2870000005)
                break
            case "medium" :
                self.priority = "medium"
                mediumPriorityButton.setTitleColor(UIColor(named: "Basic BlueWhite font"), for: .normal)
                mediumPriorityButton.backgroundColor = #colorLiteral(red: 0.1529411765, green: 0.2274509804, blue: 0.8078431373, alpha: 0.2870000005)
                break
            case "low" :
                self.priority = "low"
                lowPriorityButton.setTitleColor(UIColor(named: "Basic BlueWhite font"), for: .normal)
                lowPriorityButton.backgroundColor = #colorLiteral(red: 0.1529411765, green: 0.2274509804, blue: 0.8078431373, alpha: 0.2870000005)
                break
            default : break
            }
            let isArchived = JSON(filters)["Is Archived"].stringValue
            switch isArchived {
            case "true" :
                self.isArchived = "true"
                isArchivedSwitch.isOn = true
                isArchivedSwitch.onTintColor = .white
                isArchivedSwitch.thumbTintColor = #colorLiteral(red: 0.1529411765, green: 0.2274509804, blue: 0.8078431373, alpha: 0.850384505)
                isArchivedSwitch.layer.borderWidth = 1
                isArchivedSwitch.layer.borderColor = #colorLiteral(red: 0.1529411765, green: 0.2274509804, blue: 0.8078431373, alpha: 0.850384505)
                isArchivedSwitch.layer.cornerRadius = 16
                
                break
            case "false" :
                self.isArchived = "false"
                isArchivedSwitch.isOn = false
                isArchivedSwitch.onTintColor = .white
                isArchivedSwitch.thumbTintColor = .white
                isArchivedSwitch.layer.borderWidth = 1
                isArchivedSwitch.layer.borderColor = UIColor(named: "Filters Button Background")?.cgColor
                isArchivedSwitch.layer.cornerRadius = 16
                break
                
            default : break
            }
            let category = JSON(filters)["Category"].stringValue
            if category != "" {
                let categoriesArray = careKernelDefaults.value(forKey: "categories") as? NSMutableArray
                
                var selectedTagValue = ""
                for i in categoriesArray ?? [] {
                    let catDict = i as! Dictionary<String,Any>
                    if catDict["id"] as! String == category{
                        selectedTagValue = catDict["name"] as! String
                    }
                }
                for ta in nameTagsView.tagViews {
                    if ta.titleLabel?.text == selectedTagValue {
                        ta.isSelected = true
                        self.category = category
                    }
                }
                 
            }
            let fromDate = JSON(filters)["From"].stringValue
            if fromDate != "" {
                self.fromDate = fromDate
                fromDateButton.setTitle(fromDate, for: .normal)
                fromDateButton.setTitleColor(UIColor(named: "Basic BlueWhite font"), for: .normal)
                fromDateButton.backgroundColor = #colorLiteral(red: 0.1529411765, green: 0.2274509804, blue: 0.8078431373, alpha: 0.2574060705)
            }
            let toDate = JSON(filters)["To"].stringValue
            if toDate != "" {
                self.toDate = toDate
                toDateButton.setTitle(toDate, for: .normal)
                toDateButton.setTitleColor(UIColor(named: "Basic BlueWhite font"), for: .normal)
                toDateButton.backgroundColor = #colorLiteral(red: 0.1529411765, green: 0.2274509804, blue: 0.8078431373, alpha: 0.2574060705)
            }
        }
    }
    func getFormattedDate(date: Date, format: String) -> String {
        let dateformat = DateFormatter()
        dateformat.dateFormat = format
        return dateformat.string(from: date)
    }
    @IBAction func datePicker(_ sender: UIDatePicker) {
        setDateUI(selectedDate: datePicker.date)
    }
    
    @IBAction func doneButtonAction(_ sender: UIButton) {
        if selectedDateType == "from" {
            if self.fromDate == "" {
                
                setDateUI(selectedDate: Date())
            }
        }else{
            if self.toDate == ""{
                
                setDateUI(selectedDate: Date())
            }
        }
       
        
        dateView.isHidden = true
        
    }
    
    func setDateUI(selectedDate: Date){
        let date = getFormattedDate(date: selectedDate, format: "dd/MM/yyyy")
        print(date)
        if selectedDateType == "from" {
            minimumToDate = selectedDate
            self.fromDate = date
            fromDateButton.setTitle(date, for: .normal)
            fromDateButton.setTitleColor(UIColor(named: "Basic BlueWhite font"), for: .normal)
            fromDateButton.backgroundColor = #colorLiteral(red: 0.1529411765, green: 0.2274509804, blue: 0.8078431373, alpha: 0.2574060705)
//            self.toDate = ""
//            toDateButton.setTitle("Date", for: .normal)
//            toDateButton.backgroundColor = UIColor(named: "Filters Button Background")
//            toDateButton.setTitleColor(UIColor(named: "Client Profile text font"), for: .normal)
        }else{
            self.toDate = date
            
            maximumFromDate = selectedDate
            toDateButton.setTitle(date, for: .normal)
            toDateButton.setTitleColor(UIColor(named: "Basic BlueWhite font"), for: .normal)
            toDateButton.backgroundColor = #colorLiteral(red: 0.1529411765, green: 0.2274509804, blue: 0.8078431373, alpha: 0.2574060705)
            
        }
    }
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
}
extension TaskFiltersViewController : TagListViewDelegate {
    
    func tagPressed(_ title: String, tagView: TagView, sender: TagListView) {
        print("Tag pressed: \(title), \(sender.tag)")
        for ta in sender.tagViews {
            if ta.titleLabel?.text == title {
                ta.isSelected = !ta.isSelected
            }else{
                ta.isSelected = false
            }
        }
        for i in categoriesArray{

            let allDict = i as! Dictionary<String,Any>
            if allDict["name"] as! String == title {
                self.category = allDict["id"] as! String
            }
        }

//        tagView.isSelected = !tagView.isSelected
    }
    
}
