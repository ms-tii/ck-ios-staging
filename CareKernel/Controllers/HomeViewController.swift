//
//  ViewController.swift
//  CareKernel
//
//  Created by Mohit Sharma on 30/08/21.
//

import UIKit
import JGProgressHUD
import TagListView
import SwiftyJSON
import JWTDecode

var selectedDate = Date()

class HomeViewController: UIViewController {
    
    @IBOutlet var calendarCollectionView: UICollectionView!
    @IBOutlet var eventsTableView: UITableView!
    @IBOutlet var monthLabel: UILabel!
    @IBOutlet var sessionLabel: UILabel!
    @IBOutlet var selectedDateLabel: UILabel!
    @IBOutlet var noRecordLabel: UILabel!
    @IBOutlet weak var topBarContainer: UIView!
    @IBOutlet var notificationButton: ButtonWithProperty!
    
    @IBOutlet weak var draggableDataLabel: UILabel!
    @IBOutlet weak var draggableDetailsButton: UIButton!
    @IBOutlet weak var draggableView: UIView!
    
    let hud = JGProgressHUD()
    var totalSquares = [Date]()
    var allTags = ["J.D.Smith", "Jhon Doe"]
    var moveToNextWeek = Bool()
    var sessionsViewModel = SessionsViewModel()
    var startDate = String()
    var endDate = String()
    var offset = "0"
    var totalPage = 1
    var currentPage = 1
    var sessionData = NSMutableArray()
    var nametagFlowHeightConstraint: NSLayoutConstraint?
    var descriptiontagFlowHeightConstraint: NSLayoutConstraint?
    var selectedDateIndex = Int()
    var runningSessionId = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setCellsView()
        setWeekView()
        notificationButton.isBadgeShow = true
        NotificationCenter.default.addObserver(self, selector: #selector(self.pushNotificationUpdate(notification:)), name: Notification.Name.init(rawValue: "pushNotificationUpdate"), object: nil)
        self.draggableView.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(handler)))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.draggableView.isHidden = true
        let bundleID = Bundle.main.bundleIdentifier
        
        self.hud.contentView.backgroundColor = #colorLiteral(red: 0.1529411765, green: 0.2274509804, blue: 0.8078431373, alpha: 0.1175952431)
        
        eventsTableView.delegate = self
        eventsTableView.dataSource = self
        
        checkUserLogin()
        
        
        var swipe = UISwipeGestureRecognizer(target: self, action: #selector(swipeGesture))
        swipe.numberOfTouchesRequired = 1
        swipe.direction = .left
        self.calendarCollectionView.addGestureRecognizer(swipe)
        
        swipe = UISwipeGestureRecognizer(target: self, action: #selector(swipeGesture))
        swipe.numberOfTouchesRequired = 1
        swipe.direction = .right
        self.calendarCollectionView.addGestureRecognizer(swipe)
        
        //        eventsTableView.rowHeight = UITableView.automaticDimension
        //        eventsTableView.estimatedRowHeight = 185.0
        //
        
        fetchNotificationData()
        careKernelDefaults.removeObject(forKey: "incidentsFilterDate")
        careKernelDefaults.removeObject(forKey: "tasksFiltersValue")
        
        if let clockedStatus = careKernelDefaults.value(forKey: "clockedStatus") as? [String : Any]{
            let boldAttribute = [
                  NSAttributedString.Key.font: UIFont(name: "HelveticaNeue-Bold", size: 15.0)!
               ]
            let isClockedOn = JSON(clockedStatus)["isClockOn"].boolValue
            if isClockedOn {
                let displayId = JSON(clockedStatus)["displayId"].stringValue
                runningSessionId = JSON(clockedStatus)["sessionID"].intValue
                let regularText = NSAttributedString(string: "Clock Off \(displayId) ", attributes: .none)
                let boldText = NSAttributedString(string: "Details >>", attributes: boldAttribute)
                
                let newString = NSMutableAttributedString()
                newString.append(regularText)
                newString.append(boldText)
                self.draggableDataLabel.attributedText = newString //"Clock Off \(displayId) Details >>"
                self.draggableView.isHidden = false
            }else{
                draggableView.isHidden = true
            }
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.moveToNextWeek = false
        self.view.isUserInteractionEnabled = true
        self.hud.dismiss()
    }

    override func viewDidLayoutSubviews(){
            super.viewDidLayoutSubviews()
        var frame = self.calendarCollectionView.frame
        
//        if UIDevice().type == .iPhone13Pro{
//            frame.size.width = 55
//            frame.size.height = 65
//            self.calendarCollectionView.frame = frame
//        }
  
    
    }
    
    @IBAction func draggableDetailsButtonAction(_ sender: UIButton) {
        print("pressed drag details")
        presentStoryboard(segue: "segueToSessionDetails", sender: runningSessionId)
    }
    
    
    @IBAction func notificationAction(_ sender: UIButton) {
        presentStoryboard(segue: "segueToNotification", sender: nil)
//        if let url = URL(string: "tel://\(9876741639)"){
//                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
//                }
    }
    @objc func handler(gesture: UIPanGestureRecognizer){
        let location = gesture.location(in: self.view)
                let draggedView = gesture.view
                draggedView?.center = location
                
                if gesture.state == .ended {
                    if self.draggableView.frame.midX >= self.view.layer.frame.width / 2 && self.draggableView.frame.midY >= self.view.layer.frame.height / 2{
                        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseIn, animations: {
                            self.draggableView.center.x = self.view.layer.frame.width - 150
                            if self.draggableView.center.y >= self.view.layer.frame.height - 150 {
                                self.draggableView.center.y = self.view.layer.frame.height - 120
                            }
//                            self.draggableView.center.y = self.view.layer.frame.height - 150
                            print(self.view.layer.frame.width)
                        }, completion: nil)
                    }else if self.draggableView.frame.midX <= self.view.layer.frame.width / 2 && self.draggableView.frame.midY <= self.view.layer.frame.height / 2{
                        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseIn, animations: {
                            self.draggableView.center.x = 150
                            if self.draggableView.center.y <= 150 {
                                self.draggableView.center.y = 150
                            }
//                            self.draggableView.center.y = self.view.layer.frame.height - 150
                            print(self.view.layer.frame.width)
                            print(self.draggableView.center.x)
                        }, completion: nil)
                    }else if self.draggableView.frame.midX >= self.view.layer.frame.width / 2 && self.draggableView.frame.midY <= self.view.layer.frame.height / 2{
                        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseIn, animations: {
                            self.draggableView.center.x = self.draggableView.frame.width
                            if self.draggableView.center.y <= 150 {
                                self.draggableView.center.y = 150
                            }
//                            self.draggableView.center.y =
                            print(self.view.layer.frame.width)
                        }, completion: nil)
                    }else if self.draggableView.frame.midX <= self.view.layer.frame.width / 2 && self.draggableView.frame.midY >= self.view.layer.frame.height / 2{
                        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseIn, animations: {
                            self.draggableView.center.x = 150
                            if self.draggableView.center.y >= self.view.layer.frame.height - 150 {
                                self.draggableView.center.y = self.view.layer.frame.height - 120
                            }
//                            self.draggableView.center.y = self.view.layer.frame.height - 150
                            print(self.view.layer.frame.width)
                            print(self.draggableView.center.x)
                        }, completion: nil)
                    }
                }
        }
    func checkUserLogin(){
        
        if userLoggedStatus(){
            print("HI")
            refreshTableView()
            self.sessionData.removeAllObjects()
            self.startDate = getFormattedDate(date: selectedDate, format: "yyyy-MM-dd'T'00:00:00XXX")
            self.endDate = getFormattedDate(date: selectedDate, format: "yyyy-MM-dd'T'23:59:59XXX")
            fetchData(page: 1, refresh: true)
        }else{
            presentStoryboard(segue: "segueToLogin", sender: nil)
        }
    }
    
    func userLoggedStatus() -> Bool{
        guard let isUserLoggedIn = careKernelDefaults.object(forKey: kIsLoggedIn) else {
            return false
        }
        return isUserLoggedIn as! Bool
    }
    
    @objc func swipeGesture(swipe: UISwipeGestureRecognizer){
        switch swipe.direction {
        case .left:
            changeWeek(days: 7)
            break
        case .right:
            changeWeek(days: -7)
            break
        default:
            break
        }
    }
    
    func getWeekStartEndDate(){
        let sunday = CalendarHelper().sundayForDate(date: selectedDate)
        self.startDate = getFormattedDate(date: sunday, format: "yyyy-MM-dd")
        
        let nextSat = CalendarHelper().addDays(date: sunday, days: 6)
        self.endDate = getFormattedDate(date: nextSat, format: "yyyy-MM-dd")
    }
    
    func changeWeek(days: Int){
        
        
        selectedDate = CalendarHelper().addDays(date: selectedDate, days: days)
        setWeekView()
        
        self.sessionData = NSMutableArray()
        currentPage = 1
        totalPage = 1
        fetchData(page: 1, refresh: true)
    }
    
    func setCellsView()
    {
        let width = (calendarCollectionView.frame.size.width - 2) / 8
        let height = (calendarCollectionView.frame.size.height - 2)
        
        let flowLayout = calendarCollectionView.collectionViewLayout as! UICollectionViewFlowLayout
        flowLayout.itemSize = CGSize(width: width, height: height)
    }
    
    func setWeekView()
    {
        totalSquares.removeAll()
        
        var current = CalendarHelper().sundayForDate(date: selectedDate)
        let nextSunday = CalendarHelper().addDays(date: current, days: 7)
        
        
        while (current < nextSunday)
        {
            totalSquares.append(current)
            current = CalendarHelper().addDays(date: current, days: 1)
        }
        
        monthLabel.text = CalendarHelper().monthString(date: selectedDate)
        + " " + CalendarHelper().yearString(date: selectedDate)
//        changeSessionStatus(selectedDate: selectedDate)
        if selectedDateIndex == 0 {
            for (i,value) in totalSquares.enumerated() {
                if value == selectedDate {
                    selectedDateIndex = i
                }
            }
        }else {
            selectedDate = totalSquares[selectedDateIndex]
        }
       
        changeSessionStatus(selectedDate: selectedDate)
        self.startDate = getFormattedDate(date: selectedDate, format: "yyyy-MM-dd'T'00:00:00XXX")
        print(self.startDate)
        
        self.endDate = getFormattedDate(date: selectedDate, format: "yyyy-MM-dd'T'23:59:59XXX")
        print(self.endDate)
        calendarCollectionView.reloadData()
    }
    
    func changeSessionStatus(selectedDate: Date){
        let selectedDateString = getFormattedDate(date: selectedDate, format: "dd, MMMM, yyyy")
        self.selectedDateLabel.text = selectedDateString
        let todayDate = getFormattedDate(date: Date(), format: "dd, MMMM, yyyy")
        let date = Date()
        if date == selectedDate {
            sessionLabel.text = "Today's Sessions"
        }else if date > selectedDate {
            if todayDate == selectedDateString{
                sessionLabel.text = "Today's Sessions"
            }else{
                sessionLabel.text = "Previous Sessions"
            }
        }else if date < selectedDate{
            sessionLabel.text = "Upcoming Sessions"
        }
        careKernelDefaults.setValue(sessionLabel.text, forKey: "sessionStatus")
    }
    
    func presentStoryboard(segue: String, sender: Any?){
        hud.dismiss()
        self.view.isUserInteractionEnabled = true
        DispatchQueue.main.async {
            self.sessionData.removeAllObjects()
            self.performSegue(withIdentifier: segue, sender: sender)
        }
        
    }
    
    func getFormattedDate(date: Date, format: String) -> String {
        let dateformat = DateFormatter()
        dateformat.dateFormat = format
        return dateformat.string(from: date)
    }
    
    
    func fetchData(page: Int, refresh: Bool = false){
        sessionData.removeAllObjects()
        let selectedDateString = getFormattedDate(date: selectedDate, format: "dd/MM/yyyy")
        selectedDateLabel.text = selectedDateString
        var sessionResponseModel = SessionResponseModel()
        if refresh {
            self.eventsTableView.refreshControl?.beginRefreshing()
        }
        print(self.startDate)
        print(self.endDate)
//        self.getWeekStartEndDate()
        sessionsViewModel.startDate = startDate
        sessionsViewModel.endDate = endDate

        guard let token = careKernelDefaults.value(forKey: kLoginToken) as? String else {
            careKernelDefaults.set(false, forKey: kIsLoggedIn)
            presentStoryboard(segue: "segueToLogin", sender: nil)
            return }
        print("this is token \(token)")
        sessionsViewModel.token = token
        let limitPerPage = 50
        self.offset = "\((page - 1) * limitPerPage)"
        print(self.offset)
        sessionsViewModel.getSessionList(startDate: self.startDate, endDate: self.endDate, offset: offset, limit: "\(limitPerPage)") { response,success  in
                        print(response)
            DispatchQueue.main.async {
                if success {
                    self.noRecordLabel.isHidden = true
                    if refresh {
                        self.eventsTableView.refreshControl?.endRefreshing()
                    }
                    
                    sessionResponseModel.success = true
                    sessionResponseModel.data = JSON(response)["data"].arrayValue
                    
                    let tempArray = sessionResponseModel.data! as NSArray
                    for value in tempArray{
                        self.sessionData.add(value)
                    }
                    
                    if self.sessionData.count > 0 {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            self.eventsTableView.isHidden = false
                            self.eventsTableView.reloadData()
                        }
                    }else{
                        self.hud.dismiss()
                        self.noRecordLabel.isHidden = false
                        self.eventsTableView.isHidden = true
                    }
                    let metaResponse = JSON(response)["meta"].dictionaryValue
                    sessionResponseModel.meta = metaResponse
                    self.totalPage = metaResponse["pages"]!.intValue
                    print(self.sessionData)
                }else{
                    
                    let statusCode = JSON(response)["statusCode"].intValue
                    let message = JSON(response)["message"].stringValue
                    if statusCode == 401 && message == "Unauthorized" {
                        careKernelDefaults.set(false, forKey: kIsLoggedIn)
                        careKernelDefaults.set("", forKey: kUserEmailId)
                        careKernelDefaults.set("", forKey: kLoginToken)
                        self.presentStoryboard(segue: "segueToLogin", sender: nil)
                    }
                    
                    self.eventsTableView.refreshControl?.endRefreshing()
                    self.hud.dismiss()
                    self.eventsTableView.isHidden = true
                    self.noRecordLabel.isHidden = false
                }
            }
        }
    }
    
    func refreshTableView(){
        self.eventsTableView.refreshControl = UIRefreshControl()
        self.eventsTableView.refreshControl?.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        
    }
    
    @objc private func refreshData(){
        print("Refreshed")
        self.fetchData(page: 1, refresh: true)
//        self.changeWeek(days: -7)
    }
    
    func iso860ToString(dateString: String) -> Date{
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        let date = dateFormatter.date(from:dateString) ?? Date()
        return date
        
        
    }
    
    @objc func pushNotificationUpdate(notification: Notification) {
        fetchNotificationData()
        
    }
    
    func fetchNotificationData(){
        var notificationVM = NotificationViewModel()
        guard let token = careKernelDefaults.value(forKey: kLoginToken) as? String else {
            careKernelDefaults.set(false, forKey: kIsLoggedIn)
            return }
        notificationVM.token = token
        notificationVM.getNotificationList() { response, success in
            if success {
                DispatchQueue.main.async {
                    let tempArray = JSON(response)["data"].arrayValue
                    if tempArray.count == 0 {
                        self.notificationButton.isRead = true
                        careKernelDefaults.set(false, forKey: "isNotificationAvailable")
                    }else if tempArray.count >= 1 {
                        self.notificationButton.isRead = false
                        careKernelDefaults.set(true, forKey: "isNotificationAvailable")
                    }
                }
            }else{
                
            }
        }
        
    }
    
    private func scrollToTop(tabelIndex: Int? = 0, selectedDate: String, animated: Bool) {
        
        var currentIndex = 0
        
        for (index, value) in self.sessionData.enumerated(){
            
            let startTime = JSON(self.sessionData)[index]["startDate"].stringValue
            let sessionDate = getFormattedDate(date: iso860ToString(dateString: startTime), format: "dd, MMMM, yyyy")
            if selectedDate == sessionDate {
                print("Found \(sessionDate) for index \(index)")
                currentIndex = index
                break
            }else{
                currentIndex = tabelIndex ?? 0
            }
            
            //        currentIndex += 1
        }
        
        let topRow = IndexPath(row: currentIndex,
                               section: 0)
        self.eventsTableView.scrollToRow(at: topRow,
                                         at: .top,
                                         animated: animated)
    }
    
    func heightWidthForView(text:String, font:UIFont, width:CGFloat) -> CGRect{
        
        let size = CGSize.init(width: width, height: 10)
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        let estimateFrame = NSString(string: text).self.boundingRect(with:  size, options: options, attributes: [NSAttributedString.Key.font: font], context: nil)
        
        return estimateFrame
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let vc = segue.destination as? ClientMainViewController {
            vc.clientId = sender as! Int
        }else if let vc = segue.destination as? SessionDetailsViewController {
            vc.sessionId = sender as! Int
        }else if let vc = segue.destination as? SessionsViewController {
            vc.sessionId = sender as! Int
        }
    }
    

}
extension UILabel {
    func getSize(constrainedWidth: CGFloat) -> CGSize {
        return systemLayoutSizeFitting(CGSize(width: constrainedWidth, height: UIView.layoutFittingCompressedSize.height), withHorizontalFittingPriority: .required, verticalFittingPriority: .fittingSizeLevel)
    }
}
extension HomeViewController : UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let frame = self.calendarCollectionView.frame
        
       
        switch UIDevice().type {
        case .iPhone12ProMax, .iPhone13ProMax, .iPhone13Pro  :
            return CGSize(width: 55, height: 65)

        default:
            return CGSize(width: frame.size.width/8, height: frame.size.height)

        }


        }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        totalSquares.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "calendarCell", for: indexPath) as! CalendarCell
        
        let date = totalSquares[indexPath.item]
        cell.dayOfMonth.text = String(CalendarHelper().dayOfMonth(date: date))
        cell.labelBackground.layer.cornerRadius = 4
        print(date, selectedDate)
        if(date == selectedDate)
        {
            selectedDateIndex = indexPath.item
            cell.labelBackground.backgroundColor = UIColor(named: "TurquoiseColor")
            cell.dayOfMonth.textColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        }
        else
        {
            cell.labelBackground.backgroundColor = UIColor(named: "Home calendertable cell")
            cell.dayOfMonth.textColor = UIColor(named: "Calender Font color")
        }
        
        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)
    {
        selectedDateIndex = indexPath.item
        selectedDate = totalSquares[indexPath.item]
        changeSessionStatus(selectedDate: selectedDate)
        self.startDate = getFormattedDate(date: selectedDate, format: "yyyy-MM-dd'T'00:00:00XXX")
        self.endDate = getFormattedDate(date: selectedDate, format: "yyyy-MM-dd'T'23:59:59XXX")
        let selectedDateString = getFormattedDate(date: selectedDate, format: "dd, MMMM, yyyy")
        print(selectedDateString)
        self.selectedDateLabel.text = selectedDateString
        
        collectionView.reloadData()
        
        fetchData(page: 1, refresh: false)
//        if self.sessionData.count > 0 {
//            scrollToTop(selectedDate: selectedDateString, animated: true)
//        }
    }
    
}

