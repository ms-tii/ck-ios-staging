//
//  ForgotPasswordModel.swift
//  CareKernel
//
//  Created by MAC PC on 02/10/21.
//

import Foundation

struct ForgotPasswordRequestModel {
    var email: String
    
    init(email: String) {
        self.email = email
    }
    func getParams() -> [String: Any] {
        return ["email": email]
    }
}

struct ForgotPasswordResponseModel {
    var success = false
    var errorMessage: String?
    var successMessage: String?
    var data: Any?
}
