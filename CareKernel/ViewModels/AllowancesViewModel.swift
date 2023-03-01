//
//  AllowancesViewModel.swift
//  CareKernel
//
//  Created by Mohit Sharma on 26/04/22.
//

import Foundation
import SwiftyJSON
import Alamofire

struct Allowances: Codable {
    var allowances: [Allowance]
    
}


struct Allowance: Codable {
    var allowanceID: Int
    var unit: Float

    enum CodingKeys: String, CodingKey {
        case allowanceID = "allowanceId"
        case unit
    }
    
    var allowanceDescription:[String:Any] {
        get {
            return ["allowanceId":allowanceID, "unit": unit]
        }
    }
}

struct AllowancesViewModel : Codable {
    var token: String?
    var sessionId: Int?
}

extension AllowancesViewModel {
    
    func getAllowanceItems(completion: @escaping (JSON, Bool) -> Void){
        
        AFWrapper.sharedInstance.sendRequest(url: allowancesURL, method: .get) { statusCode, response in
            return completion(response, true)
        } fail: { statusCode, error, response in
            
            return completion(response, false)
        }
        
    }
    
    func saveAllowance(params: [String:Any], completion: @escaping (JSON, Bool) -> Void){
        AFWrapper.sharedInstance.updateJSONHeader(token: self.token ?? "")
        let url = baseURL + "sessions" + "/\(String(describing: self.sessionId!))"
        
        AFWrapper.sharedInstance.sendRequest(url: url, method: .patch, parameters: params) { statusCode, response in
            return completion(response, true)
        } fail: { statusCode, error, response in
            
            return completion(response, false)
        }

    }
    
    func saveTravelAllowance(sessionUserId: Int, params: [String:Any], completion: @escaping (JSON, Bool) -> Void){
        AFWrapper.sharedInstance.updateJSONHeader(token: self.token ?? "")
        let url = baseURL + "sessions" + "/\(String(describing: self.sessionId!))" + "/session-users/" + "\(String(describing: sessionUserId))"
        
        AFWrapper.sharedInstance.sendRequest(url: url, method: .patch, parameters: params) { statusCode, response in
            return completion(response, true)
        } fail: { statusCode, error, response in
            
            return completion(response, false)
        }

    }
    
    func getSessionAllowances(completion: @escaping (JSON, Bool) -> Void){
        
        AFWrapper.sharedInstance.updateJSONHeader(token: self.token ?? "")
        let url = baseURL + "sessions" + "/\(String(describing: self.sessionId!))" + "/session-allowances?offset=0&limit=100"
        AFWrapper.sharedInstance.sendRequest(url: url, method: .get) { statusCode, response in
            return completion(response, true)
        } fail: { statusCode, error, response in
            
            return completion(response, false)
        }

        
    }
//    /v1/sessions/{sessionId}/session-users/allowances
    func editAllowance(param: [String:Any], sessionAllowanceId: Int, completion: @escaping (JSON, Bool) -> Void){
        AFWrapper.sharedInstance.updateJSONHeader(token: self.token ?? "")
        let url = baseURL + "sessions" + "/\(String(describing: self.sessionId!))" + "/session-users/allowances"
        AFWrapper.sharedInstance.sendRequest(url: url, method: .put, parameters: param) { statusCode, response in
            return completion(response, true)
        } fail: { statusCode, error, response in
            
            return completion(response, false)
        }
    }
    
    func deleteAllowance(sessionAllowanceId: Int, completion: @escaping (JSON, Bool) -> Void){
        AFWrapper.sharedInstance.updateJSONHeader(token: self.token ?? "")
        let url = baseURL + "sessions" + "/\(String(describing: self.sessionId!))" + "/session-allowances/" + "\(sessionAllowanceId)"
        AFWrapper.sharedInstance.sendRequest(url: url, method: .delete) { statusCode, response in
            return completion(response, true)
        } fail: { statusCode, error, response in
            
            return completion(response, false)
        }
    }
    
    //Wakeup Times
    
    func getWakeupTimesList(completion: @escaping (JSON, Bool) -> Void){
        
        let url = wakeTimesURL + "/\(String(describing: sessionId!))/wakeups"
        
        AFWrapper.sharedInstance.sendRequest(url: url, method: .get) { statusCode, response in
            return completion(response, true)
        } fail: { statusCode, error, response in
            
            return completion(response, false)
        }
    }
    
    func saveWakeupTimes(params: [String:Any], completion: @escaping (JSON, Bool) -> Void){
        let url = wakeTimesURL + "/\(String(describing: self.sessionId!))/wakeups"
        AFWrapper.sharedInstance.updateJSONHeader(token: self.token ?? "")
        
        AFWrapper.sharedInstance.sendRequest(url: url, method: .post, parameters: params) { statusCode, response in
            return completion(response, true)
        } fail: { statusCode, error, response in
            
            return completion(response, false)
        }

    }
    
    func editWakeupTime(param: [String:Any], wakeupTimeId: Int, completion: @escaping (JSON, Bool) -> Void){
        AFWrapper.sharedInstance.updateJSONHeader(token: self.token ?? "")
        let url = wakeTimesURL + "/\(String(describing: self.sessionId!))/wakeups/"  + "\(wakeupTimeId)"
        
        AFWrapper.sharedInstance.sendRequest(url: url, method: .put, parameters: param) { statusCode, response in
            return completion(response, true)
        } fail: { statusCode, error, response in
            
            return completion(response, false)
        }
    }
    
    func deleteWakeupTime(wakeupTimeId: Int, completion: @escaping (JSON, Bool) -> Void){
        AFWrapper.sharedInstance.updateJSONHeader(token: self.token ?? "")
        let url = wakeTimesURL + "/\(String(describing: self.sessionId!))/wakeups/"  + "\(wakeupTimeId)"
        AFWrapper.sharedInstance.sendRequest(url: url, method: .delete) { statusCode, response in
            return completion(response, true)
        } fail: { statusCode, error, response in
            
            return completion(response, false)
        }
    }
}
