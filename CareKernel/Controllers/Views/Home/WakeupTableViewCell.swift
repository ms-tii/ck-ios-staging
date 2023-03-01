//
//  WakeupTableViewCell.swift
//  CareKernel
//
//  Created by Mohit Sharma on 02/08/22.
//

import UIKit

protocol WakeupCellDelegate: class {
    func cellButtontapped(_ tag: Int, title: String)
}

class WakeupTableViewCell: UITableViewCell {

    @IBOutlet weak var startAtLabel: UILabel!
    @IBOutlet weak var endAtLabel: UILabel!
    @IBOutlet weak var startEditButton: UIButton!
    @IBOutlet weak var endEditButton: UIButton!
    @IBOutlet weak var reasonTextView: UITextView!
    @IBOutlet weak var submitBUtton: UIButton!
    
    weak var delegate: WakeupCellDelegate?
    var parentViewController: UIViewController? = nil
    
    static func nib() -> UINib {
       
            return UINib(nibName: "WakeupTableViewCell", bundle: nil)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    @IBAction func startEditButtonAction(_ sender: UIButton) {
        delegate?.cellButtontapped(sender.tag, title: "Start")
    }
    
    @IBAction func endEditButtonAction(_ sender: UIButton) {
        delegate?.cellButtontapped(sender.tag, title: "End")
    }
    
    @IBAction func submitButtonAction(_ sender: UIButton) {
        delegate?.cellButtontapped(sender.tag, title: "Submit")
    }
}
