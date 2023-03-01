//
//  NotificationViewModel.swift
//  CareKernel
//
//  Created by Mohit Sharma on 21/01/22.
//

import Foundation
import SwiftyJSON
import Alamofire

struct NotificationViewModel : Codable {
    var token: String?
}


extension NotificationViewModel {
    func getNotificationList(completion: @escaping (JSON, Bool) -> Void){
        
        AFWrapper.sharedInstance.updateJSONHeader(token: self.token ?? "")
        guard let _ = careKernelDefaults.object(forKey: kUserId) else {
            return()
        }
        
        let clientURL = notificationURL
        AFWrapper.sharedInstance.sendRequest(url: clientURL, method: .get) { statusCode, response in
            
            return completion(response,true)
        } fail: { statusCode, error, response in
            print(error)
            return completion(response,false)
        }
    }
    
    func updateNotificationStatus(isRead: Bool, notificationId: Int, completion: @escaping (JSON, Bool) -> Void){
        let apiURL = baseURL + "notifications/" + "\(notificationId)"
        let params = ["isRead":isRead]
        AFWrapper.sharedInstance.sendRequest(url: apiURL, method: .patch, parameters: params) { statusCode, response in
            return completion(response,true)
        } fail: { statusCode, error, response in
            return completion(response,false)
        }

    }
}
