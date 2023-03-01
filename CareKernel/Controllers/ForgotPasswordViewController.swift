//
//  ForgotPasswordViewController.swift
//  CareKernel
//
//  Created by MAC PC on 01/10/21.
//

import UIKit
import JGProgressHUD

class ForgotPasswordViewController: UIViewController {
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var recoverButton: UIButton!
    
    var forgotViewModel = ForgotPasswordViewModel()
    let hud = JGProgressHUD()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        // Do any additional setup after loading the view.
    }
    @IBAction func backButtonAction(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func recoverButtonAction(_ sender: UIButton) {
        self.view.endEditing(true)
        self.view.isUserInteractionEnabled = false
        hud.show(in: self.view)
        forgotViewModel.validateInput(emailTextField.text) { success, errorMessage in
            if success {
                self.performAPICall()
            }else{
                self.view.isUserInteractionEnabled = true
                hud.dismiss()
                self.showAlert("Error!", message: errorMessage!, actions: ["OK"]) { actionTitle in
                    
                }
            }
        }
        
    }
    
    func configureUI(){
        hud.contentView.backgroundColor = #colorLiteral(red: 0.1529411765, green: 0.2274509804, blue: 0.8078431373, alpha: 0.1175952431)
        emailTextField.delegate = self
        emailTextField.setCorner(radius: 8)
        emailTextField.setLeftPaddingPoints(16)
    }
    private func performAPICall() {
        let requestModel = ForgotPasswordRequestModel(email: emailTextField.text!)
        forgotViewModel.getOtp(requestModel) { response in
            self.view.isUserInteractionEnabled = true
            self.hud.dismiss()
            if response.success {
                DispatchQueue.main.async {
                    self.performSegue(withIdentifier: "segueToVerifyOtp", sender: nil)
                }
            }else{
                let message = response.successMessage
                self.showAlert("Error!", message: message!, actions: ["Ok"]) { (actionTitle) in
                    print(actionTitle)
                }
            }
        }
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? codeVerifyViewController {
        vc.verificationType = "confirm"
            vc.forgotUserEmail = self.emailTextField.text!
        }
    }
    

}
extension ForgotPasswordViewController : UITextFieldDelegate{
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == emailTextField{
            self.emailTextField.setBorder(width: 1, color: UIColor(named: "Basic Blue")! )

        }
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == emailTextField{
            self.emailTextField.setBorder(width: 0, color: UIColor.clear )

        }
    }
}