extension HomeViewController : UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //        if currentPage < totalPage {
        //            return self.sessionData.count
        //        }else {
        return self.sessionData.count
        
        //        }
        
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "sessionCell") as! SessionInfoCell

        cell.selectionStyle = .none
        cell.jobIDLabel.text = "Session ID: " + JSON(self.sessionData)[indexPath.row]["displayId"].stringValue
        let description = JSON(self.sessionData)[indexPath.row]["description"].stringValue
        //to check the width/height of string
        let myheightLabel = UILabel()
        myheightLabel.text = description
        let labelHeight = myheightLabel.getSize(constrainedWidth: cell.nameTagsView.frame.width)

        
        let startTime = JSON(self.sessionData)[indexPath.row]["startDate"].stringValue
        let endTime = JSON(self.sessionData)[indexPath.row]["endDate"].stringValue
        let startEndTime = getFormattedDate(date: iso860ToString(dateString: startTime), format: "h:mm a") + " - " + getFormattedDate(date: iso860ToString(dateString: endTime), format: "h:mm a")
        cell.timeLabel.text = startEndTime
        let sessionDate = getFormattedDate(date: iso860ToString(dateString: startTime), format: "dd/MM/yyyy")
        cell.sessionDateLabel.text = sessionDate
        var address = JSON(self.sessionData)[indexPath.row]["site"]["name"].stringValue
        if address == "" {
            let otherAddress = JSON(self.sessionData)[indexPath.row]["otherLocation"].stringValue
            address = otherAddress
        }
        cell.addressLabel.text = address
        let clients = JSON(self.sessionData)[indexPath.row]["clients"].arrayValue as NSArray
        allTags.removeAll()
        if clients.count == 0{
//            let clientName = JSON(self.sessionData)[indexPath.row]["client"]["fullName"].stringValue
//
//            allTags.append(clientName)
//            cell.nameTagsView.tag = JSON(self.sessionData)[indexPath.row]["client"]["id"].intValue
            //            self.nametagFlowHeightConstraint?.constant = 75
//            cell.layoutIfNeeded()
            let description = JSON(self.sessionData)[indexPath.row]["description"].stringValue
            let sessionType = JSON(self.sessionData)[indexPath.row]["sessionType"].stringValue
            if description == "" {
                allTags.append(sessionType)
            }else{
                allTags.append(description)
            }
            
        }else{
            
            for (value) in clients {
                let clientNames = JSON(value)["fullName"].stringValue
                allTags.append(clientNames)
            }

        }
        cell.nameTagsView.removeAllTags()
        cell.nameTagsView.addTags(allTags)
        
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("tapped")
        self.view.isUserInteractionEnabled = false
        self.hud.show(in: self.view)
        let sessionUsers = JSON(self.sessionData)[indexPath.row]["sessionUsers"].arrayValue as NSArray
        for (value) in sessionUsers {
            let userId = JSON(value)["id"].intValue
            print(userId)
            careKernelDefaults.set(userId, forKey: kUserId)
        }
        let sessionId = JSON(self.sessionData)[indexPath.row]["id"].intValue
        presentStoryboard(segue: "segueToSessionDetails", sender: sessionId)
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 220
        
    }
    
    private func createSpinnerFooter() -> UIView {
        let footerView = UIView(frame: CGRect(x: 0, y: 0, width: eventsTableView.frame.size.width, height: 100))
        let spinner = UIActivityIndicatorView()
        spinner.center = footerView.center
        spinner.color = #colorLiteral(red: 0.2196078449, green: 0.007843137719, blue: 0.8549019694, alpha: 1)
        footerView.addSubview(spinner)
        spinner.startAnimating()
        
        return footerView
    }
    
    private func removeTableSpinner(viewType : String) {
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            if viewType == "Header"{
                self.eventsTableView.tableHeaderView = nil
            }else {
                self.eventsTableView.tableFooterView = nil
            }
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        if currentPage < totalPage && indexPath.row == self.sessionData.count - 1 {
            currentPage = currentPage + 1
            self.fetchData(page: currentPage, refresh: false)
            let selectedDateString = self.getFormattedDate(date: selectedDate, format: "dd, MMMM, yyyy")
            self.scrollToTop(tabelIndex: indexPath.row, selectedDate: selectedDateString, animated: false)
        }
        
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let position = scrollView.contentOffset.y
        let tableContentSize = eventsTableView.contentSize.height+100-scrollView.frame.size.height
        
        if position > tableContentSize{
            //fetch more data
            
            guard moveToNextWeek else {
                return
            }
            
            self.moveToNextWeek = false
//            self.eventsTableView.tableFooterView = createSpinnerFooter()
//            DispatchQueue.main.async {
////                self.changeWeek(days: 7)
//                self.removeTableSpinner(viewType: "Footer")
//            }
        }
    }
}

