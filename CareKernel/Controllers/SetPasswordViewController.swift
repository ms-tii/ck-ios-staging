//
//  SetPasswordViewController.swift
//  CareKernel
//
//  Created by MAC PC on 02/10/21.
//

import UIKit
import SwiftyJSON
import JGProgressHUD

class SetPasswordViewController: UIViewController {
    @IBOutlet weak var passwordTextfield: UIShowHideTextField!
    @IBOutlet weak var setButton: UIButton!
    
    var viewModel = SetPasswordViewModel()
    var verifyResponse = VerifyOTPResponseModel()
    var verificationType = ""
    let hud = JGProgressHUD()

    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        // Do any additional setup after loading the view.
    }
    @IBAction func backButtonAction(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func setButtonAction(_ sender: UIButton) {
        self.view.endEditing(true)
        self.view.isUserInteractionEnabled = false
        hud.show(in: self.view)
        viewModel.password = passwordTextfield.text!
        viewModel.isSetPasswordDetailsValid() { success, errorMessage in
            if success {
                self.performAPICall()
            }else{
                self.view.isUserInteractionEnabled = true
                hud.dismiss()
                self.showAlert("Error!", message: errorMessage!, actions: ["Ok"]) { (actionTitle) in
                    print(actionTitle)
                }
            }
        }
        
    }
    func configureUI(){
        hud.contentView.backgroundColor = #colorLiteral(red: 0.1529411765, green: 0.2274509804, blue: 0.8078431373, alpha: 0.1175952431)
        passwordTextfield.delegate = self
        passwordTextfield.setCorner(radius: 8)
        passwordTextfield.setLeftPaddingPoints(16)
    }
    private func performAPICall() {
        print(verifyResponse.data!)
        let data = verifyResponse.data
        let email = JSON(data ?? "")["email"].stringValue
        let token = JSON(data ?? "")["token"].stringValue
        let type = JSON(data ?? "")["type"].stringValue
        let requestModel = SetPasswordRequestModel(passwordTextfield.text!, token: token, email: email, type: type)
        viewModel.setPassword(requestModel) { response in
            self.view.isUserInteractionEnabled = true
            self.hud.dismiss()
            if response.success {
                switch self.verificationType {
                
                case "signUp":
                    self.presentingViewController?.presentingViewController?.dismiss(animated: true, completion: nil)
                    break
                case "confirm":
                    self.presentingViewController?.presentingViewController?.presentingViewController?.dismiss(animated: true, completion: nil)
                    break
                default : break
                
                }
            }else{
                let message = response.successMessage
                self.showAlert("Error!", message: message!, actions: ["Ok"]) { (actionTitle) in
                    print(actionTitle)
                }
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

}
extension SetPasswordViewController : UITextFieldDelegate{
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == passwordTextfield{
            self.passwordTextfield.setBorder(width: 1, color: UIColor(named: "Basic Blue")! )

        }
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == passwordTextfield{
            self.passwordTextfield.setBorder(width: 0, color: UIColor.clear )

        }
    }
}
