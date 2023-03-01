//
//  UserSignUpViewModel.swift
//  CareKernel
//
//  Created by MAC PC on 21/09/21.
//

import Foundation


struct UserSignUpViewModel: Codable{
    
    var token: String?
//    var password: String!
}

extension UserSignUpViewModel{
    
    func isSignUpDetailsValid()-> String{
        
        guard token != "" else {
            return "Token cannot be empty"
        }
        if self.token!.count <= 6{
            return "Token cannot be less then 6 digit"
        }else{
            return "Valid"
        }
    }
}
