//
//  ActivityViewModel.swift
//  CareKernel
//
//  Created by Mohit Sharma on 01/11/22.
//

import Foundation
import SwiftyJSON
import Alamofire

struct ActivityViewModel : Codable {
    var token: String?
    var sessionId: Int?
}

extension ActivityViewModel {
    
    func getActivityCategory(completion: @escaping (JSON, Bool) -> Void){
        let url = baseURL + "activity-log-categories?limit=100"
        AFWrapper.sharedInstance.sendRequest(url: url, method: .get) { statusCode, response in
            return completion(response, true)
        } fail: { statusCode, error, response in
            
            return completion(response, false)
        }

        
    }
    
    func saveActivity(params: [String:Any], completion: @escaping (JSON, Bool) -> Void){
        AFWrapper.sharedInstance.updateJSONHeader(token: self.token ?? "")
        let url = baseURL + "session-activity-logs"
        
        AFWrapper.sharedInstance.sendRequest(url: url, method: .post, parameters: params) { statusCode, response in
            return completion(response, true)
        } fail: { statusCode, error, response in
            
            return completion(response, false)
        }

    }
    
    func getActivityLogData(completion: @escaping (JSON, Bool) -> Void){
        
        AFWrapper.sharedInstance.updateJSONHeader(token: self.token ?? "")
        let url = baseURL + "session-activity-logs?sessionId=" + "\(String(describing: self.sessionId!))"
        AFWrapper.sharedInstance.sendRequest(url: url, method: .get) { statusCode, response in
            return completion(response, true)
        } fail: { statusCode, error, response in
            
            return completion(response, false)
        }

        
    }
    
    func editActivityLog(param: [String:Any], activityId: Int, completion: @escaping (JSON, Bool) -> Void){
        AFWrapper.sharedInstance.updateJSONHeader(token: self.token ?? "")
        let url = baseURL + "session-activity-logs/" + "\(activityId)"
        AFWrapper.sharedInstance.sendRequest(url: url, method: .put, parameters: param) { statusCode, response in
            return completion(response, true)
        } fail: { statusCode, error, response in
            
            return completion(response, false)
        }
    }
    
    func deleteAllowance(activityId: Int, completion: @escaping (JSON, Bool) -> Void){
        AFWrapper.sharedInstance.updateJSONHeader(token: self.token ?? "")
        let url = baseURL + "session-activity-logs/" + "\(activityId)"
        AFWrapper.sharedInstance.sendRequest(url: url, method: .delete) { statusCode, response in
            return completion(response, true)
        } fail: { statusCode, error, response in
            
            return completion(response, false)
        }
    }
    
    
}

