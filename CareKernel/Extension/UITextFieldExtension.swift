//
//  UITextFieldExtension.swift
//  CareKernel
//
//  Created by Mohit Sharma on 08/09/21.
//

import Foundation
import UIKit


extension UITextField {
    
    /**
     Add Shadow To TextField - this method adds shadown to textfield
     
     - Parameters:
     - color: parameter of gray color
     - cornerRadius: radius of data type CGFloat
     */
    func addShadowToTextField(color: UIColor = UIColor.gray, cornerRadius: CGFloat) {
        
        self.backgroundColor = UIColor.white
        self.layer.masksToBounds = false
        self.layer.shadowColor = color.cgColor
        self.layer.shadowOffset = CGSize(width: 0, height: 0)
        self.layer.shadowOpacity = 0.4
        self.layer.shadowRadius = 2
        self.backgroundColor = .white
        self.layer.cornerRadius = cornerRadius
    }
    
    
    /**
     Instance of hasValidEmail - Bool type that returns if the email is valid or not
     */
    public var hasValidEmail: Bool {
        return text!.range(of: "(?:[a-z0-9!#$%\\&'*+/=?\\^_`{|}~-]+(?:\\.[a-z0-9!#$%\\&'*+/=?\\^_`{|}" +
            "~-]+)*|\"(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21\\x23-\\x5b\\x5d-\\" +
            "x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])*\")@(?:(?:[a-z0-9](?:[a-" +
            "z0-9-]*[a-z0-9])?\\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?|\\[(?:(?:25[0-5" +
            "]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-" +
            "9][0-9]?|[a-z0-9-]*[a-z0-9]:(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21" +
            "-\\x5a\\x53-\\x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])+)\\])",
                           options: String.CompareOptions.regularExpression,
                           range: nil, locale: nil) != nil
    }
    
    /**
     Set Left Padding Points Method - To give space at left side
     
     - Parameters:
     - amount: value of data type CGFloat
     
     */
    func setLeftPaddingPoints(_ amount:CGFloat){
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        self.leftView = paddingView
        self.leftViewMode = .always
    }
    
    /**
     Set Right Padding Points Method - To give space at right side
     
     - Parameters:
     - amount: value of data type CGFloat
     
     */
    func setRightPaddingPoints(_ amount:CGFloat) {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        self.rightView = paddingView
        self.rightViewMode = .always
    }
    
    //Select TextField in Storyboard and in Attributes Inspector, you will find a new option for placeholder color
    @IBInspectable var placeHolderColor: UIColor? {
        get {
            return self.placeHolderColor
        }
        set {
            self.attributedPlaceholder = NSAttributedString(string:self.placeholder != nil ? self.placeholder! : "", attributes:[NSAttributedString.Key.foregroundColor: newValue!])
        }
    }

    func setCorner(radius: CGFloat) {
          layer.cornerRadius = radius
          clipsToBounds = true
      }
    
    func setBorder(width: CGFloat, color: UIColor) {
            layer.borderColor = color.cgColor
            layer.borderWidth = width
        }
    
    func addBottomBorder(color: UIColor){
            let bottomLine = CALayer()
            bottomLine.frame = CGRect(x: 0, y: self.frame.size.height - 1, width: self.frame.size.width, height: 1)
            bottomLine.backgroundColor = color.cgColor
            borderStyle = .none
            layer.addSublayer(bottomLine)
        }
    
}

class UIShowHideTextField: UITextField {

    let rightButton  = UIButton(type: .custom)

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    required override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    func commonInit() {
        rightButton.setImage(UIImage(named: "icon-password-hide") , for: .normal)
        rightButton.addTarget(self, action: #selector(toggleShowHide), for: .touchUpInside)
        rightButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: -16, bottom: 0, right: 0)
        rightButton.frame = CGRect(x:0, y:0, width:24, height:24)

        rightViewMode = .always
        rightView = rightButton
        isSecureTextEntry = true
        self.rightView = rightButton
        self.rightViewMode = .always
    }

    @objc
    func toggleShowHide(button: UIButton) {
        toggle()
    }

    func toggle() {
        isSecureTextEntry = !isSecureTextEntry
        if isSecureTextEntry {
            rightButton.setImage(UIImage(named: "icon-password-hide") , for: .normal)
        } else {
            rightButton.setImage(UIImage(named: "icon-password-show") , for: .normal)
        }
    }
}

extension UIButton {
    
    func addBorderCorner(cornerRadius: CGFloat, borderColor: UIColor = .clear, borderWidth: CGFloat = 0){
        self.layer.borderColor = borderColor.cgColor
        self.layer.borderWidth = borderWidth
        self.layer.cornerRadius = cornerRadius
        self.layer.masksToBounds = true
    }
}
extension UILabel {
    func setMargins(_ margin: CGFloat = 10) {
            if let textString = self.text {
                let paragraphStyle = NSMutableParagraphStyle()
                paragraphStyle.firstLineHeadIndent = margin
                paragraphStyle.headIndent = margin
                paragraphStyle.tailIndent = -margin
                let attributedString = NSMutableAttributedString(string: textString)
                attributedString.addAttribute(.paragraphStyle, value: paragraphStyle, range: NSRange(location: 0, length: attributedString.length))
                attributedText = attributedString
            }
        }
}

class ButtonWithProperty: UIButton {

    var isRead: Bool = false {
        didSet {
            setBadge()
        }
    }

    var isBadgeShow: Bool = false {
        didSet {
            showBadge()
        }
    }
    lazy var badgeView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 4
        view.backgroundColor = .red
        return view
    }()

    func showBadge() {
        addSubview(badgeView)
        badgeView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            badgeView.rightAnchor.constraint(equalTo: rightAnchor, constant: -9),
            badgeView.topAnchor.constraint(equalTo: topAnchor, constant: 7),
            badgeView.heightAnchor.constraint(equalToConstant: badgeView.layer.cornerRadius*2),
            badgeView.widthAnchor.constraint(equalToConstant: badgeView.layer.cornerRadius*2)
        ])

        setBadge()
    }

    func setBadge() {
        badgeView.isHidden = isRead
    }

}
class LabelWithProperty: UILabel {

   
    lazy var badgeView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 4
        view.backgroundColor = .red
        return view
    }()

    func showBadge(color: UIColor) {
        addSubview(badgeView)
        badgeView.backgroundColor = color
        badgeView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            badgeView.rightAnchor.constraint(equalTo: leftAnchor, constant: -4),
            badgeView.topAnchor.constraint(equalTo: topAnchor, constant: 5),
            badgeView.heightAnchor.constraint(equalToConstant: badgeView.layer.cornerRadius*2),
            badgeView.widthAnchor.constraint(equalToConstant: badgeView.layer.cornerRadius*2)
        ])
    }

}
