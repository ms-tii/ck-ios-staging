//
//  LoginModel.swift
//  CareKernel
//
//  Created by MAC PC on 21/09/21.
//

import Foundation
struct UserLoginModel: Codable{
    
    let email: String?
    let password: String?
    
    enum CodingKeys: String, CodingKey{
        case email = "email"
        case password = "password"
    }
    
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        email = try values.decodeIfPresent(String.self, forKey: .email)
        password = try values.decodeIfPresent(String.self, forKey: .password)
    }
}

struct LoginResponseModel {
    var success = false
    var errorMessage: String?
    var successMessage: String?
    var token: String?
}

// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let scope = try? newJSONDecoder().decode(Scope.self, from: jsonData)


// MARK: - Scope
struct Scope: Codable {
    var basicDetail: BasicDetail?
    var goals: CaseNotes?
    var caseNotes: CaseNotes?
    var healthConditions: CaseNotes?
    var incidents: CaseNotes?
    var medicalDetails: CaseNotes?
    var medications: CaseNotes?
    var risks: CaseNotes?
    
    
    enum CodingKeys: String, CodingKey {
        case basicDetail = "Basic Details"
        case goals = "Goals"
        case caseNotes = "Case Notes"
        case healthConditions = "Health Conditions"
        case incidents = "Incidents"
        case medicalDetails = "Medical Details"
        case medications = "Medications"
        case risks = "Risks"
        
    }
}

// MARK: - BasicDetail
struct BasicDetail: Codable {
    var access: Bool?
    var viewPermision: BasicDetailViewPermision?
    
    enum CodingKeys: String, CodingKey {
        case access
        case viewPermision
    }
}

// MARK: - BasicDetailViewPermision
struct BasicDetailViewPermision: Codable {
    var dob: Bool?
    var gender: Bool?
    var email: Bool?
    var phone: Bool?
    var language: Bool?
    var fullAddress: Bool?
    var religion: Bool?
    var nationality: Bool?
    
    enum CodingKeys: String, CodingKey {
        case dob = "dob"
        case gender = "gender"
        case email = "email"
        case phone = "phone"
        case language = "language"
        case fullAddress = "fullAddress"
        case religion = "religion"
        case nationality = "nationality"
    }
}

// MARK: - CaseNotes
struct CaseNotes: Codable {
    var access: Bool?
    var viewPermision: CaseNotesViewPermision?
    
    enum CodingKeys: String, CodingKey {
        case access
        case viewPermision
    }
}

// MARK: - CaseNotesViewPermision
struct CaseNotesViewPermision: Codable {
}
