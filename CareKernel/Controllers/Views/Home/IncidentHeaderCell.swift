//
//  IncidentHeaderCell.swift
//  CareKernel
//
//  Created by Mohit Sharma on 14/12/21.
//

import UIKit

//protocol IncidentHeaderDelegate: AnyObject {
//    func didTapButton(for cell: IncidentHeaderCell, title: String)
//}

class IncidentHeaderCell: UITableViewHeaderFooterView {

    @IBOutlet var addIncidentsButton: UIButton!
    @IBOutlet var filterButton: UIButton!
    
    static let identifire = "IncidentHeaderCell"
//    weak var delegate: IncidentHeaderDelegate?
    var indexPath: IndexPath?
    var parentViewController: UIViewController? = nil
    
    
    static func nib() -> UINib {
        
            return UINib(nibName: "IncidentHeaderCell", bundle: nil)
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    
//    @IBAction func addIncidentAction(_ sender: UIButton) {
//        let currentCell = self
////        delegate?.didTapButton(for: currentCell, title: sender.title(for: .normal) ?? "Add Incidents")
//    }
    
}
