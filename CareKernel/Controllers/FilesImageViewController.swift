//
//  FilesImageViewController.swift
//  CareKernel
//
//  Created by Mohit Sharma on 01/12/21.
//

import UIKit
import SDWebImage
import SwiftyJSON

class FilesImageViewController: UIViewController {

    @IBOutlet var fileBlackView: UIView!
    @IBOutlet var fileImageView: UIImageView!
    var imageurlString = ""
    var fileImage = UIImage()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if imageurlString == "" {
            self.fileImageView.image = fileImage
        }else {
        
            let imageurl = URL(string: self.imageurlString)
            self.fileImageView.sd_imageIndicator = SDWebImageActivityIndicator.grayLarge
        self.fileImageView.sd_setImage(with: imageurl, placeholderImage: #imageLiteral(resourceName: "FilesPlaceholder"))
        }
        fileImageView.layer.borderColor = UIColor(named: "Basic Blue")?.cgColor
        fileImageView.layer.borderWidth = 3
        self.fileBlackView.isHidden = false
        // Do any additional setup after loading the view.
    }
    
    @IBAction func closeButtonAction(_ sender: UIButton) {
        imageurlString = ""
        self.dismiss(animated: false, completion: nil)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
