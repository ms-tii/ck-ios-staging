//
//  GoalsViewController.swift
//  CareKernel
//
//  Created by Mohit Sharma on 10/05/22.
//

import UIKit
import SwiftyJSON

class GoalsViewController: UIViewController {

    @IBOutlet var goalTableView: UITableView!
    @IBOutlet var noRecordsLabel: UILabel!
    
    
    var clientDetailsVM = ClientDetailsViewModel()
    var clientId = 0
    var goalsArray = NSMutableArray()
    var objectivesArray = NSMutableArray()
    var selectedIndex = 0
    var numberOfRows = 0
    var isCellCollapc = Bool()
    var tempTableHeight = 0.0
    var tempTableWidth = 0.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        noRecordsLabel.isHidden = true
        
        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        refreshTableView()
        clientId = careKernelDefaults.value(forKey: "clientID") as! Int
        DispatchQueue.main.asyncAfter(deadline: .now() + 0) {
            self.fetchData()
        }
    }
    
    override func viewDidLayoutSubviews(){
            super.viewDidLayoutSubviews()
        let tableHeight = self.goalTableView.frame.height
        let viewHeight = self.view.frame.height
        tempTableHeight = viewHeight - tableHeight
        let framWidth = self.view.frame.width
        tempTableWidth = framWidth
        var frame = self.goalTableView.frame
        switch UIDevice().type {
            
        case .iPhone5, .iPhone5C, .iPhone5S, .iPhoneSE :
            frame.size.height = frame.size.height - 60
            frame.size.width = frame.size.width + 95
        case .iPhoneSE2, .iPhone6, .iPhone6S, .iPhone7, .iPhone8 :
            frame.size.height = frame.size.height - 60
            frame.size.width = frame.size.width + 40
        case .iPhone6SPlus, .iPhone7Plus, .iPhone8Plus :
            frame.size.height = frame.size.height - 55
            break
        case .iPhone11, .iPhoneXR  :
//            frame.size.height = frame.size.height + 200
//            frame.size.width = frame.size.width + 42
            break
        case .iPhone11Pro, .iPhoneXS  :
            frame.size.width = frame.size.width + 42
            break
        case .iPhone12, .iPhone12Pro, .iPhone13Pro, .iPhone13  :
            frame.size.width = frame.size.width + 24
            break
        case .iPhone12Mini, .iPhone13Mini  :
            frame.size.height = frame.size.height - 55
            frame.size.width = frame.size.width + 40
            break
        case .iPhone12ProMax, .iPhone13ProMax  :
            frame.size.width = frame.size.width - 14
            break
        default: break
        }
        self.goalTableView.frame = frame
    }
    
    func refreshTableView(){
        self.goalTableView.refreshControl = UIRefreshControl()
        self.goalTableView.refreshControl?.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        
    }
    
    @objc private func refreshData(){
        print("Refreshed")
        self.fetchData()
    }
    
    func fetchData(){
        goalsArray.removeAllObjects()
        guard let token = careKernelDefaults.value(forKey: kLoginToken) as? String else {
            careKernelDefaults.set(false, forKey: kIsLoggedIn)
            return }
        clientDetailsVM.getClientGoals(clientID: "\(clientId)", token: token) { response, success in
            if success {
                DispatchQueue.main.async {
                    let tempArray = JSON(response)["data"].arrayValue
//                    tempArray.sort(by: ({$0["id"] < $1["id"]}))
                    if tempArray.count != 0 {
                        for value in tempArray {
                            self.goalsArray.add(value)
                        }
                                                
                        self.goalTableView.reloadData()
                    }else{
                        self.noRecordsLabel.isHidden = false
                    }
                }
            }else{
                
            }
            self.goalTableView.refreshControl?.endRefreshing()
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        print(segue.destination)
        if let vc = segue.destination as? ObjectivesViewController {
            vc.objectiveDetails = sender as! [String: Any]
        }
    }
}

extension GoalsViewController : UITableViewDelegate, UITableViewDataSource, GoalsCellDelegate {


