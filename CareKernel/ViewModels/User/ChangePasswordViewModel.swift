//
//  ChangePasswordViewModel.swift
//  CareKernel
//
//  Created by Mohit Sharma on 13/12/21.
//

import Foundation
import SwiftyJSON

struct ChangePasswordViewModel {
    var oldPassword : String!
    var newPassword : String!
    var userID : Int!
}

extension ChangePasswordViewModel {
    func changePassword(completion: @escaping (JSON, Bool) -> Void){
        let params:[String: String] = ["oldPassword": self.oldPassword, "password": self.newPassword]
        
//        AFWrapper.sharedInstance.updateJSONHeader(token: self.token)
        let url = profileURL + "\(self.userID!)" + "/change-password"
        AFWrapper.sharedInstance.sendPatchRequest(url: url, method: .patch, parameters: params) { statusCode, response in
            
            return completion(response, true)
        } fail: { statusCode, error, response in
            print(error,response)
            return completion(response, false)
            
        }

    }
}
