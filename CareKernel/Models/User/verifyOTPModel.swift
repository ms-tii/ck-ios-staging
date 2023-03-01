//
//  verifyOTPModel.swift
//  CareKernel
//
//  Created by MAC PC on 02/10/21.
//

import Foundation
struct VerifyOTPRequestModel {
    var otpText = ""
    init(otpText: String) {
        self.otpText = otpText
    }
    func getParams() -> [String: Any] {
        return ["token": otpText]
    }
}

struct VerifyCodeRequestModel {
    var codeText = ""
    var email = ""
    init(codeText: String, email: String) {
        self.codeText = codeText
        self.email = email
    }
    func getParams() -> [String: Any] {
        return ["code": codeText, "email": email]
    }
}

struct VerifyOTPResponseModel {
    var success = false
    var errorMessage: String?
    var successMessage: String?
    var data: Any?
}