    func goalsObjectiveCelltapped(_ data: [String:Any]) {
       
        self.performSegue(withIdentifier: "segueToObjectives", sender: data)
    }
    

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == selectedIndex && isCellCollapc == true{
            return 370
        }else{
            return 63
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return goalsArray.count

    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "GoalsCell", for: indexPath) as! GoalsCell
        let displayId = JSON(goalsArray)[indexPath.row ]["displayId"].stringValue
        let name = JSON(goalsArray)[indexPath.row ]["name"].stringValue
        let description = JSON(goalsArray)[indexPath.row ]["description"].stringValue
        let startDate = JSON(goalsArray)[indexPath.row ]["startDate"].stringValue
        let endDate = JSON(goalsArray)[indexPath.row ]["endDate"].stringValue
        let reviewDate = JSON(goalsArray)[indexPath.row ]["reviewDate"].stringValue
        let isArchived = JSON(goalsArray)[indexPath.row ]["isArchived"].boolValue
        cell.parentViewController = self
        cell.delegate = self
        cell.titleLabel.text = displayId + " : " + name.capitalized
        cell.descriptionLabel.text = description
        let startDateString = getFormattedDate(date: iso860ToString(dateString: startDate), format: "dd/MM/yyyy")
        let endDateString = getFormattedDate(date: iso860ToString(dateString: endDate), format: "dd/MM/yyyy")
        cell.startDateLabel.text = startDateString
        cell.endDateLabel.text = endDateString
        if reviewDate == "" {
            cell.reviewDateLabel.text = "NA"
        }else{
            let reviewDateString = getFormattedDate(date: iso860ToString(dateString: reviewDate), format: "dd/MM/yyyy")
            cell.reviewDateLabel.text = reviewDateString
        }
        if isArchived {
            cell.achievedLabel.text = "Yes"
        }else {
            cell.achievedLabel.text = "No"
        }
        let objectivesArr = JSON(goalsArray)[indexPath.row]["goalObjectives"].arrayValue
        print(objectivesArr)
//        objectivesArr.sort(by: ({$0["id"] < $1["id"]}))
        cell.objectArr.removeAllObjects()
        if objectivesArr.count > 0 {
           
            for item in objectivesArr {
                cell.objectArr.add(item)
                objectivesArray.add(item)
            }
            
            cell.objectivesDetailsArray = cell.objectArr
            cell.objectiveCollectionView.isHidden = false
            cell.noRecordsLabel.isHidden = true
        }else{
            cell.noRecordsLabel.isHidden = false
            cell.objectiveCollectionView.isHidden = true
        }
        
//        cell.clipsToBounds = true
        cell.layer.cornerRadius = 8
//        cell.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
//        cell.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]

//        if indexPath.row == selectedIndex && isCellCollapc == true {
//
//        }else{
//
//
//        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if selectedIndex == indexPath.row{
            if !isCellCollapc {
                
                isCellCollapc = true
            }else{
                isCellCollapc = false
            }
        }else{
            isCellCollapc = true
        }
        selectedIndex = indexPath.row
        goalTableView.reloadRows(at: [indexPath], with: .automatic)
        
        self.goalTableView.scrollToRow(at: indexPath,
                                                 at: .top,
                                                 animated: true)
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {

        
    }
}

protocol GoalsCellDelegate: AnyObject {
    func goalsObjectiveCelltapped(_ data: [String:Any])
}
class GoalsCell : UITableViewCell, UICollectionViewDataSource, UICollectionViewDelegate{
    
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var startDateLabel: UILabel!
    @IBOutlet weak var endDateLabel: UILabel!
    @IBOutlet weak var reviewDateLabel: UILabel!
    @IBOutlet weak var achievedLabel: UILabel!
    @IBOutlet weak var objectiveCollectionView: UICollectionView!
    @IBOutlet weak var noRecordsLabel: UILabel!
    
    weak var delegate: GoalsCellDelegate?
    var parentViewController: UIViewController? = nil
    var objectArr = NSMutableArray()
    var objectivesDetailsArray : NSMutableArray = [] {
        didSet {
            print(objectivesDetailsArray.count)
            parentViewController = GoalsViewController()
            self.objectiveCollectionView.dataSource = self
            self.objectiveCollectionView.delegate = self
            self.objectiveCollectionView.reloadData()
        }
    }

    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        objectivesDetailsArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "GoalsObjectiveCell", for: indexPath as IndexPath) as! GoalsObjectiveCell
        let displayID = JSON(objectivesDetailsArray)[indexPath.row]["displayId"].stringValue
        print(displayID)
        cell.objectiveName.text = "Objective : " + displayID
        cell.clipsToBounds = true
        cell.layer.cornerRadius = 8
        cell.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let objectiveValues = JSON(objectivesDetailsArray)[indexPath.row].dictionaryValue
        print(objectiveValues)
        delegate?.goalsObjectiveCelltapped(objectiveValues)
        

    }
}

class GoalsObjectiveCell : UICollectionViewCell{
    
    @IBOutlet weak var objectiveName: UILabel!
    
    
}

