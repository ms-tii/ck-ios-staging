//
//  SessionInfoCell.swift
//  CareKernel
//
//  Created by Mohit Sharma on 11/10/21.
//

import UIKit
import TagListView

class SessionInfoCell: UITableViewCell
{
    @IBOutlet var nameTagsView: TagListView!
    @IBOutlet var jobIDLabel: UILabel!
    @IBOutlet var timeLabel: UILabel!
//    @IBOutlet var textViewLabel: UITextView!
    @IBOutlet var addressLabel: UILabel!
    @IBOutlet var sessionDateLabel: UILabel!
//    @IBOutlet var descriptionLabel: UILabel!
    
    override func awakeFromNib() {
            super.awakeFromNib()
        self.nameTagsView.paddingY = 10
        self.nameTagsView.paddingX = 15
        self.nameTagsView.marginY = 15
        self.nameTagsView.marginX = 20
        sizeToFit()
        layoutIfNeeded()
    }
}