extension HomeViewController : TagListViewDelegate {
    
    func tagPressed(_ title: String, tagView: TagView, sender: TagListView) {
        print("Tag pressed: \(title), \(sender.tag)")

        var tappedClientId = Int()
        var clientID = 0
        let clients = NSMutableArray()
        let dataCount = self.sessionData.count
        var ind = dataCount
        
        
        for index in 0...self.sessionData.count-1 {
            ind = dataCount - ind
            let clientCount = JSON(self.sessionData)[index]["clients"].arrayValue
            if clientCount.count > 1 {
                for (i,_) in clientCount.enumerated() {
                    let clID = JSON(self.sessionData)[index]["clients"][i]["id"].intValue
                    if clientID != clID{
                        clientID = clID
                        clients.add(JSON(self.sessionData)[index]["clients"].arrayValue)
                    }
                }
            }else{
            let clID = JSON(self.sessionData)[index]["clients"][0]["id"].intValue
            if clientID != clID{
                clientID = clID
                clients.add(JSON(self.sessionData)[index]["clients"].arrayValue)
            }
            }
            ind = ind - 1
            ind.negate()
        }
        for (i,value) in clients.enumerated() {
            let values = JSON(clients)[i].arrayValue
            for j in 0..<values.count{
                let id = JSON(values)[j]["id"].intValue
                let clientName = JSON(value)[j]["fullName"].stringValue
                if clientName == title {
                    tappedClientId = id
                }
            }
        }
        if tappedClientId != 0{
        careKernelDefaults.set(tappedClientId, forKey: "clientID")
        presentStoryboard(segue: "segueToClientDetails", sender: tappedClientId)
        }
    }
    
}

