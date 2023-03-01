//
//  UserSignUpModel.swift
//  CareKernel
//
//  Created by MAC PC on 21/09/21.
//

import Foundation
struct UserSignUp: Codable{
    
    let token: String
//    let password: String
    
    enum CodingKeys: String, CodingKey {
        case token = "token"
//        case password = "password"
    }
    
    init(_ userSignUp: UserSignUpViewModel) {
        guard let token = userSignUp.token
//              let password = userSignUp.password
        else {
            fatalError()
        }
        self.token = token
//        self.password = password
    }
}

extension UserSignUp{
    
    static func signUp(userSignUpDetails: UserSignUpViewModel) -> Resource<UserSignUp?>{
        let userSignUp = UserSignUp(userSignUpDetails)
        
        guard let url = URL(string: verifyUrl) else {
            fatalError("URL is incorrect!")
        }
        
        guard let data = try? JSONEncoder().encode(userSignUp) else {
            fatalError("Error encoding order!")
        }
        
        var resource = Resource<UserSignUp?>(url: url)
        resource.httpMethod = HttpMethod.post
        resource.body = data
        
        return resource
    }
}
