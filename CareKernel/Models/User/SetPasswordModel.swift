//
//  setPasswordModel.swift
//  CareKernel
//
//  Created by MAC PC on 21/09/21.
//

import Foundation
struct SetPasswordRequestModel {
    var password: String
    var token: String
    var email: String
    var type: String
        
    init(_ password: String, token: String, email: String, type: String) {
        self.password = password
        self.token = token
        self.email = email
        self.type = type
    }

    func getParams() -> [String: Any] {
        return ["password": password, "token": token, "email": email, "type": type]
    }
}

struct SetPasswordResponseModel {
    var success = false
    var errorMessage: String?
    var successMessage: String?
    var data: Any?
}
