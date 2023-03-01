//
//  DropDownCell.swift
//  CareKernel
//
//  Created by Mohit Sharma on 11/11/21.
//

import UIKit

class DropDownCell: UITableViewCell {

    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var tickImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
