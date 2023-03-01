//
//  IncidentViewModel.swift
//  CareKernel
//
//  Created by Mohit Sharma on 17/12/21.
//

import Foundation
import SwiftyJSON
import Alamofire

struct IncidentViewModel : Codable {
    var clientId: Int?
    var token: String?
}

extension IncidentViewModel {
    func getClientIncidentList(fromDate: String, toDate: String, completion: @escaping (JSON, Bool) -> Void){
        
        AFWrapper.sharedInstance.updateJSONHeader(token: self.token ?? "")
        guard let _ = careKernelDefaults.object(forKey: kUserId) else {
            return()
        }
        var fromDateStr = fromDate
        var toDateStr = toDate
        if fromDate == "From"{
            fromDateStr = ""
        }else if toDate == "To"{
            toDateStr = ""
        }
//        ts?clientId=25&startDate=2022-2-9&endDate=2022-2-24&offset=0&limit=15
        let clientURL = incidentsURL  + "\(String(describing: self.clientId!))" + "&startDate=\(fromDateStr)&endDate=\(toDateStr)&offset=0" + "&limit=100"
        AFWrapper.sharedInstance.sendRequest(url: clientURL, method: .get) { statusCode, response in
            
            return completion(response,true)
        } fail: { statusCode, error, response in
            print(error)
            return completion(response,false)
        }
    }
    
    func getCategoryList(completion: @escaping (JSON, Bool) -> Void){
        
        let apiURL = baseURL  + "incident-categories?limit=100&sort=name"
        
        AFWrapper.sharedInstance.sendRequest(url: apiURL, method: .get) { statusCode, response in
            
            return completion(response,true)
        } fail: { statusCode, error, response in
            print(error)
            return completion(response,false)
        }
    }
    
    func getSiteList(completion: @escaping (JSON, Bool) -> Void){
        
        let apiURL = baseURL  + "sites?limit=100"
        
        AFWrapper.sharedInstance.sendRequest(url: apiURL, method: .get) { statusCode, response in
            
            return completion(response,true)
        } fail: { statusCode, error, response in
            print(error)
            return completion(response,false)
        }
    }
    
    func getCategorySiteList(type: String, completion: @escaping (JSON, Bool) -> Void){
        
        let apiURL = baseURL  + type + "?limit=100&sort=name"
        
        AFWrapper.sharedInstance.sendRequest(url: apiURL, method: .get) { statusCode, response in
            
            return completion(response,true)
        } fail: { statusCode, error, response in
            print(error)
            return completion(response,false)
        }
    }
    
    func createIncident(param: [String:Any], completion: @escaping (JSON, Bool) -> Void){
        let apiURL = baseURL + "incidents"
        print(apiURL + "for testing")
        print(param)
        AFWrapper.sharedInstance.sendRequest(url: apiURL, method: .post, parameters: param) { statusCode, response in
            return completion(response,true)
        } fail: { statusCode, error, response in
            return completion(response,false)
        }

    }
    
    func updateIncident(incidentId: Int, param: [String:Any], completion: @escaping (JSON, Bool) -> Void){
        let apiURL = baseURL + "incidents/" + "\(incidentId)"
        print(param)
        AFWrapper.sharedInstance.sendRequest(url: apiURL, method: .put, parameters: param) { statusCode, response in
            return completion(response,true)
        } fail: { statusCode, error, response in
            return completion(response,false)
        }

    }
    
    func uploadDocuments(fileName: String, fileData: Data, entity: String, clientID: Int, entityID: Int, completion: @escaping (Bool) -> Void) {
        guard let token = careKernelDefaults.value(forKey: kLoginToken) as? String else {
            careKernelDefaults.set(false, forKey: kIsLoggedIn)
            return }
        var bodyKeyValue = [RequestBodyFormDataKeyValue]()
        
        bodyKeyValue.append(RequestBodyFormDataKeyValue(skey: "entity", sValue: "\(entity)", dbloadData: Data()))
        bodyKeyValue.append(RequestBodyFormDataKeyValue(skey: "removeExisting", sValue: "\(false)", dbloadData: Data()))
        bodyKeyValue.append(RequestBodyFormDataKeyValue(skey: "clientId", sValue: "\(clientID)", dbloadData: Data()))
        bodyKeyValue.append(RequestBodyFormDataKeyValue(skey: "batchId", sValue: "", dbloadData: Data()))
        bodyKeyValue.append(RequestBodyFormDataKeyValue(skey: "entityId", sValue: "\(entityID)", dbloadData: Data()))
        let url = filesURL
        
        _ = DataResponseSerializer(emptyResponseCodes: Set([200,204,205]))
        
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
