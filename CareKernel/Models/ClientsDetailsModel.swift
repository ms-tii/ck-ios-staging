//
//  ClientsDetailsModel.swift
//  CareKernel
//
//  Created by Mohit Sharma on 28/10/21.
//

import Foundation

struct ClientDetailsResponseModel {
    var success = false
    var errorMessage: String?
    var successMessage: String?
    var data: [Any]?
    var meta: [String:Any]?
}
