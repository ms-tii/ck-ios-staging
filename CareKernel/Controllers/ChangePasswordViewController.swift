//
//  ChangePasswordViewController.swift
//  CareKernel
//
//  Created by Mohit Sharma on 13/12/21.
//

import UIKit
import JGProgressHUD
import SwiftyJSON
class ChangePasswordViewController: UIViewController {

    @IBOutlet var passwordTextField: UIShowHideTextField!
    @IBOutlet var newPassTextField: UIShowHideTextField!
    let hud = JGProgressHUD()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureUI()
    }
    
    @IBAction func backButtonAction(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    @IBAction func updateButtonAction(_ sender: UIButton) {
        if passwordTextField.text == "" {
            showAlert("Warning!", message: "Old Password cannot be empty.", actions: ["Ok"]) { actionTitle in
                
            }
        }else if newPassTextField.text == ""{
            showAlert("Warning!", message: "New Password cannot be empty", actions: ["Ok"]) { actionTitle in
                
            }
        }else{
            self.view.isUserInteractionEnabled = false
            hud.show(in: self.view)
        var changePasswordVM = ChangePasswordViewModel()
        changePasswordVM.oldPassword = passwordTextField.text
        changePasswordVM.newPassword = newPassTextField.text
        guard let workerId = careKernelDefaults.value(forKey: kUserId) as? Int else {
            careKernelDefaults.set(false, forKey: kIsLoggedIn)
            return }
        changePasswordVM.userID = workerId
        
        changePasswordVM.changePassword { response, success in
            self.view.isUserInteractionEnabled = true
            self.hud.dismiss()
            if success {
                
                self.showAlert("CareKernel", message: "Password changed successfully. Please login again with a new Password", actions: ["OK"]) { actionTitle in
                    if actionTitle == "OK"{
                        
                            self.dismiss(animated: false) {
                                
                            }
                            careKernelDefaults.set(false, forKey: kIsLoggedIn)
                            careKernelDefaults.set("", forKey: kUserEmailId)
                            careKernelDefaults.set("", forKey: kLoginToken)
                            let storyboard = UIStoryboard(name: "Main", bundle: nil)
                                let loginNavController = storyboard.instantiateViewController(identifier: "loginViewController")

                                (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.changeRootViewController(loginNavController)
                           
                    }
                }
            }else{
                let error = JSON(response)["message"].stringValue
                self.showAlert("CareKernel", message: error, actions: ["OK"]) { actionTitle in
                }
            }
        }
        }
    }

    
    func configureUI(){
        DispatchQueue.main.async {
            self.hud.contentView.backgroundColor = #colorLiteral(red: 0.1529411765, green: 0.2274509804, blue: 0.8078431373, alpha: 0.1175952431)
            self.passwordTextField.delegate = self
            self.newPassTextField.delegate = self
            self.newPassTextField.setCorner(radius: 8)
            self.passwordTextField.setCorner(radius: 8)
            
            self.newPassTextField.setLeftPaddingPoints(16)
            self.passwordTextField.setLeftPaddingPoints(16)
        }
        
    }
    
    func presentStoryboard(segue: String, sender: Any?){
//        hud.dismiss()
//        self.view.isUserInteractionEnabled = true
        DispatchQueue.main.async {
            self.performSegue(withIdentifier: segue, sender: sender)
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
extension ChangePasswordViewController : UITextFieldDelegate{
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == newPassTextField{
            self.newPassTextField.setBorder(width: 1, color: UIColor(named: "Basic Blue")! )

        }else if textField == passwordTextField{
            self.passwordTextField.setBorder(width: 1, color: UIColor(named: "Basic Blue")!)

        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == newPassTextField{
            self.newPassTextField.setBorder(width: 0, color: UIColor.clear )

        }else if textField == passwordTextField{
            self.passwordTextField.setBorder(width: 1, color: UIColor.clear)

        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            textField.resignFirstResponder() // dismiss keyboard
            return true
        }
}
