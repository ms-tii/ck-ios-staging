//
//  setPasswordViewModel.swift
//  CareKernel
//
//  Created by MAC PC on 21/09/21.
//

import Foundation
struct SetPasswordViewModel{
    var password: String!
    var token: String!
    var type: String!
    var email: String!

    let passwordEmptyMessage = "Please Enter Password"
    let passwordLengthRange = (6, 14) // (minimum length, maximum length)
    let passwordErrorMessage = "Please enter valid password"
}

extension SetPasswordViewModel{
    func isSetPasswordDetailsValid(_ completion: (Bool, String?) -> Void){
        if self.password.isTextEmpty(){
            completion(false, passwordEmptyMessage)
            return
        }
        
        completion(true, nil)
    }
    
    func setPassword(_ request: SetPasswordRequestModel, completion: @escaping (SetPasswordResponseModel) -> Void) {
        let params = request.getParams()
        print("Reset Password Input:\(params)")
        var responseModel = SetPasswordResponseModel()

        AFWrapper.sharedInstance.sendRequest(url: setPasswordUrl, method: .post, parameters: params) { statusCode, response in
            responseModel.success = true
            responseModel.successMessage = "Password set successfully"
            responseModel.data = response
            return completion(responseModel)
        } fail: { statusCode, error, response in
            responseModel.success = false
            responseModel.successMessage = response["message"].stringValue
            responseModel.data = response
            return completion(responseModel)
        }

        
    }
}
