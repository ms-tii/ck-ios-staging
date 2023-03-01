//
//  ClientsCollectionViewCell.swift
//  CareKernel
//
//  Created by Mohit Sharma on 07/04/22.
//

import UIKit


protocol CollectionCellDelegate: class {
    func clientButtonCelltapped(_ tag: Int)
}

class ClientsCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var lineItemsLabel: UILabel!
    @IBOutlet weak var clientNameButton: UIButton!
    @IBOutlet weak var lineItemButton: UIButton!
    
    
    weak var delegate: CollectionCellDelegate?
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Initialization code
    }
    @IBAction func clientButtonAction(_ sender: UIButton) {
        
        delegate?.clientButtonCelltapped(sender.tag)
    }
    
    @IBAction func lineItemButtonAction(_ sender: UIButton) {
        delegate?.clientButtonCelltapped(sender.tag)
    }
}
