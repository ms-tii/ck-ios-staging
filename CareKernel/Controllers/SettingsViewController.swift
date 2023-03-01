//
//  SettingsViewController.swift
//  CareKernel
//
//  Created by Mohit Sharma on 30/08/21.
//

import UIKit
import SwiftyJSON
import SDWebImage

class SettingsViewController: UIViewController, UNUserNotificationCenterDelegate {

    @IBOutlet var userEmailLabel: UILabel!
    @IBOutlet var userNameLabel: UILabel!
    @IBOutlet var profileImageView: UIImageView!
    @IBOutlet var tableView: UITableView!
    @IBOutlet var changePasswordButton: UIButton!
    @IBOutlet var notificationButton: ButtonWithProperty!
    
    @IBOutlet weak var topBarContainer: UIView!
    
    var phoneString = String()
    var imageString = String()
    var isImageCached = Bool()
    override func viewDidLoad() {
        super.viewDidLoad()
//        tableView.reloadData()
        profileImageView.layer.cornerRadius = profileImageView.bounds.width / 2
        changePasswordButton.layer.cornerRadius = 20
        changePasswordButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: (self.changePasswordButton.bounds.width - 40), bottom: 0, right: 0)
        notificationButton.isBadgeShow = true
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let bundleID = Bundle.main.bundleIdentifier
        
        super.viewWillAppear(animated)
        if let imageString = careKernelDefaults.value(forKey: "workerProfilePic") as? String {
                isImageCached = true
            self.profileImageView.downloadImage(url: imageString)
            self.imageString = imageString
             }else{
                isImageCached = false
            }
        
