//
//  ClientMainViewController.swift
//  CareKernel
//
//  Created by Mohit Sharma on 31/10/21.
//

import UIKit
import SwiftyJSON
import SDWebImage
import Alamofire
import JGProgressHUD

class ClientMainViewController: UIViewController  {
    
    @IBOutlet var menuBar: MenuBarView!
    @IBOutlet var navView: UIView!
    @IBOutlet var viewsCollectionView: UICollectionView!
    @IBOutlet var clientFullName: UILabel!
    @IBOutlet var mobileLabel: UILabel!
    @IBOutlet var clientImageView: UIImageView!
    @IBOutlet var alertsTableView: UITableView!
    @IBOutlet var collectionViewHeightAnchor: NSLayoutConstraint!
    @IBOutlet weak var clientDetailsView: UIView!
    
    var viewControllers = [UIView]()
    var clientId = 0
    var detailsDict: [String:Any] = [:]
    var clientDetailsVM = ClientDetailsViewModel()
    var alerts = NSMutableArray()
    var titleName = ""
    let hud = JGProgressHUD()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //        self.view.isUserInteractionEnabled = false
        //        hud.show(in: self.view)
        print("Passed clientId - \(self.clientId)")
        self.customization()
        self.view.backgroundColor = UIColor(named: "Light Purple Background")
        guard let clientIddefaults = careKernelDefaults.value(forKey: "clientID") as? Int else {
            self.clientId = 25
            return }
        self.clientId = clientIddefaults
        fetchData()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.collectionViewHeightAnchor.constant = viewsCollectionView.contentSize.height
    }
    @IBAction func backButtonAction(_ sender: Any) {
        careKernelDefaults.removeObject(forKey: "incidentsFilterDate")
        self.dismiss(animated: true, completion: nil)
    }
    
    func presentStoryboard(segue: String, sender: Any?){
        //        hud.dismiss()
        //        self.view.isUserInteractionEnabled = true
        DispatchQueue.main.async {
            self.performSegue(withIdentifier: segue, sender: sender)
        }
        
    }
    
    func fetchData(){
        guard let token = careKernelDefaults.value(forKey: kLoginToken) as? String else {
            careKernelDefaults.set(false, forKey: kIsLoggedIn)
            return }
        clientDetailsVM.clientId = self.clientId
        clientDetailsVM.token = token
        clientDetailsVM.getClientDetails(clientID: "\(clientId)", token: token) { response, success in
            if success {
                DispatchQueue.main.async {
                    let dict = JSON(response).dictionaryValue
                    self.detailsDict = dict  as [String : Any]
                    self.updateUI()
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
        }
        
    }
    
    func updateUI(){
        
        let fullName = JSON(self.detailsDict)["fullName"].stringValue
        let mobile = JSON(self.detailsDict)["mobile"].stringValue
        let title = JSON(self.detailsDict)["title"].stringValue
        titleName = title.capitalized + ". " + fullName.capitalized
        let alertArray = JSON(self.detailsDict)["alerts"].arrayValue as NSArray
        careKernelDefaults.set(fullName, forKey: "clientName")
        for value in alertArray{
            self.alerts.add(value)
        }
        //        let alertTitle = alerts[0]["title"].stringValue
        //        print(alertTitle)
        let imageURL = URL(string: "\(JSON(self.detailsDict)["avatarUrl"].stringValue)")
        self.clientImageView.sd_setImage(with: imageURL, placeholderImage: #imageLiteral(resourceName: "icon-basicProfile"))
        
        clientFullName.text = fullName
        if mobile == "" {
            mobileLabel.text = "NA"
        }else{
            mobileLabel.text = mobile
        }
       
        alertsTableView.reloadData()
        
        //        self.viewsCollectionView.scrollToItem(at: IndexPath.init(row: 6, section: 0), at: .centeredHorizontally, animated: true)
        //
        //        DispatchQueue.main.asyncAfter(deadline: .now() + 0.9) {
        //
        //            self.viewsCollectionView.scrollToItem(at: IndexPath.init(row: 0, section: 0), at: .centeredHorizontally, animated: true)
        //            self.view.isUserInteractionEnabled = true
        ////            self.hud.dismiss()
        //        }
        
    }
    func customization(){
        self.view.addSubview(self.menuBar)
        self.menuBar.translatesAutoresizingMaskIntoConstraints = false
        guard let v = self.view else { return }
        let _ = NSLayoutConstraint.init(item: navView ?? v, attribute: .top, relatedBy: .equal, toItem: self.menuBar, attribute: .top, multiplier: 1.0, constant: -100).isActive = true
        let _ = NSLayoutConstraint.init(item: navView ?? v, attribute: .left, relatedBy: .equal, toItem: self.menuBar, attribute: .left, multiplier: 1.0, constant: 0).isActive = true
        let _ = NSLayoutConstraint.init(item: navView ?? v, attribute: .right, relatedBy: .equal, toItem: self.menuBar, attribute: .right, multiplier: 1.0, constant: 0).isActive = true
        self.menuBar.heightAnchor.constraint(equalToConstant: 65).isActive = true
        
        
        let basicVC = self.storyboard?.instantiateViewController(withIdentifier: "ClientBasicDetailsViewController")
        let goalsVC = self.storyboard?.instantiateViewController(withIdentifier: "GoalsViewController")
        let casenotesVC = self.storyboard?.instantiateViewController(withIdentifier: "ClientCaseNotesViewController")
        let healthVC = self.storyboard?.instantiateViewController(withIdentifier: "HealthConditionViewController")
        let incidentsVC = self.storyboard?.instantiateViewController(withIdentifier: "IncidentsViewController")
        let medicinesVC = self.storyboard?.instantiateViewController(withIdentifier: "MedicinesViewController")
        let medicalDetailsVC = self.storyboard?.instantiateViewController(withIdentifier: "MedicalDetailsViewController")
        let risksVC = self.storyboard?.instantiateViewController(withIdentifier: "RiskViewController")
        
        let vcs = [basicVC, casenotesVC, goalsVC, healthVC, incidentsVC, medicalDetailsVC, medicinesVC, risksVC]
        let pagesTitle = careKernelDefaults.value(forKey: "pageTitles") as! [String]
        var compArr = [String]()
        for names in pagesTitle {
            switch names {
            case "Basic Details" :
                compArr.append("ClientBasicDetailsViewController")
                break
            case "Goals" :
                compArr.append("GoalsViewController")
                break
            case "Case Notes" :
                compArr.append("ClientCaseNotesViewController")
                break
            case "Health Conditions" :
                compArr.append("HealthConditionViewController")
                break
            case "Incidents" :
                compArr.append("IncidentsViewController")
                break
            case "Medical Details" :
                compArr.append("MedicalDetailsViewController")
                break
            case "Medications" :
                compArr.append("MedicinesViewController")
                break
            case "Risks" :
                compArr.append("RiskViewController")
                break
            default :
                compArr.append("ClientBasicDetailsViewController")
                break
            }
        }
        var modifiedArray = [UIViewController]()
        for value in vcs {
            let vcClassName = value?.className ?? ""
            if compArr.contains(vcClassName){
                let finalVC = self.storyboard?.instantiateViewController(withIdentifier: vcClassName)
                if modifiedArray.contains(finalVC!){
                    print("Already there")
                }else{
                    
                    modifiedArray.append(finalVC!)
                }
            }
            
        }
        print(modifiedArray)
        for vc in modifiedArray {
            self.addChild(vc)
            vc.didMove(toParent: self)
            
            vc.view.frame = CGRect.init(x: 0, y: 0, width: self.view.bounds.width, height: self.view.bounds.height)
            self.viewControllers.append(vc.view)
        }
        self.viewsCollectionView.reloadData()
        //NotificationCenter setup
        NotificationCenter.default.addObserver(self, selector: #selector(self.scrollViews(notification:)), name: Notification.Name.init(rawValue: "didSelectMenu"), object: nil)
        if let flowLayout = viewsCollectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            flowLayout.minimumLineSpacing = 0
        }
        //        viewsCollectionView.scrollToItem(at: IndexPath.init(row: 5, section: 0), at: .centeredHorizontally, animated: true)
    }
    
    @objc func scrollViews(notification: Notification) {
        if let info = notification.userInfo {
            let userInfo = info as! [String: Int]
            let index = (userInfo["index"] ?? 0) as Int
            if index > 7{
                showAlert("CareKernel", message: "Feature Coming Soon.", actions:["Ok"]) { action in
                    
                }
            }else{
                self.viewsCollectionView.scrollToItem(at: IndexPath.init(row: userInfo["index"]!, section: 0), at: .centeredHorizontally, animated: true)
                
            }
            
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
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

extension NSObject {
    var className: String {
        return String(describing: type(of: self))
    }
    
    class var className: String {
        return String(describing: self)
    }
}

extension ClientMainViewController : UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.viewControllers.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CHVIewCell", for: indexPath)
        cell.contentView.addSubview(self.viewControllers[indexPath.row])
        //        cell.contentView.backgroundColor = UIColor.white
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize.init(width: self.view.bounds.width, height: self.viewsCollectionView.bounds.height)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        let scrollIndex = scrollView.contentOffset.x / 3 
        //        NotificationCenter.default.post(name: Notification.Name.init(rawValue: "scrollMenu"), object: nil, userInfo: ["length": scrollIndex])
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        if scrollView is UICollectionView {
            let tar = targetContentOffset.pointee.x / view.frame.width
            print("index of coll\(tar)")
            let indexPath = IndexPath(item: Int(tar), section: 0)
            menuBar.collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
            menuBar.collectionView.selectItem(at: indexPath, animated: true, scrollPosition: .centeredHorizontally)
            NotificationCenter.default.post(name: Notification.Name.init(rawValue: "scrollMenu"), object: nil, userInfo: ["length": tar])
        }
    }
}

extension ClientMainViewController : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return alerts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "alertCell", for: indexPath) as! AlertCell
        
        let alertName = titleName + " " + JSON(self.alerts)[indexPath.row]["title"].stringValue
        
        cell.alertLabel.text = alertName
        
        return cell
    }
    
    
}

class AlertCell: UITableViewCell {
    
    @IBOutlet var iconImageView: UIImageView!
    @IBOutlet var alertLabel: UILabel!
    
}
