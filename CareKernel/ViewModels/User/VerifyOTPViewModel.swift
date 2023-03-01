//
//  VerifyOTPViewModel.swift
//  CareKernel
//
//  Created by MAC PC on 02/10/21.
//

import Foundation
import SwiftyJSON

struct VerifyOTPViewModel {
    var OTP: String?
    
}

extension VerifyOTPViewModel{
    
    func isOTPValid()-> String{
        
        guard OTP != "" else {
            return "Token cannot be empty"
        }
        if self.OTP!.count <= 5{
            return "Token cannot be less then 6 digit"
        }else{
            return "Valid"
        }
    }
    
    func submitOTP(_ request: VerifyOTPRequestModel, requestURL: String, completion: @escaping (VerifyOTPResponseModel) -> Void) {
        print(request.getParams())
        var responseModel = VerifyOTPResponseModel()
        AFWrapper.sharedInstance.sendRequest(url: requestURL, method: .post, parameters: request.getParams()) { statusCode, response in
            let userID = JSON(response)["id"].intValue
            let emailId = JSON(response)["email"].stringValue
            careKernelDefaults.set(Int(userID), forKey: kUserId)
            careKernelDefaults.set(emailId, forKey: kUserEmailId)
            responseModel.success = true
            responseModel.successMessage = "OTP Verified successfully"
            responseModel.data = JSON(response)
            return completion(responseModel)
        } fail: { statusCode, error, response in
            
            responseModel.success = false
            responseModel.successMessage = response["message"].stringValue
            responseModel.data = JSON(response)
            return completion(responseModel)
        }        
        
    }
    
    func submitCode(_ request: VerifyCodeRequestModel, requestURL: String, completion: @escaping (VerifyOTPResponseModel) -> Void) {
        print(request.getParams())
        var responseModel = VerifyOTPResponseModel()
        AFWrapper.sharedInstance.sendRequest(url: requestURL, method: .post, parameters: request.getParams()) { statusCode, response in
            let userID = JSON(response)["id"].intValue
            let emailId = JSON(response)["email"].stringValue
            careKernelDefaults.set(userID, forKey: kUserId)
            careKernelDefaults.set(emailId, forKey: kUserEmailId)
            responseModel.success = true
            responseModel.successMessage = "OTP Verified successfully"
            responseModel.data = JSON(response)
            return completion(responseModel)
        } fail: { statusCode, error, response in
            
            responseModel.success = false
            responseModel.successMessage = response["message"].stringValue
            responseModel.data = JSON(response)
            return completion(responseModel)
        }
        
    }
}
