//
//  CaseNotesCell.swift
//  CareKernel
//
//  Created by Mohit Sharma on 05/11/21.
//

import UIKit
import SwiftyJSON

protocol CaseNotesCellDelegate: AnyObject {
    func didTapButton(for cell: CaseNotesCell, cellData: [String:Any], title: String)
}

class CaseNotesCell: UITableViewCell {

    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var arrowIconImage: UIImageView!
    @IBOutlet var notesTextView: UITextView!
    @IBOutlet var addAttachmentButton: UIButton!
    @IBOutlet var submitButton: UIButton!
    @IBOutlet var fileNameButton: UIButton!
    
    weak var delegate: CaseNotesCellDelegate?
    var indexPath: IndexPath?
    static let identifire = "CaseNotesCell"
    var dataDict: [String:Any] = [:]
    static func nib() -> UINib {
        
            return UINib(nibName: "CaseNotesCell", bundle: nil)
    }
    @IBAction func addAttachment(_ sender: UIButton) {
        let currentCell = self
        delegate?.didTapButton(for: currentCell, cellData: dataDict, title: sender.title(for: .normal) ?? "Add Attachment")
    }
    
    @IBAction func submitButtonAction(_ sender: UIButton) {
        let currentCell = self
        delegate?.didTapButton(for: currentCell, cellData: dataDict, title: sender.title(for: .normal) ?? "Submit")
    }
    
    @IBAction func fileNameButtonAction(_ sender: UIButton) {
        let currentCell = self
        delegate?.didTapButton(for: currentCell, cellData: dataDict, title: sender.title(for: .normal) ?? "CN-00.png")
        
    }
    

    public func configure(with clientData: String){
//        titleLabel.text = clientName
    }
    
    func animateCell(){
        UIView.animate(withDuration: 0.5, delay: 0.3, usingSpringWithDamping: 0.8, initialSpringVelocity: 1, options: .curveEaseIn) {
            self.contentView.layoutIfNeeded()
        }

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
