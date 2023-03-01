//
//  CasenotesHeaderCell.swift
//  CareKernel
//
//  Created by Mohit Sharma on 26/11/21.
//

import UIKit

class CasenotesHeaderCell: UITableViewHeaderFooterView {

    @IBOutlet var iconImageView: UIImageView!
    @IBOutlet var headerTitleLabel: UILabel!
    
    
    static func nib() -> UINib {
        
            return UINib(nibName: "CasenotesHeaderCell", bundle: nil)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }


    
}
