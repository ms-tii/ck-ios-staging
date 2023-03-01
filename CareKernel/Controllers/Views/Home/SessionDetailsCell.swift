//
//  SessionDetailsCellTableViewCell.swift
//  CareKernel
//
//  Created by Mohit Sharma on 26/10/21.
//

import UIKit

class SessionDetailsCell: UITableViewCell {

    @IBOutlet var label: UILabel!
    @IBOutlet var label2: UILabel!
    
//    var data: cellData? {
//        didSet {
//            guard let data = data else {
//                return
//            }
//            self.label.text = data.title
//            self.label2.text = data.childItems[<#Int#>]
//        }
//    }
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        animateCell()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func animateCell(){
        UIView.animate(withDuration: 0.5, delay: 0.3, usingSpringWithDamping: 0.8, initialSpringVelocity: 1, options: .curveEaseIn) {
            self.contentView.layoutIfNeeded()
        }

    }
}

