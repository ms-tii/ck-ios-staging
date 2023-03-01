//
//  FiltersViewModel.swift
//  CareKernel
//
//  Created by Mohit Sharma on 23/11/21.
//

import Foundation
import SwiftyJSON

struct FiltersViewModel {
    var token : String!
    
}

extension FiltersViewModel {
    
    func getCategories(completion: @escaping (JSON, Bool) -> Void) {
        AFWrapper.sharedInstance.updateJSONHeader(token: self.token)
        
        AFWrapper.sharedInstance.sendRequest(url: taskCategoriesURL, method: .get, parameters: nil) { statusCode, response in
            
            return completion(response, true)
            
        } fail: { statusCode, error, response in
            return completion(response,false)
        }

    }
    
    
}
