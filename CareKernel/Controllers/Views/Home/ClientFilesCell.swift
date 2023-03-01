//
//  ClientFilesCell.swift
//  CareKernel
//
//  Created by Mohit Sharma on 27/11/21.
//

import UIKit

class ClientFilesCell: UITableViewCell {
    @IBOutlet var idLabel: UILabel!
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var viewLabel: UILabel!
    
    static func nib() -> UINib {
        
            return UINib(nibName: "ClientFilesCell", bundle: nil)
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
