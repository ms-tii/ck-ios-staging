//
//  ClientDetailsViewModel.swift
//  CareKernel
//
//  Created by Mohit Sharma on 28/10/21.
//

import Foundation
import SwiftyJSON

struct ClientDetailsViewModel : Codable {
    var clientId: Int?
    var token: String?
}

extension ClientDetailsViewModel {
    
    func getClientDetails(clientID: String, token: String, completion: @escaping (JSON, Bool) -> Void){
        
        AFWrapper.sharedInstance.updateJSONHeader(token: token)
        guard let _ = careKernelDefaults.object(forKey: kUserId) else {
            return()
        }
        
        let clientURL = clientDetailsURL + "/" + "\(String(describing: clientID))"
        
        AFWrapper.sharedInstance.sendRequest(url: clientURL, method: .get) { statusCode, response in
            
            return completion(response,true)
        } fail: { statusCode, error, response in
            print(error)
            return completion(response,false)
        }

        
    }
    
    func getClientCasenotes(clientID: String, token: String, offset: String, limit: String, completion: @escaping (JSON, Bool) -> Void){
        
        AFWrapper.sharedInstance.updateJSONHeader(token: token)
        guard let _ = careKernelDefaults.object(forKey: kUserId) else {
            return()
        }
        
        let clientURL = clientDetailsURL + "/" + "\(String(describing: clientID))" + "/" + "case-notes" + "?offset=\(offset)&limit=\(limit)"
        
        AFWrapper.sharedInstance.sendRequest(url: clientURL, method: .get) { statusCode, response in
            
            return completion(response,true)
        } fail: { statusCode, error, response in
            print(error)
            return completion(response,false)
        }

        
    }
    
    func getSessionCasenotes(sessionID: String, clientID: String, token: String, offset: String, limit: String, completion: @escaping (JSON, Bool) -> Void){
        
        AFWrapper.sharedInstance.updateJSONHeader(token: token)
        guard let _ = careKernelDefaults.object(forKey: kUserId) else {
            return()
        }
        
        let clientURL = baseURL + "case-notes?" + "sessionId=" + "\(String(describing: sessionID))" + "&clientId="  + "\(String(describing: clientID))" + "&offset=\(offset)&limit=\(limit)"
        
        AFWrapper.sharedInstance.sendRequest(url: clientURL, method: .get) { statusCode, response in
            
            return completion(response,true)
        } fail: { statusCode, error, response in
            print(error)
            return completion(response,false)
        }

        
    }
    func getClientHealthCondition(clientID: String, token: String, completion: @escaping (JSON, Bool) -> Void){
        
        AFWrapper.sharedInstance.updateJSONHeader(token: token)
        guard let _ = careKernelDefaults.object(forKey: kUserId) else {
            return()
        }
        
        let clientURL = clientDetailsURL + "/" + clientID + "/" + "health-conditions?limit=100"
        
        AFWrapper.sharedInstance.sendRequest(url: clientURL, method: .get) { statusCode, response in
            
            return completion(response,true)
        } fail: { statusCode, error, response in
            print(error)
            return completion(response,false)
        }
    }
    
    func getClientMedicines(clientID: String, token: String, completion: @escaping (JSON, Bool) -> Void){
        
        AFWrapper.sharedInstance.updateJSONHeader(token: token)
        guard let _ = careKernelDefaults.object(forKey: kUserId) else {
            return()
        }
        
        let clientURL = clientDetailsURL + "/" + clientID + "/" + "medications?limit=100"
        
        AFWrapper.sharedInstance.sendRequest(url: clientURL, method: .get) { statusCode, response in
            
            return completion(response,true)
        } fail: { statusCode, error, response in
            print(error)
            return completion(response,false)
        }
    }
    
    func getClientRisks(clientID: String, token: String, completion: @escaping (JSON, Bool) -> Void){
        
        AFWrapper.sharedInstance.updateJSONHeader(token: token)
        guard let _ = careKernelDefaults.object(forKey: kUserId) else {
            return()
        }
        
        let clientURL = clientDetailsURL + "/" + clientID + "/" + "risks?limit=100"
        
        AFWrapper.sharedInstance.sendRequest(url: clientURL, method: .get) { statusCode, response in
            
            return completion(response,true)
        } fail: { statusCode, error, response in
            print(error)
            return completion(response,false)
        }
    }
    
