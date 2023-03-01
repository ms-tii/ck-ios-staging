//
//  Storage.swift
//  CareKernel
//
//  Created by Mohit Sharma on 20/12/21.
//

import Foundation
/// Storage Class - CRUD for file storage (in & from Document Directory)
public class Storage {
    
    fileprivate init() { }
    
    /**
     My own Directory options.
     
     ````
     case documents
     case caches
     ````
     */
    enum Directory {
        // Only documents and other data that is user-generated, or that cannot otherwise be recreated by your application, should be stored in the <Application_Home>/Documents directory and will be automatically backed up by iCloud.
        case documents
        
        // Data that can be downloaded again or regenerated should be stored in the <Application_Home>/Library/Caches directory. Examples of files you should put in the Caches directory include database cache files and downloadable content, such as that used by magazine, newspaper, and map applications.
        case caches
    }
    
    /**
     Returns URL constructed from specified directory
     
     - Parameters:
     - directory: where the struct is stored
     
     - Returns: Document directory path as URL
     
     */
    static func getURL(for directory: Directory) -> URL {
        var searchPathDirectory: FileManager.SearchPathDirectory
        
        switch directory {
        case .documents:
            searchPathDirectory = .documentDirectory
        case .caches:
            searchPathDirectory = .cachesDirectory
        }
        
        if let url = FileManager.default.urls(for: searchPathDirectory, in: .allDomainsMask).first {
            return url
        } else {
            // if any error occured while accessing path url for File
            fatalError("Could not create URL for specified directory!")
        }
    }
    
    
    /**
     Store an encodable struct to the specified directory on disk
     
     - Parameters:
     - object: the encodable struct to store
     - directory: where to store the struct
     - fileName: what to name the file where the struct data will be stored
     
     */
    static func store<T: Encodable>(_ object: T, to directory: Directory, as fileName: String) {
        let url = getURL(for: directory).appendingPathComponent(fileName, isDirectory: false)
        
        let encoder = JSONEncoder()
        do {
            let data = try encoder.encode(object)
            if FileManager.default.fileExists(atPath: url.path) {
                try FileManager.default.removeItem(at: url)
            }
            FileManager.default.createFile(atPath: url.path, contents: data, attributes: nil)
//            print("Data saved here -\(url.path)")
        } catch {
            fatalError(error.localizedDescription)
        }
    }
    
    /**
     Retrieve and convert a struct from a file on disk
     
     - Parameters:
     - fileName: name of the file where struct data is stored
     - directory: directory where struct data is stored
     - type: struct type (i.e. Message.self)
     
     - Returns: decoded struct model(s) of data
     */
    static func retrieve<T: Decodable>(_ fileName: String, from directory: Directory, as type: T.Type?) -> T {
        let url = getURL(for: directory).appendingPathComponent(fileName, isDirectory: false)
        
        if !FileManager.default.fileExists(atPath: url.path) {
            fatalError("File at path \(url.path) does not exist!")
        }
        
        if let data = FileManager.default.contents(atPath: url.path) {
            let decoder = JSONDecoder()
            do {
                let model = try decoder.decode(type!, from: data)
                return model
            } catch {
                fatalError(error.localizedDescription)
            }
        } else {
            fatalError("No data at \(url.path)!")
        }
    }
    
    static func readingFromDD(from directory: Directory, fileName: String) -> Data{
        let url = getURL(for: directory).appendingPathComponent(fileName, isDirectory: false)
        
        if !FileManager.default.fileExists(atPath: url.path) {
            print("File at path \(url.path) does not exist!")
            
            fatalError("File at path \(url.path) does not exist!")
        }
        
        if let data = FileManager.default.contents(atPath: url.path) {
            return data
        }else {
            print("No data at \(url.path)!")
            fatalError("No data at \(url.path)!")
        }
    }
    
    /**
     Write a struct to file on disk
     
     - Parameters:
     - data: data that need to write to URL
     - documentsURL: Path URL of document
     - completion: Completion Handler for writing data to file
     
     */    static func writeToFile(_ data: Data, documentsURL: URL, completion: @escaping (Bool) -> Void){
        do {
            try data.write(to: documentsURL)
            completion(true)
        } catch {
//            print("Something went wrong!")
            completion(false)
        }
    }
    
    /**
     Remove all files at specified directory
     
     - Parameters:
     - directory: directory where struct data is stored
     
     */
    static func clear(_ directory: Directory) {
        let url = getURL(for: directory)
        do {
            let contents = try FileManager.default.contentsOfDirectory(at: url, includingPropertiesForKeys: nil, options: [])
            for fileUrl in contents {
                try FileManager.default.removeItem(at: fileUrl)
            }
        } catch {
            fatalError(error.localizedDescription)
        }
    }
    
    /**
     Remove specified file from specified directory
     
     - Parameters:
     - fileName: name of the file stored in document directory
     - directory: directory where struct data is stored
     */
    static func remove(_ fileName: String, from directory: Directory) {
        let url = getURL(for: directory).appendingPathComponent(fileName, isDirectory: false)
        if FileManager.default.fileExists(atPath: url.path) {
            do {
                try FileManager.default.removeItem(at: url)
            } catch {
                fatalError(error.localizedDescription)
            }
        }
    }
    
    /**
     Check for the file existence
     
     - Parameters:
     - fileName: name of the file stored in document directory
     - directory: directory where struct data is stored
     
     - Returns: BOOL indicating whether file exists at specified directory with specified file name
     */    static func fileExists(_ fileName: String, in directory: Directory) -> Bool {
        let url = getURL(for: directory).appendingPathComponent(fileName, isDirectory: false)
        return FileManager.default.fileExists(atPath: url.path)
    }
}
//Retrive from Disk
//let messagesFromDisk = Storage.retrieve("messages.json", from: .documents, as: [Message].self)

// Remove messages.json from Documents Directory
//Storage.remove("messages.json", from: .documents)

// Or just clear the Documents Directory entirely
//Storage.clear(.documents)

// We can even check if our file exists in the specified directory
//if Storage.fileExists("messages.json", in: .documents) {
//    // we have messages to retrieve
//}
