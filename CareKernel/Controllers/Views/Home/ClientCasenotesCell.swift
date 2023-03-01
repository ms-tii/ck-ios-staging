
//
//  CaseNotesCell.swift
//  CareKernel
//
//  Created by Mohit Sharma on 05/11/21.
//

import UIKit
import SwiftyJSON

protocol ClientcCaseNotesCellDelegate: AnyObject {
    func didTapButton(for cell: ClientCasenotesCell, cellData: [String:Any], title: String)
}

class ClientCasenotesCell: UITableViewCell {

 
    
    weak var delegate: ClientcCaseNotesCellDelegate?
    @IBOutlet var notesTextView: UITextView!
    @IBOutlet var addAttachmentButton: UIButton!
    @IBOutlet var submitButton: UIButton!
    @IBOutlet var fileNameButton: UIButton!
    var indexPath: IndexPath?
    static let identifire = "ClientCasenotesCell"
    var dataDict: [String:Any] = [:]
    static func nib() -> UINib {
        
            return UINib(nibName: "ClientCasenotesCell", bundle: nil)
    }
    
    
    @IBAction func submitButtonAction(_ sender: UIButton) {
        let currentCaseCell = self

        delegate?.didTapButton(for: currentCaseCell, cellData: dataDict, title: sender.title(for: .normal) ?? "Submit")
    }
    
    @IBAction func fileNameButtonAction(_ sender: UIButton) {
        let currentCaseCell = self
        delegate?.didTapButton(for: currentCaseCell, cellData: dataDict, title: sender.title(for: .normal) ?? "CN-00.png")
        
    }
    
    @IBAction func addAttachment(_ sender: UIButton) {
        let currentCaseCell = self
        delegate?.didTapButton(for: currentCaseCell, cellData: dataDict, title: sender.title(for: .normal) ?? "Add Attachment")
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
