//
//  ViewCommentsViewController.swift
//  CareKernel
//
//  Created by Mohit Sharma on 06/01/22.
//

import UIKit
import SwiftyJSON


class ViewCommentsViewController: UIViewController {

    @IBOutlet var commentsTableView: UITableView!
    @IBOutlet var noRecordsLabel: UILabel!
    var taskId = 0
    var commentsArray = NSMutableArray()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        commentsTableView.register(CasenotesHeaderCell.nib(), forHeaderFooterViewReuseIdentifier: "CasenotesHeaderCell")
        commentsTableView.estimatedRowHeight = 111.0
        commentsTableView.rowHeight = UITableView.automaticDimension
        fetchComments()
        // Do any additional setup after loading the view.
    }
    
    @IBAction func backButtonAction(_ sender: UIButton) {
        self.dismiss(animated: true)
    }
    
    @IBAction func notificationAction(_ sender: UIButton) {
    
        self.performSegue(withIdentifier: "segueToNotification", sender: nil)
    }
    
    func setTableHeader(headerTitle: String){
        let header = UIView(frame: CGRect(x: 0, y: 0, width:commentsTableView.frame.width, height: 70))
        //        header.backgroundColor = .red
        let titleLable = UILabel(frame: CGRect(x: 24, y: 30, width: 200, height: 21))
        titleLable.textColor = UIColor(named: "Basic Blue")
        titleLable.text = headerTitle
        header.addSubview(titleLable)
        let lineLable = UILabel(frame: CGRect(x: 0, y: header.frame.height - 1, width:header.frame.width, height: 1))
        lineLable.backgroundColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
        header.addSubview(lineLable)
        commentsTableView.tableHeaderView = header
    }
    
    func fetchComments(){
        
        commentsArray.removeAllObjects()
        var taskDetailsVM = TaskDetailsViewModel()
        guard let token = careKernelDefaults.value(forKey: kLoginToken) as? String else {
            careKernelDefaults.set(false, forKey: kIsLoggedIn)
            
            return }
        taskDetailsVM.token = token
        taskDetailsVM.taskId = taskId
        taskDetailsVM.getTaskComments { response, success in
            if success {
                DispatchQueue.main.async {
                    let tempArray = JSON(response)["data"].arrayValue
                    if tempArray.count != 0 {
                        self.noRecordsLabel.isHidden = true
                        for value in tempArray {
                            self.commentsArray.add(value)
                        }
                       
                        self.commentsTableView.reloadData()
                    }else{
                        self.noRecordsLabel.isHidden = false
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
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
extension ViewCommentsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
            return UITableView.automaticDimension
        }

    func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
            return 66.0
        }
    

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let cell = tableView.dequeueReusableHeaderFooterView(withIdentifier: "CasenotesHeaderCell") as? CasenotesHeaderCell else {
          return nil
          }
        cell.headerTitleLabel.text = "Comments"
        cell.iconImageView.image = UIImage(named: "icon-comments")
        
          return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let descriptionString = JSON(commentsArray)[indexPath.row]["description"].stringValue
        let height:CGFloat = self.calculateHeight(inString: descriptionString)
        return height + 60.0
    }

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return commentsArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CommentsCell", for: indexPath) as! CommentsCell
        cell.userNameLabel.text = JSON(commentsArray)[indexPath.row]["creator"]["fullName"].stringValue
        let createDate = JSON(self.commentsArray)[0]["createdAt"].stringValue
        cell.dateLabel.text = self.getFormattedDate(date: self.iso860ToString(dateString: createDate), format: "dd/MM/yyyy hh:mm a")
        cell.commentLabel.text = JSON(commentsArray)[indexPath.row]["description"].stringValue
        cell.preservesSuperviewLayoutMargins = false
        cell.separatorInset = UIEdgeInsets.zero
        cell.layoutMargins = UIEdgeInsets.zero
        return cell
    }
    
   
    
}

class CommentsCell: UITableViewCell {
    @IBOutlet var userNameLabel: UILabel!
    @IBOutlet var dateLabel: UILabel!
    @IBOutlet var commentLabel: UILabel!
}
