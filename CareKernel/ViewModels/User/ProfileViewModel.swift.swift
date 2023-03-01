//
//  ProfileViewModel.swift.swift
//  CareKernel
//
//  Created by Mohit Sharma on 07/12/21.
//

import Foundation
import SwiftyJSON
import Alamofire


struct ProfileViewModel {
    var token : String!
    var workerId: Int!
}

extension ProfileViewModel {
    
    func getWorkerDetails(completion: @escaping (JSON, Bool) -> Void) {
        
        AFWrapper.sharedInstance.updateJSONHeader(token: self.token)
        let url = profileURL + "\(String(describing: workerId!))"
        AFWrapper.sharedInstance.sendRequest(url: url, method: .get) { statusCode, response in
            return completion(response, true)
        } fail: { statusCode, error, response in
            return completion(response,false)
        }

    }
    
    func updateName(params: [String:Any], completion: @escaping (JSON, Bool) -> Void){
        AFWrapper.sharedInstance.updateJSONHeader(token: self.token)
        let url = profileURL + "\(String(describing: workerId!))"
        AFWrapper.sharedInstance.sendRequest(url: url, method: .put, parameters: params) { statusCode, response in
            return completion(response, true)
        } fail: { statusCode, error, response in
            return completion(response,false)
        }

    }
    
    func uploadPicture(fileName: String, fileData: Data, completion: @escaping (Bool) -> Void) {
        guard let token = careKernelDefaults.value(forKey: kLoginToken) as? String else {
            careKernelDefaults.set(false, forKey: kIsLoggedIn)
            return }
        var bodyKeyValue = [RequestBodyFormDataKeyValue]()
        
        let url = profileURL + "\(String(describing: workerId!))" + "/avatar"
        
        
        bodyKeyValue.append(RequestBodyFormDataKeyValue(skey: "file", sValue: fileName, dbloadData: fileData))
        
        
        
        AF.upload(multipartFormData:{ multipartFormdta in
            
            for formData in bodyKeyValue {
                if formData.dbloadData.isEmpty {
                    multipartFormdta.append(Data(formData.sValue.utf8), withName: formData.skey)
                }else{
                    multipartFormdta.append(fileData as Data, withName: formData.skey, fileName: fileName, mimeType: "image/jpg")
                }
                
                
            }
        }, to: url,method: .patch, headers: ["Authorization": "Bearer \(token)"])
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
