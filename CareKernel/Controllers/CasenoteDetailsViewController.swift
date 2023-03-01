//
//  CasenoteDetailsViewController.swift
//  CareKernel
//
//  Created by Mohit Sharma on 26/11/21.
//

import UIKit
import SwiftyJSON
import SDWebImage

class CasenoteDetailsViewController: UIViewController {

    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var fileBlackView: UIView!
    @IBOutlet var fileImageView: UIImageView!
    @IBOutlet var attachmentTable: UITableView!
    @IBOutlet var descriptionTextView: UITextView!
    @IBOutlet weak var createdByLabel: UILabel!
    @IBOutlet weak var createdAtLabel: UILabel!
    
    var clientId = 0
    var filesArray = NSMutableArray()
    var clientDetailsVM = ClientDetailsViewModel()
    var casenoteId = 0
    var notesDescription = ""
    var clientName = ""
    var detailsParam = [String:Any]()

    override func viewDidLoad() {
        super.viewDidLoad()
        fileBlackView.isHidden = true
        fileImageView.layer.borderColor = UIColor(named: "Basic Blue")?.cgColor
        fileImageView.layer.borderWidth = 3
        
        attachmentTable.register(CasenotesHeaderCell.nib(), forHeaderFooterViewReuseIdentifier: "CasenotesHeaderCell")
        attachmentTable.register(ClientFilesCell.nib(), forCellReuseIdentifier: "ClientFilesCell")
        clientId = careKernelDefaults.value(forKey: "clientID") as! Int
        
        titleLabel.text = JSON(detailsParam)["title"].stringValue
        descriptionTextView.text = JSON(detailsParam)["description"].stringValue.capitalized
        casenoteId = JSON(detailsParam)["id"].intValue
        let goalID = JSON(detailsParam)["goalId"].intValue
        self.attachmentTable.isHidden = true
        if goalID == 0 {
            self.iconImageView.image = UIImage(named: "icon-casenote")
        }else{
            self.iconImageView.image = UIImage(named: "icon-goal")
        }
      
        createdAtLabel.text = JSON(detailsParam)["createdAt"].stringValue
        createdByLabel.text = JSON(detailsParam)["creator"].stringValue + " at" 
        DispatchQueue.main.asyncAfter(deadline: .now()) {
            self.fetchData()
        }
    }
    
    @IBAction func backButtonAction(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }

    @IBAction func closeButtonAction(_ sender: UIButton) {
        fileBlackView.isHidden = true
    }
    
    func fetchData(){
        guard let token = careKernelDefaults.value(forKey: kLoginToken) as? String else {
            careKernelDefaults.set(false, forKey: kIsLoggedIn)
            return }
        self.clientDetailsVM.getCasenoteFiles(entity: "case-notes", entityID: "\(self.casenoteId)", token: token) { response, success in
            if success {
                let tempFileArray = JSON(response)["data"].arrayValue
                if tempFileArray.count != 0 {
                    for file in tempFileArray {
                        self.filesArray.add(file)
                    }
                    print(self.filesArray)
                    self.attachmentTable.isHidden = false
                }
                self.attachmentTable.reloadData()
            }
        }
        
    }

}

extension CasenoteDetailsViewController : UITableViewDelegate, UITableViewDataSource {
    
   
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
            return UITableView.automaticDimension
        }

    func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
            return 66.0
        }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
            return 75
        
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let cell = tableView.dequeueReusableHeaderFooterView(withIdentifier: "CasenotesHeaderCell") as? CasenotesHeaderCell else {
          return nil
          }
    
            cell.headerTitleLabel.text = "Files"
            cell.iconImageView.image = UIImage(named: "icon-files")
            
          return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
            return filesArray.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
            let cell = tableView.dequeueReusableCell(withIdentifier: "ClientFilesCell", for: indexPath) as! ClientFilesCell
            
            cell.idLabel.text = JSON(filesArray)[indexPath.row ]["displayId"].stringValue
            cell.nameLabel.text = JSON(filesArray)[indexPath.row ]["name"].stringValue
        let isVisibleToServiceWorker = JSON(filesArray)[indexPath.row ]["viewFilePermission"].boolValue
        if isVisibleToServiceWorker {
            cell.viewLabel.isHidden = false
            cell.viewLabel.layer.cornerRadius = 8
            cell.viewLabel.layer.masksToBounds = true
        }else{
            cell.viewLabel.isHidden = true
        }
        
        cell.selectionStyle = .none
            return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let isVisibleToServiceWorker = JSON(filesArray)[indexPath.row ]["viewFilePermission"].boolValue
        if isVisibleToServiceWorker {
            let fileType = JSON(filesArray)[indexPath.row ]["fileType"].stringValue
            if fileType == "image/jpg" || fileType == "image/png"{
                let imageurl = URL(string: JSON(filesArray)[indexPath.row ]["url"].stringValue)
            self.fileImageView.sd_imageIndicator = SDWebImageActivityIndicator.grayLarge
            self.fileImageView.sd_setImage(with: imageurl, placeholderImage: #imageLiteral(resourceName: "FilesPlaceholder"))
            self.fileBlackView.isHidden = false
            }else{
                showAlert("CareKernel", message: "File not supported.", actions: ["OK"]) { success in
                    
                }
            }
            
        }
            
        
    }

    
}
