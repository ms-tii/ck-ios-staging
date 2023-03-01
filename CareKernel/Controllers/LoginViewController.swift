//
//  LoginTableViewController.swift
//  CareKernel
//
//  Created by Mohit Sharma on 09/09/21.
//

import UIKit
import JGProgressHUD
import SwiftyJSON

class LoginViewController: UITableViewController {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UIShowHideTextField!
    
    private var loginViewModel = UserLoginViewModel()
    let hud = JGProgressHUD()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    func configureUI(){
        DispatchQueue.main.async {
            let bundleID = Bundle.main.bundleIdentifier
            print(bundleID!)
            if bundleID == "it.conversant.carekernelstaging" {
                self.showAlert("CareKernel Staging", message: "This is the staging version of app.", actions: ["Ok"]) { success in
                    
                }
            }
            self.hud.contentView.backgroundColor = #colorLiteral(red: 0.1529411765, green: 0.2274509804, blue: 0.8078431373, alpha: 0.1175952431)
            self.emailTextField.delegate = self
            self.passwordTextField.delegate = self
            self.emailTextField.setCorner(radius: 8)
            self.passwordTextField.setCorner(radius: 8)
            
            self.emailTextField.setLeftPaddingPoints(16)
            self.passwordTextField.setLeftPaddingPoints(16)
        }
        
    }
    
    @IBAction func loginButtonAction(_ sender: UIButton) {
      
        self.view.isUserInteractionEnabled = false
        hud.show(in: self.view)
        loginViewModel.email = self.emailTextField.text
        loginViewModel.password = self.passwordTextField.text
        var isFcmEnable = Bool()
        if let isHaveValue = careKernelDefaults.value(forKey: "isFcmEnableForLogin") as? Bool {
            isFcmEnable = isHaveValue
            loginViewModel.isFcmEnable = isFcmEnable
            if let fcmToken = careKernelDefaults.value(forKey: "FCMToken") as? String {
                loginViewModel.fcmToken = fcmToken
            }else{
                print("NO FCM TOKEN")
            }
        }else{
            print("not allowed notifications")
        }
        
        loginViewModel.isLoginDetailsValid { success, errorMessage in
            if success {
                self.callToApi(isNotificationAllowed: isFcmEnable)
            }else{
                self.view.isUserInteractionEnabled = true
                hud.dismiss()
                self.showAlert("Error!", message: errorMessage!, actions: ["OK"]) { actionTitle in
                    
                }
            }
        }
    }
    
    func callToApi(isNotificationAllowed: Bool){
        loginViewModel.loginCall { response in
            
            if response.success{
                print(response)
                careKernelDefaults.set(isNotificationAllowed, forKey: "isFcmEnable")
                DispatchQueue.main.async {
//                self.popAfterSuccessfulLogin()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        
                        self.clientScopePreference()
                    }
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                        let mainTabBarController = storyboard.instantiateViewController(identifier: "MainTabBarController")
                    self.view.isUserInteractionEnabled = true
                    self.hud.dismiss()
                        // This is to get the SceneDelegate object from your view controller
                        // then call the change root view controller function to change to main tab bar
                        (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.changeRootViewController(mainTabBarController)

                }
            }else{
                print(response)
                self.view.isUserInteractionEnabled = true
                self.hud.dismiss()
                let message = response.successMessage
                self.showAlert("Error!", message: message!, actions: ["Ok"]) { (actionTitle) in
                    print(actionTitle)
                }
            }
        }
    }
    
    @IBAction func signUpButtonAction(_ sender: UIButton) {
        self.performSegue(withIdentifier: "segueToSignUp", sender: nil)
    }
    
    func clientScopePreference(){
        let messagesFromDisk = Storage.retrieve("appData.json", from: .documents, as: JSON.self)
        var pageTitles = [String]()
        for (key,value) in messagesFromDisk {
            print(key)
            let access = JSON(value)["access"].boolValue
            if access {
                switch key {
                case "Basic Details":
                    pageTitles.insert("Basic Details", at: 0)
                    
                    break
                default:
                    pageTitles.append(key.capitalized)
                    break
                }
                
            }
        }
        careKernelDefaults.set(pageTitles, forKey: "pageTitles")
        print("Pagetitles = \(pageTitles)")
    }
    
    func saveTokenReceived(_ token: String){
        careKernelDefaults.set(token, forKey: kLoginToken)
        kSuccessfullLogin = true
    }
    
    func popAfterSuccessfulLogin() {
        careKernelDefaults.set(true, forKey: kIsLoggedIn)
        self.dismiss(animated: true, completion: nil)
        self.navigationController?.popToRootViewController(animated: true)
//        self.performSegue(withIdentifier: "segueToSignUp", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? codeVerifyViewController {
        vc.verificationType = "signUp"
        }
    }
}

extension LoginViewController : UITextFieldDelegate{
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == emailTextField{
            self.emailTextField.setBorder(width: 1, color: UIColor(named: "Basic Blue")! )

        }else if textField == passwordTextField{
            self.passwordTextField.setBorder(width: 1, color: UIColor(named: "Basic Blue")!)

        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == emailTextField{
            self.emailTextField.setBorder(width: 0, color: UIColor.clear )

        }else if textField == passwordTextField{
            self.passwordTextField.setBorder(width: 1, color: UIColor.clear)

        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            textField.resignFirstResponder() // dismiss keyboard
            return true
        }
}
