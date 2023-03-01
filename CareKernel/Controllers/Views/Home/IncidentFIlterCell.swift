//
//  IncidentFIlterCell.swift
//  CareKernel
//
//  Created by Mohit Sharma on 17/02/22.
//

import UIKit

class IncidentFIlterCell: UITableViewCell {

    
    @IBOutlet var fromButton: UIButton!
    @IBOutlet var toButton: UIButton!
    @IBOutlet var clearButton: UIButton!
    @IBOutlet var applyButton: UIButton!
    
    static let identifire = "IncidentFIlterCell"
//    weak var delegate: IncidentHeaderDelegate?
    var indexPath: IndexPath?
    var parentViewController: UIViewController? = nil
    
    static func nib() -> UINib {
        
            return UINib(nibName: "IncidentFIlterCell", bundle: nil)
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
