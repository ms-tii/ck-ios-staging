//
//  StringValidationsExtension.swift
//  CareKernel
//
//  Created by Mohit Sharma on 02/09/21.
//

import Foundation


/// String Extension
extension String{
    
    /**
     Check if Text Empty Method
     
     - Returns: Boolean value
     
    */
    func isTextEmpty() -> Bool {
        let afterText = trimWhiteSpaceFromText()
        if afterText.isEmpty{
            return true
        }
        return false
    }
    
    /**
     Check if Email is valid
     
     - Returns: Boolean value
     
    */
    func isValidEmail() -> Bool {
        if !isTextEmpty(){
            let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"
            return applyPredicateOnRegex(regexStr: emailRegEx)
        }
        return false
    }
    
    func isValidPassword(mini: Int = 8, max: Int = 10) -> Bool {
        //Minimum 8 characters at least 1 Alphabet and 1 Number:
        var passRegEx = ""
//        if mini >= max{
//            passRegEx = "^(?=.*[A-Za-z])(?=.*\\d)[A-Za-z\\d]{\(mini),}$"
//        }else{
//            passRegEx = "^(?=.*[A-Za-z])(?=.*\\d)[A-Za-z\\d]{\(mini),\(max)}$"
//        }
        passRegEx = "(?=[^a-z]*[a-z])(?=[^0-9]*[0-9])[a-zA-Z0-9!@#$%^&*]{\(mini),}"
        return applyPredicateOnRegex(regexStr: passRegEx)
    }
    
    /**
     Trim WhiteSpace from text
     
     - Returns: Trimmed String value
     
    */
    func trimWhiteSpaceFromText() -> String {
        return (self.trimmingCharacters(in: CharacterSet.whitespaces))
    }
    
    
    func applyPredicateOnRegex(regexStr: String) -> Bool{
        let trimmedString = self.trimmingCharacters(in: .whitespaces)
        let validateOtherString = NSPredicate(format: "SELF MATCHES %@", regexStr)
        let isValidateOtherString = validateOtherString.evaluate(with: trimmedString)
        return isValidateOtherString
    }
}
extension String {
    func htmlAttributedString() -> NSAttributedString? {
        guard let data = self.data(using: .utf8) else {
            return nil
        }

        return try? NSAttributedString(
            data: data,
            options: [.documentType: NSAttributedString.DocumentType.html],
            documentAttributes: nil
        )
    }
}
extension URL {
    init?(encoding string: String) {
        let encodedString = string
            .addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)?
            .replacingOccurrences(of: "%20", with: "+")
//        guard case let encodedString != nil else { return nil }
        self.init(string: encodedString!)
    }
}
