//
//  TaskListTableViewCell.swift
//  CareKernel
//
//  Created by Mohit Sharma on 08/11/21.
//

import UIKit

class TaskListTableViewCell: UITableViewCell {

    static let identifier = "TaskListTableViewCell"
    
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var taskIdlbl: UILabel!
    @IBOutlet var statusLbl: UILabel!
    @IBOutlet var dueDateLbl: UILabel!
    @IBOutlet var priorityLbl: LabelWithProperty!
    @IBOutlet var clientIdLabel: UILabel!
    @IBOutlet var relatedtoClientLabel: UILabel!
    @IBOutlet var categoryLabel: UILabel!
    @IBOutlet var attachmentIcon: UIImageView!
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
