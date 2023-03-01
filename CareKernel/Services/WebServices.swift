//
//  WebServices.swift
//  CareKernel
//
//  Created by Mohit Sharma on 02/09/21.
//

import Foundation
enum NetworkError: Error{
    case decodingError
    case domainError
    case urlError
}

enum HttpMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
}

struct Resource<T: Codable> {
    let url: URL
    var httpMethod: HttpMethod = .get
    var body: Data? = nil
}

struct AnotherResource<T>{
    let url: URL
    let parse: (Data) -> T?

}

extension Resource {
    init(url: URL) {
        self.url = url
    }
}

class WebService {
    
    func load<T>(resource: Resource<T>, completion: @escaping(Result<Dictionary<String, Any>,  NetworkError>) -> Void){
        
        var request = URLRequest(url: resource.url)
        request.httpMethod = resource.httpMethod.rawValue
        request.httpBody = resource.body
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
//        if let userLoginToken = careKernelDefaults.value(forKey: "loginToken"){
//            print(userLoginToken)
//            request.addValue("Bearer \(userLoginToken as! String)", forHTTPHeaderField: "Authorization")
//        }
        
        print(request)
        URLSession.shared.dataTask(with: request){ (data, response, error) in
            guard let data = data, error == nil else{
                completion(.failure(.domainError))
                return
            }
            
            print((response as? HTTPURLResponse)?.statusCode)
            
            let resultDict = try? JSONSerialization.jsonObject(with: data, options: .mutableLeaves) as? Dictionary<String, Any>
                //as? Dictionary<String,Any>
            if resultDict != nil {
                completion(.success(resultDict!))
            } else {
                completion(.failure(.decodingError))
            }
            
        }.resume()
    }
    
    func loadData<T>(resource: AnotherResource<T>, completion: @escaping (T?) -> ()) {
        
        URLSession.shared.dataTask(with: resource.url) { data, response, error in
            
            if let data = data {
                DispatchQueue.main.async {
                     completion(resource.parse(data))
                }
            } else {
                completion(nil)
            }
            
        }.resume()
        
    }
}
