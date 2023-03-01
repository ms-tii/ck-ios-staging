//
//  SessionsUpdateViewModel.swift
//  CareKernel
//
//  Created by Mohit Sharma on 08/11/21.
//

import Foundation
import SwiftyJSON
import Alamofire

struct SessionsUpdateViewModel{
    var sessionId: Int!
    var sessionUserId: Int!
    var clockOnAt: Bool!
    var clockOnLat: String!
    var clockOnLong: String!
    var clockOffAt: Bool!
    var clockOffLat: String!
    var clockOffLong: String!
    var travelKm: Int!
    var isDelivered: Bool!
    var token: String!
    var sessionStatus: String!
    
}
struct CustomPATCHEncoding: ParameterEncoding {
    func encode(_ urlRequest: URLRequestConvertible, with parameters: Parameters?) throws -> URLRequest {
        let mutableRequest = try! URLEncoding().encode(urlRequest, with: parameters) as? NSMutableURLRequest

        do {
            let jsonData = try JSONSerialization.data(withJSONObject: parameters!, options: .prettyPrinted)
            mutableRequest?.httpBody = jsonData
        } catch {
            print(error.localizedDescription)
        }

        return mutableRequest! as URLRequest
    }
}
extension SessionsUpdateViewModel {
    func updateSession(completion: @escaping (JSON, Bool) -> Void){
        let params:[String: Any] = ["sessionUserId": self.sessionUserId!,"clockOnAt": self.clockOnAt ?? "", "clockOnLat": self.clockOnLat ?? "", "clockOnLong": self.clockOnLong ?? "", "clockOffAt": self.clockOffAt ?? "","clockOffLat": self.clockOffLat ?? "", "clockOffLong": self.clockOffLong ?? "", "travelKm": self.travelKm ?? "", "isDelivered": self.isDelivered ?? ""]
        
        AFWrapper.sharedInstance.updateJSONHeader(token: self.token!)
        let url = sessionsURL + "/\(self.sessionId!)" + "/session-users/" + "\(sessionUserId!)"
        AFWrapper.sharedInstance.sendPatchRequest(url: url, method: .patch, parameters: params) { statusCode, response in
            
            return completion(response, true)
        } fail: { statusCode, error, response in
            print(error,response)
            return completion(response, false)
            
        }

    }

    func deliveredSession(completion: @escaping (JSON, Bool) -> Void){
        let params:[String: String] = ["sessionStatus": "delivered"]
        
//        AFWrapper.sharedInstance.updateJSONHeader(token: self.token)
        let url = sessionsURL + "/\(self.sessionId!)" + "/session-users/" + "\(sessionUserId!)"
        AFWrapper.sharedInstance.sendPatchRequest(url: url, method: .patch, parameters: params) { statusCode, response in
            
            return completion(response, true)
        } fail: { statusCode, error, response in
            print(error,response)
            return completion(response, false)
            
        }

    }
    func updateClock(params: [String:Any], completion: @escaping (JSON, Bool) -> Void){
        let url = sessionsURL + "/\(self.sessionId!)" + "/session-users/" + "\(sessionUserId!)"
        AFWrapper.sharedInstance.sendPatchRequest(url: url, method: .patch, parameters: params){ statusCode, response in
            
            return completion(response, true)
        } fail: { statusCode, error, response in
            print(error,response)
            return completion(response, false)
        }
        
    }
    
    func updateTaskStatus(taskId: Int, params: [String:Any], completion: @escaping (JSON, Bool) -> Void){
        let url = sessionsURL + "/\(self.sessionId!)" + "/session-tasks/" + "\(taskId)"
        AFWrapper.sharedInstance.sendPatchRequest(url: url, method: .patch, parameters: params) { statusCode, response in
            return completion(response, true)
        } fail: { statusCode, error, response in
            return completion(response, false)
        }

    }
    
    func getSessionTasks(completion: @escaping (JSON, Bool) -> Void){
        let url = sessionsURL + "/\(self.sessionId!)" + "/session-tasks/"
        AFWrapper.sharedInstance.sendRequest(url: url, method: .get) { statusCode, response in
            return completion(response, true)
        } fail: { statusCode, error, response in
            return completion(response, false)
        }

    }
}
