//
//  SessionCaseNotesCell.swift
//  CareKernel
//
//  Created by Mohit Sharma on 08/06/22.
//

import UIKit
import SwiftyJSON

protocol SessionCaseNotesCellDelegate: AnyObject {
    func didTapButton(for cell: SessionCaseNotesCell, cellData: [String:Any], title: String)
    func notesListCelltapped(_ data: [String:Any])
}

class SessionCaseNotesCell: UITableViewCell, UICollectionViewDataSource, UICollectionViewDelegate {

    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var arrowIconImage: UIImageView!
    @IBOutlet var notesTextView: UITextView!
    @IBOutlet var addAttachmentButton: UIButton!
    @IBOutlet var submitButton: UIButton!
    @IBOutlet var fileNameButton: UIButton!
    @IBOutlet weak var notesCollectionView: UICollectionView!
    @IBOutlet weak var noRecordsLabel: UILabel!
    
    weak var delegate: SessionCaseNotesCellDelegate?
    var indexPath: IndexPath?
    static let identifire = "SessionCaseNotesCell"
    var dataDict: [String:Any] = [:]
    var parentViewController: UIViewController? = nil
    var notesArr = NSMutableArray()
    var notesArray : NSMutableArray = [] {
        didSet {
            print(notesArray.count)
            parentViewController = SessionCaseNotesViewController()
            self.notesCollectionView.dataSource = self
            self.notesCollectionView.delegate = self
            self.notesCollectionView.reloadData()
            if notesArray.count == 0 {
                noRecordsLabel.isHidden = false
            }else{
                noRecordsLabel.isHidden = true
            }
        }
    }
    static func nib() -> UINib {
        
            return UINib(nibName: "SessionCaseNotesCell", bundle: nil)
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
    
    func getFormattedDate(date: Date, format: String) -> String {
        let dateformat = DateFormatter()
        dateformat.dateFormat = format
        return dateformat.string(from: date)
    }
    
    func iso860ToString(dateString: String) -> Date{
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        let date = dateFormatter.date(from:dateString) ?? Date()
        return date
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return notesArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "NotesListCell", for: indexPath as IndexPath) as! NotesListCell
        let displayID = JSON(notesArray)[indexPath.row]["displayId"].stringValue
        print(displayID)
        let goalID = JSON(notesArray)[indexPath.row]["goalId"].intValue
        if goalID == 0 {
            cell.icnonImage.image = UIImage(named: "icon-casenote")
        }else{
            cell.icnonImage.image = UIImage(named: "icon-goal")
        }
        let createdBy = JSON(notesArray)[indexPath.row]["creator"]["fullName"].stringValue
        let createdAt = JSON(notesArray)[indexPath.row]["createdAt"].stringValue
        let date = getFormattedDate(date: iso860ToString(dateString: createdAt), format: "dd/MM/yyyy hh:mm a")
        cell.caseTitleLabel.text = JSON(notesArray)[indexPath.row]["displayId"].stringValue
        cell.caseDateLabel.text = date
        cell.caseDescriptionLabel.text = JSON(notesArray)[indexPath.row]["description"].stringValue.capitalized
        cell.createdByLabel.text = createdBy + " at"
        cell.clipsToBounds = true
        cell.layer.cornerRadius = 8
        cell.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let caseNoteId = JSON(notesArray)[indexPath.row]["id"].intValue
        let title = JSON(notesArray)[indexPath.row]["title"].stringValue
        let goalID = JSON(notesArray)[indexPath.row]["goalId"].intValue
        let desc = JSON(notesArray)[indexPath.row]["description"].stringValue
            let createdBy = JSON(notesArray)[indexPath.row]["creator"]["fullName"].stringValue
            let createdAt = JSON(notesArray)[indexPath.row]["createdAt"].stringValue
            let date = getFormattedDate(date: iso860ToString(dateString: createdAt), format: "dd/MM/yyyy hh:mm a")
            let detailsParam : [String : Any] = ["id":caseNoteId, "title":title, "description":desc, "goalId": goalID, "creator": createdBy, "createdAt": date]
        print(detailsParam)
//        self.performSegue(withIdentifier: "segueToCasenoteDetails", sender: detailsParam)
        
        delegate?.notesListCelltapped(detailsParam)
        

    }
}
class NotesListCell : UICollectionViewCell{
    
    @IBOutlet weak var icnonImage: UIImageView!
    @IBOutlet var caseTitleLabel: UILabel!
    @IBOutlet var caseDateLabel: UILabel!
    
    @IBOutlet weak var createdByLabel: UILabel!
    @IBOutlet var caseDescriptionLabel: UILabel!
    
}
