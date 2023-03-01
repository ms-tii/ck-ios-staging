//
//  AFWrapper.swift
//  CareKernel
//
//  Created by MAC PC on 30/09/21.
//

import Foundation
import  Alamofire
import  SwiftyJSON



class AFWrapper : NSObject {
    enum HttpMethod: String {
        case get = "GET"
        case post = "POST"
        case put = "PUT"
        case patch = "PATCH"
    }
    static let sharedInstance = AFWrapper()
        
    internal typealias SuccessCompletion = (Int?, JSON) -> Void?
    internal typealias FailCompletion = (Int?, Error, JSON) -> Void?
    var sessionManager : Session!
    var request : Request?
    var headers : HTTPHeaders! = [:]
    
    
    override init() {
        let configuration = URLSessionConfiguration.af.default
        configuration.headers = .default
        configuration.timeoutIntervalForRequest = 30
        sessionManager = Session(configuration: configuration)
    }
    func updateJSONHeader(token: String) {
        headers = [:]
        headers["Content-Type"] = "application/json"
        headers["Authorization"] = "Bearer \(token)"
    }
    
    func sendRequest(url: String?, method: HTTPMethod, parameters: Parameters? = nil, success: SuccessCompletion?, fail: FailCompletion?){
        var encoding : ParameterEncoding!
        if  method == HTTPMethod.post || method == HTTPMethod.put || method == HTTPMethod.patch{
            encoding = JSONEncoding.default
        } else {
            encoding = URLEncoding.default
        }
        print(url ?? "", method, parameters ?? "", headers ?? "")
        request = sessionManager.request(url ?? "", method: method, parameters: parameters, encoding: encoding, headers: headers)
            .validate()
            .responseData(emptyResponseCodes: [200, 204, 205]){response in
                print(response)
                switch (response.result) {
                case .success(let value):
                    let statusCode = response.response?.statusCode
                    success?(statusCode, JSON(value))
                    self.request = nil
                    break
                case .failure(let error):
                    let statusCode = response.response?.statusCode
                    let json = JSON(response.data as Any)
                    fail?(statusCode, error, json)
                    self.request = nil
                    break
                }
            }
    }
    
    func sendPatchRequest(url: String?, method: HTTPMethod, parameters: Parameters? = nil, success: SuccessCompletion?, fail: FailCompletion?){
        var encoding : ParameterEncoding!
        encoding = JSONEncoding.default
        print(url ?? "", method, parameters ?? "", headers ?? "")
        request = sessionManager.request(url ?? "", method: method, parameters: parameters, encoding: encoding, headers: headers)
            .validate()
            .responseData(emptyResponseCodes: [200, 204, 205]){response in
                print(response)
                switch (response.result) {
                case .success(let value):
                    let statusCode = response.response?.statusCode
                    success?(statusCode, JSON(value))
                    self.request = nil
                    break
                case .failure(let error):
                    let statusCode = response.response?.statusCode
                    let json = JSON(response.data as Any)
                    fail?(statusCode, error, json)
                    self.request = nil
                    break
                }
            }
    }
}

