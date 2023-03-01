//
//  LoginViewModel.swift
//  CareKernel
//
//  Created by MAC PC on 21/09/21.
//

import Foundation
import SwiftyJSON
import JWTDecode

class UserLoginViewModel {
    var email: String!
    var password: String!
    var fcmToken: String!
    var isFcmEnable: Bool!
}

extension UserLoginViewModel{
    
    func isLoginDetailsValid(completion: (Bool, String?) -> Void) {

        if !self.email.isValidEmail(){
            completion(false, "Email address is not valid.")
            return
        }else if self.password.isEmpty{
            completion(false, "Please enter password")
            return
        }else{
            completion(true, nil)
            return
        }
    }
    
    func loginCall(_ completion: @escaping (LoginResponseModel) -> Void){

        let scope = Scope(basicDetail: BasicDetail(access: true, viewPermision: BasicDetailViewPermision(dob: true, gender: true, email: true, phone: true, language: true, fullAddress: true, religion: true, nationality: true)),goals: CaseNotes(access: true, viewPermision: CaseNotesViewPermision()), caseNotes: CaseNotes(access: true, viewPermision: CaseNotesViewPermision()), healthConditions: CaseNotes(access: true, viewPermision: CaseNotesViewPermision()), incidents: CaseNotes(access: true, viewPermision: CaseNotesViewPermision()), medicalDetails: CaseNotes(access: true, viewPermision: CaseNotesViewPermision()), medications: CaseNotes(access: true, viewPermision: CaseNotesViewPermision()), risks: CaseNotes(access: true, viewPermision: CaseNotesViewPermision()))
        let encoder = JSONEncoder()
        let data = try! encoder.encode(scope)
        let convertedScopeString = String(data: data, encoding: .utf8)
        let param:[String: Any] = ["email": self.email!, "password": self.password!, "deviceId": self.fcmToken!, "isFcmEnable": self.isFcmEnable!, "scope": convertedScopeString!]
        var responseModel = LoginResponseModel()
        AFWrapper.sharedInstance.sendRequest(url: loginUrl, method: .post, parameters: param) { statusCode, response in

            print(statusCode ?? "")
            print(response)
            
            responseModel.success = true
            responseModel.successMessage = "User logged in successfully"
            responseModel.token = response["token"].stringValue
            careKernelDefaults.set(response["token"].stringValue, forKey: kLoginToken)
            careKernelDefaults.set(true, forKey: kIsLoggedIn)
            careKernelDefaults.set(self.email, forKey: kUserEmailId)
            do {
            let jwt = try decode(jwt: response["token"].stringValue)
                let sub = JSON(jwt.body)["sub"].stringValue
                let subID = JSON(jwt.body)["subId"].stringValue
                print(sub, subID)
                let scope1 = JSON(jwt.body)["scope"].stringValue
                
                if let scopeData = scope1.data(using: String.Encoding.utf8) {

                    let appData = try JSONDecoder().decode(Scope.self, from: scopeData)
                    Storage.store(appData, to: .documents, as: "appData.json")
                    
                
                careKernelDefaults.set(Int(sub), forKey: kUserId)
                careKernelDefaults.set(Int(subID), forKey: kWorkerID)
                }
            }catch {
                print(Error.self)
            }
            return completion(responseModel)
        } fail: { statusCode, error, response in
            
            print(statusCode ?? "")
            print(error)
            print(response)
            responseModel.success = false
            responseModel.successMessage = response["message"].stringValue
            responseModel.token = ""
            return completion(responseModel)
        }

    }
    
    func logoutCall(param: [String:Any], completion: @escaping (JSON, Bool) -> Void){
        let apiURL = notificationOnOffURL
        AFWrapper.sharedInstance.sendRequest(url: apiURL, method: .post, parameters: param) { statusCode, response in
            return completion(response,true)
        } fail: { statusCode, error, response in
            return completion(response,false)
        }

    }
}

//class UserLoginVm{
//     var email = ""
//     var password = ""
//
//    func isLoginDetailsValid() -> Bool{
//        if !self.email.isValidEmail(){
//            return false
//        }else if !self.password.isValidPassword(){
//           return false
//        }else{
//            return true
//        }
//
//    }
//
//    var isLoginComplete: Bool {
//        if !isLoginDetailsValid(){
//            return false
//        }else{
//            return true
//        }
//    }
//}
