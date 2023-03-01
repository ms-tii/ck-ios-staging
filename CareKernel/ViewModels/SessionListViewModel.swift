//
//  SessionListViewModel.swift
//  CareKernel
//
//  Created by Mohit Sharma on 15/10/21.
//

import Foundation
import SwiftyJSON

struct SessionsViewModel: Codable{
    var token: String?
    var startDate: String!
    var endDate: String!
}

extension SessionsViewModel{
    
    
    func getSessionList(startDate: String, endDate: String, offset: String, limit: String, completion: @escaping (JSON, Bool) -> Void){
        
        AFWrapper.sharedInstance.updateJSONHeader(token: self.token ?? "")
        guard let _ = careKernelDefaults.object(forKey: kUserId) else {
            return()
        }
//        var characters = NSCharacterSet.URLHostAllowedCharacterSet.mutableCopy() as NSMutableCharacterSet
        var characters = CharacterSet.urlHostAllowed
        characters.remove(charactersIn: "+")
        let encodeStartDate = URL(encoding: startDate)?.absoluteString
        let encodedEndDate = URL(encoding: endDate)?.absoluteString
        let finalEncodeStartDate = encodeStartDate!.replacingOccurrences(of: "+", with: "%2b")
        let finalEncodedEndDate = encodedEndDate!.replacingOccurrences(of: "+", with: "%2b")
        let sessionUrl = sessionsListURL + "\(String(describing: careKernelDefaults.value(forKey: kUserId)!))" + "&startDate=\(String(describing: finalEncodeStartDate))" + "&endDate=\(String(describing: finalEncodedEndDate))" + "&sort=-startDate&offset=\(offset)&limit=\(limit)"
        print(sessionUrl)
        let requestUrl = URL(encoding: sessionUrl)
        AFWrapper.sharedInstance.sendRequest(url: sessionUrl, method: .get, parameters: nil) {statusCode, response  in
            
            
            return completion(response, true)
            
        } fail: { statusCode, error, response in
            print(error)
            return completion(response, false)
            
        }

    }
    
    
    func getSessionDetails(sessionId: Int, completion: @escaping (JSON, Bool) -> Void) {
        
        AFWrapper.sharedInstance.updateJSONHeader(token: self.token ?? "")
        let detailsURL = sessionDetailsURL + "\(sessionId)"
        AFWrapper.sharedInstance.sendRequest(url: detailsURL, method: .get) { statusCode, response in
            return completion(response, true)
        } fail: { statusCode, error, response in
            return completion(response, false)
        }
        
    }
    
    func getSessionTasks(sessionId: Int, completion: @escaping (JSON, Bool) -> Void){
        let url = sessionsURL + "/\(sessionId)" + "/session-tasks/"
        AFWrapper.sharedInstance.sendRequest(url: url, method: .get) { statusCode, response in
            return completion(response, true)
        } fail: { statusCode, error, response in
            return completion(response, false)
        }

    }
}