        fetchData()
        guard  let isNotificationAvailable = careKernelDefaults.value(forKey: "isNotificationAvailable") as? Bool else { return()}
        if isNotificationAvailable {
            notificationButton.isRead = false
        }else{
            notificationButton.isRead = true
        }
    }
    
    func logoutButtonAction() {
        self.dismiss(animated: false) {
            
        }
        callNotificatioOnOff(isFcmEnable: false)
        careKernelDefaults.set(false, forKey: kIsLoggedIn)
        careKernelDefaults.set("", forKey: kUserEmailId)
        careKernelDefaults.set("", forKey: kLoginToken)
        careKernelDefaults.removeObject(forKey: "workerProfilePic")
        careKernelDefaults.removeObject(forKey: "pageTitles")
        Storage.remove("appData.json", from: .documents)
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let loginNavController = storyboard.instantiateViewController(identifier: "loginViewController")

            (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.changeRootViewController(loginNavController)
        tableView.tableFooterView = UIView()
    }
    
    @IBAction func changePasswordAction(_ sender: UIButton) {
        presentStoryboard(segue: "segueToChangePassword", sender: nil)
    }
    @IBAction func notificationButtonAction(_ sender: UIButton) {
        presentStoryboard(segue: "segueToNotification", sender: nil)
    }
    
    func fetchData(){
        var profileVM = ProfileViewModel()
        guard let token = careKernelDefaults.value(forKey: kLoginToken) as? String else {
            careKernelDefaults.set(false, forKey: kIsLoggedIn)
            return }
        guard let workerId = careKernelDefaults.value(forKey: kUserId) as? Int else {
            
            careKernelDefaults.set(false, forKey: kIsLoggedIn)
            careKernelDefaults.set(false, forKey: kIsLoggedIn)
            careKernelDefaults.set("", forKey: kUserEmailId)
            careKernelDefaults.set("", forKey: kLoginToken)
            careKernelDefaults.removeObject(forKey: "workerProfilePic")
            self.presentStoryboard(segue: "segueToLogin", sender: nil)
            return }
        profileVM.token = token
        profileVM.workerId = workerId
        profileVM.getWorkerDetails { response, success in
            if success {
                
                self.setUI(dataDict: response)
            }else{
                let statusCode = JSON(response)["statusCode"].intValue
                let message = JSON(response)["message"].stringValue
                if statusCode == 401 && message == "Unauthorized" {
                    careKernelDefaults.set(false, forKey: kIsLoggedIn)
                    careKernelDefaults.set("", forKey: kUserEmailId)
                    careKernelDefaults.set("", forKey: kLoginToken)
                    careKernelDefaults.removeObject(forKey: "workerProfilePic")
                self.presentStoryboard(segue: "segueToLogin", sender: nil)
                }
            }
        }
    }
    
    func setUI(dataDict: Any){
        print(JSON(dataDict)["fullName"].stringValue)
        
        if !isImageCached {
            imageString = JSON(dataDict)["avatarUrl"].stringValue
            careKernelDefaults.set(imageString, forKey: "workerProfilePic")
            self.profileImageView.downloadImage(url: imageString)
        }else{
            let oldImage = self.profileImageView.image
            let fetchedImage = UIImageView()
            let fetchedUrl = JSON(dataDict)["avatarUrl"].stringValue
            fetchedImage.downloadImage(url: fetchedUrl)
            
            if let oldImage = oldImage, oldImage.isEqual(fetchedImage.image){
                print("same")
            }else{
                print("differ")
                careKernelDefaults.set(fetchedUrl, forKey: "workerProfilePic")
                self.profileImageView.downloadImage(url: imageString)
            }
            
        }
//        let ImageURL = URL(string: imageString)
//        self.profileImageView.sd_imageIndicator = SDWebImageActivityIndicator.grayLarge
//        self.profileImageView.downloadImage(url: imageString)
        self.userNameLabel.text = JSON(dataDict)["fullName"].stringValue.capitalized
        self.userEmailLabel.text = JSON(dataDict)["email"].stringValue
        self.phoneString = JSON(dataDict)["mobile"].stringValue
    
    }
    
    func presentStoryboard(segue: String, sender: Any?){
//        hud.dismiss()
//        self.view.isUserInteractionEnabled = true
        DispatchQueue.main.async {
            self.performSegue(withIdentifier: segue, sender: sender)
        }
        
    }
    @objc func switchTriggered(sender: UISwitch) {
        print(sender.tag)
        
        if(sender.isOn){
                UIApplication.shared.registerForRemoteNotifications()
            checkPermission { isPermissionOn in
                        DispatchQueue.main.async {
                            if isPermissionOn == false {
                                //It's off
                                if let bundle = Bundle.main.bundleIdentifier,
                                    let settings = URL(string: UIApplication.openSettingsURLString + bundle) {
                                    if UIApplication.shared.canOpenURL(settings) {
                                        UIApplication.shared.open(settings)
                                    }
                                }
                            }
                        }
                    }
            callNotificatioOnOff(isFcmEnable: true)
            }
            else{
                UIApplication.shared.unregisterForRemoteNotifications()
                callNotificatioOnOff(isFcmEnable: false)
                
            }
        
    }
    
    func callNotificatioOnOff(isFcmEnable: Bool){
        var loginViewModel = UserLoginViewModel()
        guard let fcmToken = careKernelDefaults.value(forKey: "FCMToken") as? String else {
            careKernelDefaults.set(false, forKey: kIsLoggedIn)
            return }
        let params : [String: Any] = ["deviceId":fcmToken,"isFcmEnable":isFcmEnable]
        loginViewModel.logoutCall(param: params) { response, success in
            if success {
                print("sucess with isFcmEnable - \(isFcmEnable)")
                careKernelDefaults.set(isFcmEnable, forKey: "isFcmEnable")
                let indexPath = IndexPath(row: 1, section: 0)
                self.tableView.reloadRows(at: [indexPath], with: .none)
            }
        }
    }
    
    func checkPermission(completion: @escaping (_ isCameraPermissionOn: Bool) -> ()) {
            let current = UNUserNotificationCenter.current()
            current.getNotificationSettings(completionHandler: { permission in
                switch permission.authorizationStatus  {
                case .authorized:
                    //If user allow the permission
                    completion(true)
                case .denied:
                    //If user denied the permission
                    completion(false)
                case .notDetermined:
                    //First time
                    current.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
                        if granted {
                            completion(true)
                        } else {
                            completion(false)
                        }
                    }
                case .provisional:
                    // @available(iOS 12.0, *)
                    // The application is authorized to post non-interruptive user notifications.
                    completion(true)
                case .ephemeral:
                    // @available(iOS 14.0, *)
                    // The application is temporarily authorized to post notifications. Only available to app clips.
                    completion(true)
                @unknown default:
                    print("Unknow Status")
                }
            })
        }
    // MARK: - Navigation

     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
         
         if let vc = segue.destination as? ProfileViewController {
             vc.params = sender as! [String:String]
         } else if let vc = segue.destination as? WebViewController {
             vc.params = sender as! [String:String]
         }
     }
    
}

