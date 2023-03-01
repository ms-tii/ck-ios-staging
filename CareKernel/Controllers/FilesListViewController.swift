//
//  FilesListViewController.swift
//  CareKernel
//
//  Created by Mohit Sharma on 01/08/22.
//

import UIKit
import SwiftyJSON

class FilesListViewController: UIViewController {
    
    @IBOutlet weak var filesTableView: UITableView!
    
    @IBOutlet weak var titleLabel: UILabel!
    var filesArray = NSMutableArray()
    var titleName = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        titleLabel.text = titleName
        
        // Do any additional setup after loading the view.
    }
    
    
    @IBAction func backButtonAction(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? FilesImageViewController {
            vc.imageurlString = sender as! String
        }
        
    }
    
}

extension FilesListViewController : UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        1
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return filesArray.count
        
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "FilesListCell", for: indexPath) as! FilesListCell
        
        cell.nameLabel.text = JSON(filesArray)[indexPath.row ]["name"].stringValue
        let isVisibleToServiceWorker = JSON(filesArray)[indexPath.row ]["viewFilePermission"].boolValue
        if isVisibleToServiceWorker {
            cell.viewLabel.isHidden = false
            cell.viewLabel.layer.cornerRadius = 8
            cell.viewLabel.layer.masksToBounds = true
        }else{
            cell.viewLabel.isHidden = true
        }
        cell.viewLabel.layer.cornerRadius = 8
        cell.viewLabel.layer.masksToBounds = true
        cell.selectionStyle = .none
        if indexPath.row == (filesArray.count - 1) {
        cell.clipsToBounds = true
        cell.layer.cornerRadius = 8
        cell.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
            
        }
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let imageurl = JSON(filesArray)[indexPath.row ]["url"].stringValue
        
        self.performSegue(withIdentifier: "segueToShowFile", sender: imageurl)
        
        
    }
    
}

class FilesListCell: UITableViewCell {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var viewLabel: UILabel!
    
}
