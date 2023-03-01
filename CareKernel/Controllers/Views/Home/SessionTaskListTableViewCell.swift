//
//  SessionTaskListTableViewCell.swift
//  CareKernel
//
//  Created by Mohit Sharma on 08/04/22.
//

import UIKit

protocol SessionTaskListCellDelegate: AnyObject {
    func didTapTaskButton(for cell: SessionTaskListTableViewCell, tag: Int)
}

class SessionTaskListTableViewCell: UITableViewCell {

    weak var delegate: SessionTaskListCellDelegate?
    @IBOutlet weak var tickImageView: UIImageView!
    @IBOutlet weak var taskNameLabel: UILabel!
    @IBOutlet weak var tickButton: UIButton!
    static let identifire = "SessionTaskListCell"
    var dataDict: [String:Any] = [:]
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    static func nib() -> UINib {
        
            return UINib(nibName: "SessionTaskListTableViewCell", bundle: nil)
    }
    

    override func setSelected(_ selected: Bool, animated: Bool) {
            super.setSelected(selected, animated: animated)
//        accessoryType = selected ? UITableViewCell.AccessoryType.checkmark : UITableViewCell.AccessoryType.none
    }
    
    @IBAction func tickButtonAction(_ sender: UIButton) {
        let currentTaskCell = self
        delegate?.didTapTaskButton(for: currentTaskCell, tag: sender.tag)
    }
}
