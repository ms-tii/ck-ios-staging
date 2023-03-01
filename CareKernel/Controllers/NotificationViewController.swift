//
//  NotificationViewController.swift
//  CareKernel
//
//  Created by Mohit Sharma on 30/08/21.
//

import UIKit
import SwiftyJSON

class NotificationViewController: UIViewController {

    @IBOutlet var tableView: UITableView!
    @IBOutlet var noNotificationLabel: UILabel!
    
    var notificationArray = NSMutableArray()

    override func viewDidLoad() {
        super.viewDidLoad()
        if #available(iOS 15.0, *) {
            tableView.sectionHeaderTopPadding = 0
        }
        tableView.delegate = self
        tableView.dataSource = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.pushNotificationUpdate(notification:)), name: Notification.Name.init(rawValue: "pushNotificationUpdate"), object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        noNotificationLabel.isHidden = true
        fetchData()
    }
    @IBAction func backButtonAction(_ sender: UIButton) {
        
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func pushNotificationUpdate(notification: Notification) {
        fetchData()
        
    }
    
    func fetchData(){
        notificationArray.removeAllObjects()
        var notificationVM = NotificationViewModel()
        guard let token = careKernelDefaults.value(forKey: kLoginToken) as? String else {
            careKernelDefaults.set(false, forKey: kIsLoggedIn)
            return }
        notificationVM.token = token
        notificationVM.getNotificationList() { response, success in
            if success {
                DispatchQueue.main.async {
                    let tempArray = JSON(response)["data"].arrayValue
                    print(tempArray)
                    if tempArray.count != 0 {
                        self.noNotificationLabel.isHidden = true
                        careKernelDefaults.set(true, forKey: "isNotificationAvailable")
                        for value in tempArray {
                            self.notificationArray.add(value)
                        }
                        self.tableView.isHidden = false
                        self.tableView.reloadData()
                    }else{
                        self.tableView.isHidden = true
                        self.noNotificationLabel.isHidden = false
                        careKernelDefaults.set(false, forKey: "isNotificationAvailable")
                        self.tableView.reloadData()
                    }
                }
            }else{
                
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
    
    func deleteNotification(indexNo: Int, notificationId: Int){
        print(indexNo)
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
    
    func updateNotificationStatus(indexNo: Int, notificationId: Int){
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
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? TaskDetailsViewController {
            vc.taskID = sender as! Int
        }else if let vc = segue.destination as? SessionsViewController {
            vc.sessionId = sender as! Int
        }else if let vc = segue.destination as? ClientMainViewController {
            vc.clientId = sender as! Int
        }
    }
    

}

extension NotificationViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return CGFloat.leastNonzeroMagnitude
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 115.0
      }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notificationArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NotificationCell", for: indexPath) as! NotificationCell
        let createDate = JSON(self.notificationArray)[indexPath.row]["createdAt"].stringValue
        cell.dateLabel.text = self.getFormattedDate(date: self.iso860ToString(dateString: createDate), format: "dd, MMMM, yyyy hh:mm a")
        
        cell.titleLabel.text = JSON(notificationArray)[indexPath.row]["titlePlainText"].stringValue
        cell.preservesSuperviewLayoutMargins = false
        cell.separatorInset = UIEdgeInsets.zero
        cell.layoutMargins = UIEdgeInsets.zero
        return cell
    }
    
        func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
            let swipeAction = UIContextualAction(style: .normal, title: "Delete") { [weak self] (action, view, completionHandler) in
                let notificationId = JSON(self?.notificationArray)[indexPath.row]["id"].intValue
                self?.deleteNotification(indexNo: indexPath.row, notificationId: notificationId)
                completionHandler(true)
            }
            swipeAction.backgroundColor = UIColor.red
            return UISwipeActionsConfiguration(actions: [swipeAction])
        }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let entityType = JSON(notificationArray)[indexPath.row]["entityType"].stringValue
        let entityId = JSON(notificationArray)[indexPath.row]["entityId"].intValue
        let notificationId = JSON(self.notificationArray)[indexPath.row]["id"].intValue
        self.deleteNotification(indexNo: indexPath.row, notificationId: notificationId)
        switch entityType {
        case "SESSION":
            self.performSegue(withIdentifier: "segueToSessionView", sender: entityId)
            break
        case "INQUIRY":
            
            break
        case "CLIENT":
            self.performSegue(withIdentifier: "segueToClientDetails", sender: entityId)
            break
        case "TASK":
            self.performSegue(withIdentifier: "segueToTaskDetails", sender: entityId)
            break
        default:
            break
        }
        
        
    }
}

class NotificationCell: UITableViewCell {
    @IBOutlet var dateLabel: UILabel!
    @IBOutlet var titleLabel: UILabel!
}