extension SettingsViewController : UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        2
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
            return UITableView.automaticDimension
        }

    func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
            return 44.0
        }
    

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//        let cell = UITableViewCell(style: .value1, reuseIdentifier: "Cell")
        let headerView = UIView()
        let titleLabel = UILabel()
        titleLabel.textColor = UIColor(named: "Client Profile text font")
        titleLabel.frame = CGRect(x: 10, y: 10, width: tableView.frame.width, height: 20)
        if section == 0 {
//            cell.textLabel?.text = "Settings"
            titleLabel.text = "SETTINGS"
        }else{
//            cell.textLabel?.text = "More Links"
            titleLabel.text = "MORE LINKS"
        }
//        cell.textLabel?.textColor = UIColor(named: "Client Profile text font")
        
        headerView.backgroundColor = UIColor(named: "Light Purple Background")
        headerView.addSubview(titleLabel)
          return headerView
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 2
        }else{
            return 3
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SettingsCell", for: indexPath) as! SettingsCell
        cell.clipsToBounds = true
        
        if indexPath.section == 0 {
            if indexPath.row == 0{
                cell.layer.cornerRadius = 8
                cell.iconImage.image = UIImage(named: "icon-profile")
                cell.nameLabel.text = "Profile"
                cell.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
                cell.accessoryView?.backgroundColor = .blue
            }else{
                let isFcmEnable = careKernelDefaults.value(forKey: "isFcmEnable") as? Bool
                cell.iconImage.image = UIImage(named: "icon-notifications")
                cell.nameLabel.text = "Notification"
                cell.layer.cornerRadius = 8
                cell.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
                let lightSwitch = UISwitch(frame: CGRect.zero) as UISwitch
                lightSwitch.isOn = isFcmEnable!
                if isFcmEnable! == true{
                    lightSwitch.onTintColor = .white
                    lightSwitch.thumbTintColor = .green
                    lightSwitch.layer.borderWidth = 1
                    lightSwitch.layer.borderColor = UIColor.lightGray.cgColor
                    lightSwitch.layer.cornerRadius = 16
                }else{
                    lightSwitch.onTintColor = .white
                    lightSwitch.thumbTintColor = .white
                    lightSwitch.layer.borderWidth = 1
                    lightSwitch.layer.borderColor = UIColor.lightGray.cgColor
                    lightSwitch.layer.cornerRadius = 16
                }
                
//                    lightSwitch.addTarget(self, action: #selector(switchTriggered), forControlEvents: .ValueChanged)
                lightSwitch.addTarget(self, action: #selector(switchTriggered(sender:)), for: .valueChanged)
                lightSwitch.tag = indexPath.row
                    cell.accessoryView = lightSwitch
            }
        
        }else {
            if indexPath.row == 0 {
                cell.layer.cornerRadius = 8
                cell.iconImage.image = UIImage(named: "icon-about")
                cell.nameLabel.text = "About"
                cell.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
            }else if indexPath.row == 1 {
                cell.iconImage.image = UIImage(named: "icon-help")
                cell.nameLabel.text = "Help"
            }else if indexPath.row == 2 {
                cell.iconImage.image = UIImage(named: "icon-logout")
                cell.nameLabel.text = "Logout"
                cell.layer.cornerRadius = 8
                cell.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
                cell.accessoryType = .none
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            if indexPath.row == 0{
                let userName = userNameLabel.text
                let email = userEmailLabel.text
                
                let param : [String:String] = ["userName": userName!, "email": email!, "phone": phoneString, "imageURL": imageString]
                self.performSegue(withIdentifier: "segueToProfile", sender: param)
            }
        }else {
            if indexPath.row == 0 {
                let param : [String:String] = ["urlString": aboutURL, "title": "About"]
                presentStoryboard(segue: "segueToWebview", sender: param)
            }else if indexPath.row == 1 {
                let param : [String:String] = ["urlString": helpURL, "title": "Help"]
                presentStoryboard(segue: "segueToWebview", sender: param)
                
            }else if indexPath.row == 2 {
                self.logoutButtonAction()
            }
        }
    }
    
    
}

class SettingsCell : UITableViewCell {
    
    @IBOutlet var iconImage: UIImageView!
    @IBOutlet var nameLabel: UILabel!
}
extension UIImageView{
    func downloadImage(url:String){
      //remove space if a url contains.
        let stringWithoutWhitespace = url.replacingOccurrences(of: " ", with: "%20", options: .regularExpression)
        self.sd_imageIndicator = SDWebImageActivityIndicator.gray
        self.sd_setImage(with: URL(string: stringWithoutWhitespace), placeholderImage: UIImage(named: "icon-profile-setting"))
    }
}
