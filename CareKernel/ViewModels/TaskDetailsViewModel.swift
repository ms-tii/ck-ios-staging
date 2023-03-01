//
//  TaskDetailsViewModel.swift
//  CareKernel
//
//  Created by Mohit Sharma on 10/11/21.
//

import Foundation
import SwiftyJSON

struct TaskDetailsViewModel {
    var token : String!
    var taskId: Int!
}

extension TaskDetailsViewModel {
    
    func getTaskDetails(completion: @escaping (JSON, Bool) -> Void) {
        
        AFWrapper.sharedInstance.updateJSONHeader(token: self.token)
        let url = tasksURL + "/\(String(describing: taskId!))"
        AFWrapper.sharedInstance.sendRequest(url: url, method: .get) { statusCode, response in
            return completion(response, true)
        } fail: { statusCode, error, response in
            return completion(response,false)
        }

    }
    
    func getUser(completion: @escaping (JSON, Bool) -> Void) {
        
        AFWrapper.sharedInstance.updateJSONHeader(token: self.token)
        let url = userURL
        AFWrapper.sharedInstance.sendRequest(url: url, method: .get) { statusCode, response in
            return completion(response, true)
        } fail: { statusCode, error, response in
            return completion(response,false)
        }

    }
    
    func updateDetails(params: [String:Any], completion: @escaping (JSON, Bool) -> Void){
        AFWrapper.sharedInstance.updateJSONHeader(token: self.token)
        let url = tasksURL + "/\(self.taskId!)"
        AFWrapper.sharedInstance.sendPatchRequest(url: url, method: .patch, parameters: params){ statusCode, response in
            
            return completion(response, true)
        } fail: { statusCode, error, response in
            print(error,response)
            return completion(response, false)
        }
    }
    
    func getTaskComments(completion: @escaping (JSON, Bool) -> Void) {
        
        AFWrapper.sharedInstance.updateJSONHeader(token: self.token)
        let url = tasksURL + "/\(String(describing: taskId!))" + "/comments"
        AFWrapper.sharedInstance.sendRequest(url: url, method: .get) { statusCode, response in
            return completion(response, true)
        } fail: { statusCode, error, response in
            return completion(response,false)
        }

    }
    
    func createTaskComment(taskId: Int, param: [String:Any], completion: @escaping (JSON, Bool) -> Void) {
        let apiURL = tasksURL + "/\(String(describing: taskId))" + "/comments"
        AFWrapper.sharedInstance.sendRequest(url: apiURL, method: .post, parameters: param) { statusCode, response in
            return completion(response,true)
        } fail: { statusCode, error, response in
            return completion(response,false)
        }
    }
    
}

struct TaskDetailsResponseModel {
    var success = false
    var errorMessage: String?
    var successMessage: String?
    var data: Any?
}
