//
//  UIViewControllerExtension.swift
//  CareKernel
//
//  Created by MAC PC on 02/10/21.
//

import UIKit

extension UIViewController {
    func showAlert(_ title: String, message: String, actions: [String], completion: @escaping ((String) -> Void)) {
        let controller = UIAlertController.init(title: title, message: message, preferredStyle: .alert)
        for title in actions {
            controller.addAction(UIAlertAction.init(title: title, style: .default, handler: { _ in
                completion(title)
            }))
        }
        self.present(controller, animated: true, completion: nil)
    }
    //Set message allignement to left or right
    func showAlertAlligned(_ title: String, message: String, actions: [String], completion: @escaping ((String) -> Void)) {
        let alertController = UIAlertController(title: title, message:
                message, preferredStyle: .alert)
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = NSTextAlignment.left
            let attributedMessage: NSMutableAttributedString = NSMutableAttributedString(
                string: message, // your string message here
                attributes: [
                    NSAttributedString.Key.paragraphStyle: paragraphStyle,
                    NSAttributedString.Key.font: UIFont.systemFont(ofSize: 13.0)
                ]
            )
            alertController.setValue(attributedMessage, forKey: "attributedMessage")

            alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: {action in

            }))
            self.present(alertController, animated: true, completion: nil)
    }
    //Set background color of UIAlertController
        func setBackgroundColor(color: UIColor) {
            if let bgView = self.view.subviews.first, let groupView = bgView.subviews.first, let contentView = groupView.subviews.first {
                contentView.backgroundColor = color
            }
        }
        
        //Set title font and title color
        func setTitlet(font: UIFont?, color: UIColor?) {
            guard let title = self.title else { return }
            let attributeString = NSMutableAttributedString(string: title)//1
            if let titleFont = font {
                attributeString.addAttributes([NSAttributedString.Key.font : titleFont],//2
                                              range: NSMakeRange(0, title.utf8.count))
            }
            
            if let titleColor = color {
                attributeString.addAttributes([NSAttributedString.Key.foregroundColor : titleColor],//3
                                              range: NSMakeRange(0, title.utf8.count))
            }
            self.setValue(attributeString, forKey: "attributedTitle")//4
        }
        
        //Set message font and message color
        func setMessage(font: UIFont?, color: UIColor?, message: String) {
//            guard let message = self.message else { return }
            let attributeString = NSMutableAttributedString(string: message)
            if let messageFont = font {
                attributeString.addAttributes([NSAttributedString.Key.font : messageFont],
                                              range: NSMakeRange(0, message.utf8.count))
            }
            
            if let messageColorColor = color {
                attributeString.addAttributes([NSAttributedString.Key.foregroundColor : messageColorColor],
                                              range: NSMakeRange(0, message.utf8.count))
            }
            self.setValue(attributeString, forKey: "attributedMessage")
        }
        
        //Set tint color of UIAlertController
        func setTint(color: UIColor) {
            self.view.tintColor = color
        }
}
extension UIView{
    func addConstraintsWithFormat(format: String, views: UIView...) {
            
            var viewsDict = [String: UIView]()
            
            for (index, view) in views.enumerated() {
                
                view.translatesAutoresizingMaskIntoConstraints = false
                viewsDict["v\(index)"] = view
            }
            
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: format, options: NSLayoutConstraint.FormatOptions(), metrics: nil, views: viewsDict))
        }
    
    
}
extension UIColor{
    
    
    public convenience init?(hex: String) {
            let r, g, b, a: CGFloat

            if hex.hasPrefix("#") {
                let start = hex.index(hex.startIndex, offsetBy: 1)
                let hexColor = String(hex[start...])

                if hexColor.count == 8 {
                    let scanner = Scanner(string: hexColor)
                    var hexNumber: UInt64 = 0

                    if scanner.scanHexInt64(&hexNumber) {
                        r = CGFloat((hexNumber & 0xff000000) >> 24) / 255
                        g = CGFloat((hexNumber & 0x00ff0000) >> 16) / 255
                        b = CGFloat((hexNumber & 0x0000ff00) >> 8) / 255
                        a = CGFloat(hexNumber & 0x000000ff) / 255

                        self.init(red: r, green: g, blue: b, alpha: a)
                        return
                    }
                }
            }

            return nil
        }
}
