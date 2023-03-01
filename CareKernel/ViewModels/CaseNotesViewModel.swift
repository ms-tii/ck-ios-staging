//
//  CaseNotesViewModel.swift
//  CareKernel
//
//  Created by Mohit Sharma on 07/11/21.
//

import Foundation
import SwiftyJSON
import Alamofire
import MobileCoreServices
import UniformTypeIdentifiers

struct CaseViewModel{
    var title: String!
    var description: String!
    var clientId: Int!
    var token: String!
    var recordedAt: String!
    var sessionID: Int?
}

extension CaseViewModel {
    func postSessionCaseNotes( completion: @escaping (CaseNotesResponseModel) -> Void){
        
        let params:[String: Any] = ["title": self.title!,"category": "activity", "description": self.description!, "recordedAt": recordedAt ?? "", "isVisibleToServiceWorker": true, "sessionId":sessionID ?? 0]
        AFWrapper.sharedInstance.updateJSONHeader(token: self.token)
        let url = caseNotesURL + "\(self.clientId!)" + "/case-notes"
        var caseNotesResponse = CaseNotesResponseModel()
        AFWrapper.sharedInstance.sendRequest(url: url, method: .post, parameters: params) { statusCode, response in
            print(response)
            caseNotesResponse.data = response
            caseNotesResponse.success = true
            
            return completion(caseNotesResponse)
        } fail: { statusCode, error, response in
            print(error)
            print(response)
            caseNotesResponse.success = false
            caseNotesResponse.successMessage = response.description
            caseNotesResponse.data = response
            return completion(caseNotesResponse)
        }
        
    }
    func postCaseNotes( completion: @escaping (CaseNotesResponseModel) -> Void){
        
        let params:[String: Any] = ["title": self.title!,"category": "activity", "description": self.description!, "recordedAt": recordedAt ?? "", "isVisibleToServiceWorker": true]
        AFWrapper.sharedInstance.updateJSONHeader(token: self.token)
        let url = caseNotesURL + "\(self.clientId!)" + "/case-notes"
        var caseNotesResponse = CaseNotesResponseModel()
        AFWrapper.sharedInstance.sendRequest(url: url, method: .post, parameters: params) { statusCode, response in
            print(response)
            caseNotesResponse.data = response
            caseNotesResponse.success = true
            
            return completion(caseNotesResponse)
        } fail: { statusCode, error, response in
            print(error)
            print(response)
            caseNotesResponse.success = false
            caseNotesResponse.successMessage = response.description
            caseNotesResponse.data = response
            return completion(caseNotesResponse)
        }
        
    }
    
    func uploadDocuments(fileName: String, fileData: Data, entity: String, entityId: Int, clientID: Int, completion: @escaping (Bool) -> Void) {
        guard let token = careKernelDefaults.value(forKey: kLoginToken) as? String else {
            careKernelDefaults.set(false, forKey: kIsLoggedIn)
            return }
        var bodyKeyValue = [RequestBodyFormDataKeyValue]()
        
        bodyKeyValue.append(RequestBodyFormDataKeyValue(skey: "entity", sValue: "\(entity)", dbloadData: Data()))
        bodyKeyValue.append(RequestBodyFormDataKeyValue(skey: "entityId", sValue: "\(entityId)", dbloadData: Data()))
        bodyKeyValue.append(RequestBodyFormDataKeyValue(skey: "clientId", sValue: "\(clientID)", dbloadData: Data()))
        
        
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
    
    func returnMimeType(fileString :String) -> String {
        let url = NSURL(fileURLWithPath: fileString)
        let pathExtension = url.pathExtension
        
        if let uti = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, pathExtension! as NSString, nil)?.takeRetainedValue() {
            if let mimetype = UTTypeCopyPreferredTagWithClass(uti, kUTTagClassMIMEType)?.takeRetainedValue() {
                return mimetype as String
            }
        }
        return "application/octet-stream"
    }
    
}



struct CaseNotesResponseModel{
    var success = false
    var errorMessage: String?
    var successMessage: String?
    var data: Any?
}

struct RequestBodyFormDataKeyValue {
    var skey: String!
    var sValue: String!
    var dbloadData : Data
}
