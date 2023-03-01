//
//  KeyboardExtension.swift
//  CareKernel
//
//  Created by Mohit Sharma on 02/09/21.
//

import Foundation
import UIKit

extension UIViewController{
    
    func hideKeyboard(){
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard(){
        self.view.endEditing(true)
    }
}