    func getClientMedicalDetails(clientID: String, token: String, completion: @escaping (JSON, Bool) -> Void){
        
        AFWrapper.sharedInstance.updateJSONHeader(token: token)
        guard let _ = careKernelDefaults.object(forKey: kUserId) else {
            return()
        }
        
        let clientURL = clientDetailsURL + "/" + clientID + "/" + "medical-details"
        AFWrapper.sharedInstance.sendRequest(url: clientURL, method: .get) { statusCode, response in
            
            return completion(response,true)
        } fail: { statusCode, error, response in
            print(error)
            return completion(response,false)
        }
    }
    func getClientFiles(entity: String, clientID: String, token: String, completion: @escaping (JSON, Bool) -> Void){
        
        AFWrapper.sharedInstance.updateJSONHeader(token: token)
        guard let _ = careKernelDefaults.object(forKey: kUserId) else {
            return()
        }
        
        let clientURL = getFilesURL + entity + "&clientId=" + clientID + "&limit=100"
        
        AFWrapper.sharedInstance.sendRequest(url: clientURL, method: .get) { statusCode, response in
            
            return completion(response,true)
        } fail: { statusCode, error, response in
            print(error)
            return completion(response,false)
        }
    }
    
    func getCasenoteFiles(entity: String, entityID: String, token: String, completion: @escaping (JSON, Bool) -> Void){
        
        AFWrapper.sharedInstance.updateJSONHeader(token: token)
        guard let _ = careKernelDefaults.object(forKey: kUserId) else {
            return()
        }
        
        let clientURL = getFilesURL + entity + "&entityId=" + entityID
        
        AFWrapper.sharedInstance.sendRequest(url: clientURL, method: .get) { statusCode, response in
            
            return completion(response,true)
        } fail: { statusCode, error, response in
            print(error)
            return completion(response,false)
        }
    }
    
    func getClientGoals(clientID: String, token: String, completion: @escaping (JSON, Bool) -> Void){
        
        AFWrapper.sharedInstance.updateJSONHeader(token: token)
        guard let _ = careKernelDefaults.object(forKey: kUserId) else {
            return()
        }
    
        let clientURL = clientDetailsURL + "/" + clientID + "/" + "goals?limit=100&mobile=true"
        
        AFWrapper.sharedInstance.sendRequest(url: clientURL, method: .get) { statusCode, response in
            
            return completion(response,true)
        } fail: { statusCode, error, response in
            print(error)
            return completion(response,false)
        }
    }
    
    func getClientGoalsObjective(goalId: Int, goalObjectiveId: Int, completion: @escaping (JSON, Bool) -> Void){
        
        AFWrapper.sharedInstance.updateJSONHeader(token: self.token ?? "")
    
        let url = clientDetailsURL + "/\(String(describing: self.clientId!))" + "/goals/" + "\(String(describing: goalId))" + "/goal-objectives/" + "\(String(describing: goalObjectiveId))" + "/goal-objective-readings?mobile=true"
        
        AFWrapper.sharedInstance.sendRequest(url: url, method: .get) { statusCode, response in
            
            return completion(response,true)
        } fail: { statusCode, error, response in
            print(error)
            return completion(response,false)
        }
    }
        
    func addClientAchivemets(goalId: Int, goalObjectiveId: Int, params: [String:Any], completion: @escaping (JSON, Bool) -> Void){
        AFWrapper.sharedInstance.updateJSONHeader(token: self.token ?? "")

        let url = clientDetailsURL + "/\(String(describing: self.clientId!))" + "/goals/" + "\(String(describing: goalId))" + "/goal-objectives/" + "\(String(describing: goalObjectiveId))" + "/goal-objective-readings"
        
        AFWrapper.sharedInstance.sendRequest(url: url, method: .post, parameters: params) { statusCode, response in
            return completion(response, true)
        } fail: { statusCode, error, response in
            return completion(response, false)
        }
    }
}
