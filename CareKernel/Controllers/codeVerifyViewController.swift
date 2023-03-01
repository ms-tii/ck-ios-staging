//
//  VerifyUserViewController.swift
//  CareKernel
//
//  Created by Mohit Sharma on 30/08/21.
//

import UIKit
import JGProgressHUD


class codeVerifyViewController: UIViewController {
    
    @IBOutlet var textField1: UITextField!
    @IBOutlet var textField2: UITextField!
    @IBOutlet var textField3: UITextField!
    @IBOutlet var textField4: UITextField!
    @IBOutlet var textField5: UITextField!
    @IBOutlet var textField6: UITextField!
    @IBOutlet var submitButton: UIButton!
    @IBOutlet var alreadyAccountStackView: UIStackView!
    @IBOutlet var headingLabel: UILabel!
    @IBOutlet var discriptionLabel: UILabel!
    
    private var userSignUpDetails = UserSignUpViewModel()
    enum VerificationType {
        case signUp
        case confirm
    }
    var otp: String = ""
    var verificationType = ""
    var forgotUserEmail = ""
    var arrOtpFields = [UITextField]()
    var viewModel = VerifyOTPViewModel()
    let hud = JGProgressHUD()

    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
    }
    
    func configureView (){
        switch verificationType {
        case "signUp" :
            self.updateControlsView(visible: false, headingLabelText: "Signup", descriptionLabelText: "Create an account so you can manage your profile.", buttonTitle: "Signup")
            break
        case "confirm" :
            self.updateControlsView(visible: true, headingLabelText: "Enter Code", descriptionLabelText: "Enter verification code received in email", buttonTitle: "Confirm")
            break
        default:
            self.updateControlsView(visible: true, headingLabelText: "Enter Code", descriptionLabelText: "Enter verification code received in email", buttonTitle: "Confirm")
            break
        }
        
        self.hideKeyboard()
        hud.contentView.backgroundColor = #colorLiteral(red: 0.1529411765, green: 0.2274509804, blue: 0.8078431373, alpha: 0.1175952431)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShowNotification), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHideNotification), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        
        textField1.addBottomBorder(color: UIColor(named: "Light TextField border")!)
        textField2.addBottomBorder(color: UIColor(named: "Light TextField border")!)
        textField3.addBottomBorder(color: UIColor(named: "Light TextField border")!)
        textField4.addBottomBorder(color: UIColor(named: "Light TextField border")!)
        textField5.addBottomBorder(color: UIColor(named: "Light TextField border")!)
        textField6.addBottomBorder(color: UIColor(named: "Light TextField border")!)
        
        self.textField1.delegate = self
        self.textField2.delegate = self
        self.textField3.delegate = self
        self.textField4.delegate = self
        self.textField5.delegate = self
        self.textField6.delegate = self
        
        
        self.textField1.addTarget(self, action: #selector(self.changeCharacter), for: .editingChanged)
        self.textField2.addTarget(self, action: #selector(self.changeCharacter), for: .editingChanged)
        self.textField3.addTarget(self, action: #selector(self.changeCharacter), for: .editingChanged)
        self.textField4.addTarget(self, action: #selector(self.changeCharacter), for: .editingChanged)
        self.textField5.addTarget(self, action: #selector(self.changeCharacter), for: .editingChanged)
        self.textField6.addTarget(self, action: #selector(self.changeCharacter), for: .editingChanged)
    }
    
    func updateControlsView(visible: Bool, headingLabelText: String, descriptionLabelText: String, buttonTitle: String){
        DispatchQueue.main.async {
            self.alreadyAccountStackView.isHidden = visible
            self.headingLabel.text = headingLabelText
            self.discriptionLabel.text = descriptionLabelText
            self.submitButton.titleLabel?.text = buttonTitle
        }
    }
    
    @IBAction func backButtonAction(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func verifyAction(_ sender: UIButton) {
        self.view.isUserInteractionEnabled = false
        hud.show(in: self.view)
        viewModel.OTP = self.otp
        let isValidate = viewModel.isOTPValid()
        guard isValidate == "Valid" else {
            //showAlert
            print(isValidate)
            self.view.isUserInteractionEnabled = true
            hud.dismiss()
            self.showAlert("Error!", message: isValidate, actions: ["Ok"]) { actionTitle in
                
            }
            return
        }
        print(isValidate)
        switch verificationType {
        
        case "signUp":
            let verifyRequestModel = VerifyOTPRequestModel(otpText: self.otp)
            viewModel.submitOTP(verifyRequestModel, requestURL: verifyUrl) { response in
                self.view.isUserInteractionEnabled = true
                self.hud.dismiss()
                if response.success {
                    self.popAfterSuccessfulLogin(response: response)
                }else{
                    let message = response.successMessage
                    self.showAlert("Error!", message: message!, actions: ["Ok"]) { (actionTitle) in
                        print(actionTitle)
                    }
                }
            }
            break
        case "confirm":
            let verifyRequestModel = VerifyCodeRequestModel(codeText: self.otp, email: self.forgotUserEmail)
            viewModel.submitCode(verifyRequestModel, requestURL: verifyCodeUrl) { response in
                self.view.isUserInteractionEnabled = true
                self.hud.dismiss()
                if response.success {
                    self.popAfterSuccessfulLogin(response: response)
                    
                }else{
                    let message = response.successMessage
                    self.showAlert("Error!", message: message!, actions: ["Ok"]) { (actionTitle) in
                        print(actionTitle)
                    }
                }
            }
            break
        default : break
            
        }
        
    }
    
    func popAfterSuccessfulLogin(response: VerifyOTPResponseModel) {
        DispatchQueue.main.async {
            self.performSegue(withIdentifier: "segueToSetPassword", sender: response.data)
        }
    }
    
    @objc func changeCharacter(textField : UITextField){
        if textField.text?.utf8.count == 1 {
            switch textField {
            case textField1:
                textField2.becomeFirstResponder()
            case textField2:
                textField3.becomeFirstResponder()
            case textField3:
                textField4.becomeFirstResponder()
            case textField4:
                textField5.becomeFirstResponder()
            case textField5:
                textField6.becomeFirstResponder()
            case textField6:
                otp = "\(textField1.text!)\(textField2.text!)\(textField3.text!)\(textField4.text!)\(textField5.text!)\(textField6.text!)"
                print(otp)
                
            default:
                break
            }
        }else if textField.text!.isEmpty {
            switch textField {
            
            case textField6:
                textField5.becomeFirstResponder()
            case textField5:
                textField4.becomeFirstResponder()
            case textField4:
                textField3.becomeFirstResponder()
            case textField3:
                textField2.becomeFirstResponder()
            case textField2:
                textField1.becomeFirstResponder()
            case textField1:
                otp = "\(textField1.text!)\(textField2.text!)\(textField3.text!)\(textField4.text!)\(textField5.text!)\(textField6.text!)"
                print(otp)
            default:
                break
            }
        }
    }
    
    @objc func keyboardWillShowNotification(notification: Notification) {
//        if let frame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
//            let height = frame.cgRectValue.height
//            //            self.scrollView.contentSize = CGSize(width: self.view.frame.width, height: self.scrollView.contentSize.height + height)
//        }
    }
    
    @objc func keyboardWillHideNotification(notification: Notification) {
//        if let frame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
//            let height = frame.cgRectValue.height
//            //            self.scrollView.contentSize = CGSize(width: self.view.frame.width, height: self.scrollView.contentSize.height + height)
//        }
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let vc = segue.destination as! SetPasswordViewController
        vc.verifyResponse.data = sender
        vc.verificationType = verificationType
    }
    
    
}


extension codeVerifyViewController :UITextFieldDelegate{
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField.text!.utf16.count == 1 && !string.isEmpty {
            return false
        } else {
            return true
        }
    }
}
