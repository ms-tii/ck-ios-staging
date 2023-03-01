//
//  ProfileViewController.swift
//  CareKernel
//
//  Created by Mohit Sharma on 07/12/21.
//

import UIKit
import SwiftyJSON
import SDWebImage
import JGProgressHUD

class ProfileViewController: UIViewController {
    
    @IBOutlet var profilePicture: UIImageView!
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var nameTextField: UIShowHideTextField!
    @IBOutlet var emailTextField: UIShowHideTextField!
    @IBOutlet var phoneTextField: UIShowHideTextField!
    
    
    var userName = String()
    var params = [String:String]()
    var isPicChanged = Bool()
    var isNameChanged = Bool()
    let hud = JGProgressHUD()

    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        
    }
    
    @IBAction func backButtonAction(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }

    
    @IBAction func changePictureButtoAction(_ sender: UIButton) {
        AttachmentHandler.shared.showAttachmentActionSheet(vc: self)
        AttachmentHandler.shared.imagePickedBlock = { (image) in
            /* get your image here */
            if image.size.width != 0 {
                DispatchQueue.main.async {
                    self.profilePicture.image = image
                    self.isPicChanged = true
                }
            }
        }
    }
    
    @IBAction func updateButtonAction(_ sender: UIButton) {
        if nameTextField.text != ""{
            hud.show(in: self.view)
            self.view.isUserInteractionEnabled = false
        let nameItems = nameTextField.text?.split(separator: " ")
        var firstName = ""
        var lastName = ""
        if nameItems?.count != 0{
            
            firstName = String(nameItems![0])
            
            for n in 1...nameItems!.count - 1 {
                lastName = lastName + nameItems![n]
            }
            print(lastName)
        }
        if isPicChanged && isNameChanged {
            
            let isCalled = callToUpdateApi(firstName: String(firstName),lastName: lastName)
            if isCalled {
                callToProfilePicApi()
            }
        }else if isPicChanged {
            callToProfilePicApi()
        }else if isNameChanged {
            
            let isCalled = callToUpdateApi(firstName: String(firstName),lastName: lastName)
            
            }
        }else{
            self.showAlert("Alert!", message: "Name cannot be empty.", actions: ["Ok"]) { actionTitle in

            }
        }
    }
    
    func configureUI(){
        DispatchQueue.main.async {
            self.profilePicture.layer.cornerRadius = self.profilePicture.bounds.width / 2
            self.nameTextField.delegate = self
            self.nameTextField.setCorner(radius: 8)
            self.emailTextField.setCorner(radius: 8)
            self.phoneTextField.setCorner(radius: 8)
            self.nameTextField.setLeftPaddingPoints(16)
            self.emailTextField.setLeftPaddingPoints(16)
            self.phoneTextField.setLeftPaddingPoints(16)
            let userName = JSON(self.params)["userName"].stringValue
            let userEmail = JSON(self.params)["email"].stringValue
            let userPhone = JSON(self.params)["phone"].stringValue
            let imageString = JSON(self.params)["imageURL"].stringValue
//            let ImageURL = URL(string: imageString)
//            self.profilePicture.sd_imageIndicator = SDWebImageActivityIndicator.grayLarge
            if let cachedImageString = careKernelDefaults.value(forKey: "workerProfilePic") as? String {
                self.profilePicture.downloadImage(url: cachedImageString)
                 }else{
                     self.profilePicture.downloadImage(url: imageString)
                }
            
            self.nameLabel.text = userName
            self.nameTextField.text = userName
            self.emailTextField.text = userEmail
            self.phoneTextField.text = userPhone
        }
        
    }
    
    func callToUpdateApi(firstName: String, lastName: String) -> Bool{
        var profileVM = ProfileViewModel()
        guard let token = careKernelDefaults.value(forKey: kLoginToken) as? String else {
            careKernelDefaults.set(false, forKey: kIsLoggedIn)
            return false }
        guard  let userId = careKernelDefaults.value(forKey: kUserId) as? Int else { return false}
        profileVM.token = token
        profileVM.workerId = userId
        let nameParams = ["firstName": firstName, "lastName": lastName]
        profileVM.updateName(params: nameParams) { response, success in
            if success {
                self.showAlert("CareKernel", message: "Name updated successfully.", actions: ["Ok"]) { action in
                    self.nameLabel.text = firstName + " " + lastName
                    
                }
            }else{
                let error = JSON(response)["message"].stringValue
                self.showAlert("CareKernel", message: error, actions: ["OK"]) { actionTitle in
                }
            }
            self.hud.dismiss(animated: true)
            self.view.isUserInteractionEnabled = true
        }
        self.isNameChanged = false
        self.isPicChanged = false
        return true
    }
    
    func callToProfilePicApi(){
        var profileVM = ProfileViewModel()
        guard let token = careKernelDefaults.value(forKey: kLoginToken) as? String else {
            careKernelDefaults.set(false, forKey: kIsLoggedIn)
            return }
        guard  let userId = careKernelDefaults.value(forKey: kUserId) as? Int else { return()}
        profileVM.token = token
        profileVM.workerId = userId
        let fileName = "ProfilePictureOf" + "\(userId)"
        let fileData = self.profilePicture.image?.jpegData(compressionQuality: 0.3)
        profileVM.uploadPicture(fileName: fileName, fileData: fileData   ?? Data()) { success in
            if success {
                careKernelDefaults.removeObject(forKey: "workerProfilePic")
                self.showAlert("CareKernel", message: "Picture updated successfully.", actions: ["Ok"]) { action in
                }
            }else{
                self.showAlert("CareKernel", message: "Something went wrong!", actions: ["OK"]) { actionTitle in
                }
            }
            self.hud.dismiss(animated: true)
            self.view.isUserInteractionEnabled = true
            self.isNameChanged = false
            self.isPicChanged = false
        }
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.resignFirstResponder()
        view.endEditing(true)
        
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
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
}
extension ProfileViewController : UITextFieldDelegate{
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == nameTextField{
            self.nameTextField.setBorder(width: 1, color: UIColor(named: "Basic Blue")! )
            
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == nameTextField{
            self.nameTextField.setBorder(width: 0, color: UIColor.clear )
            
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder() // dismiss keyboard
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        isNameChanged = true
        return true
    }
}
