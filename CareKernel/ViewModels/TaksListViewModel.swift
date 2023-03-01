//
//  TaksListViewModel.swift
//  CareKernel
//
//  Created by Mohit Sharma on 08/11/21.
//

import Foundation
import SwiftyJSON
import Alamofire

struct TaskListViewModel {
    var token : String!
    var sessionUserId: Int!
}

extension TaskListViewModel {
    
    func getAllTask(url: String, completion: @escaping (JSON, Bool) -> Void) {
        
        AFWrapper.sharedInstance.updateJSONHeader(token: self.token)
        
        AFWrapper.sharedInstance.sendRequest(url: url, method: .get) { statusCode, response in
            return completion(response, true)
        } fail: { statusCode, error, response in
            return completion(response,false)
        }

    }
    
    func getAllTaskList(url: String, offset: String, limit: String, completion: @escaping (JSON, Bool) -> Void) {
        
        AFWrapper.sharedInstance.updateJSONHeader(token: self.token)
        let taskUrl = url + "&offset=\(offset)&limit=\(limit)"
        
        AFWrapper.sharedInstance.sendRequest(url: taskUrl, method: .get) { statusCode, response in
            return completion(response, true)
        } fail: { statusCode, error, response in
            return completion(response,false)
        }

    }
    
    func createTask(apiURL: String, param: [String:Any], method: HTTPMethod, completion: @escaping (JSON, Bool) -> Void) {
        
        AFWrapper.sharedInstance.sendRequest(url: apiURL, method: method, parameters: param) { statusCode, response in
            return completion(response,true)
        } fail: { statusCode, error, response in
            return completion(response,false)
        }
    }
    
    func updateTask(param: [String:Any], completion: @escaping (JSON, Bool) -> Void) {
        let apiURL = tasksURL
        AFWrapper.sharedInstance.sendRequest(url: apiURL, method: .patch, parameters: param) { statusCode, response in
            return completion(response,true)
        } fail: { statusCode, error, response in
            return completion(response,false)
        }
    }
    
    func uploadDocuments(fileName: String, fileData: Data, entity: String, entityId: Int, completion: @escaping (Bool) -> Void) {
        guard let token = careKernelDefaults.value(forKey: kLoginToken) as? String else {
            careKernelDefaults.set(false, forKey: kIsLoggedIn)
            return }
        var bodyKeyValue = [RequestBodyFormDataKeyValue]()
        
        bodyKeyValue.append(RequestBodyFormDataKeyValue(skey: "entity", sValue: "\(entity)", dbloadData: Data()))

        bodyKeyValue.append(RequestBodyFormDataKeyValue(skey: "entityId", sValue: "\(entityId)", dbloadData: Data()))
        bodyKeyValue.append(RequestBodyFormDataKeyValue(skey: "batchId", sValue: "", dbloadData: Data()))
        
        let url = filesURL
        
            
        bodyKeyValue.append(RequestBodyFormDataKeyValue(skey: "file", sValue: fileName, dbloadData: fileData))
        
        var sampleRequest = URLRequest(url: URL(string: url)!)
        sampleRequest.httpMethod = HttpMethod.post.rawValue
        
        AF.upload(multipartFormData:{ multipartFormdta in
            
            for formData in bodyKeyValue {
                if formData.dbloadData.isEmpty {
                    multipartFormdta.append(Data(formData.sValue.utf8), withName: formData.skey)
                }else{
                    multipartFormdta.append(fileData as Data, withName: formData.skey, fileName: fileName, mimeType: "image/jpg")
                }
                
                
            }
        }, to: url,method: .post, headers: ["Authorization": "Bearer \(token)"])
        .uploadProgress{progress in
            print(CGFloat(progress.fractionCompleted)*100)
        }
        .response{response in
            if(response.error == nil){
                
                var responseString: String!
                responseString = ""
                
                if (response.data != nil) {
                    responseString = String(bytes: response.data!, encoding: .utf8)
                }else{
                    responseString = response.response?.description
                }
                print(responseString ?? "")
                
                var responseData :NSData
                responseData = response.data! as NSData
                let iDataLength = responseData.length
                
                print("Size: \(iDataLength)")
                return completion(true)
            }
            return completion(false)
        }
        
    }
}

struct TaskListResponseModel {
    var success = false
    var errorMessage: String?
    var successMessage: String?
    var data: Any?
}
