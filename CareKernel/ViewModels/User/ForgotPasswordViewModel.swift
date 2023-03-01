//
//  ForgotPasswordViewModel.swift
//  CareKernel
//
//  Created by MAC PC on 01/10/21.
//

import UIKit

struct ForgotPasswordViewModel {
    let emailEmptyMessage = "Please Enter Email"
    let emailErrorMessage = "Entered Email is invalid"

    func validateInput(_ email: String?, completion: (Bool, String?) -> Void) {
        if let email = email {
            if email.isEmpty {
                completion(false, emailEmptyMessage)
                return
            } else if !email.isValidEmail() {
                completion(false, emailErrorMessage)
                return
            }
        } else {
            completion(false, emailEmptyMessage)
            return
        }
        completion(true, nil)
    }

    func getOtp(_ request: ForgotPasswordRequestModel, completion: @escaping (ForgotPasswordResponseModel) -> Void) {
        print(request.getParams())
        var responseModel = ForgotPasswordResponseModel()
        AFWrapper.sharedInstance.sendRequest(url: forgotPassUrl, method: .post, parameters: request.getParams()) { statusCode, response in
            responseModel.success = true
            responseModel.successMessage = "Recovery code has been set to your registered email"
            return completion(responseModel)
        } fail: { statusCode, error, response in
            responseModel.success = false
            responseModel.successMessage = response["message"].stringValue
            return completion(responseModel)
        }
                
    }
}

