//
//  ClientHomeViewController.swift
//  CareKernel
//
//  Created by Mohit Sharma on 29/10/21.
//

import UIKit
import SwiftyJSON
import SDWebImage

class ClientBasicDetailsViewController: UIViewController {

    @IBOutlet var clientTable: UITableView!
    var clientId = 0
    var detailsDict: [String:Any] = [:]
    var clientDetailsVM = ClientDetailsViewModel()
    var tempTableHeight = 0.0
    var tempTableWidth = 0.0
    var detailsPermissions = [String:JSON]()
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let clientIddefaults = careKernelDefaults.value(forKey: "clientID") as? Int else {
            self.clientId = 25
            return }
        self.clientId = clientIddefaults
        let messagesFromDisk = Storage.retrieve("appData.json", from: .documents, as: JSON.self)
        
        for (key,value) in messagesFromDisk {
            if key == "Basic Details"{
                
                    let permissions = JSON(value)["viewPermision"].dictionaryValue
                    detailsPermissions = permissions
                }
            }
        fetchData()
        // Do any additional setup after loading the view.
    }
    
    override func viewDidLayoutSubviews(){
            super.viewDidLayoutSubviews()
        let tableHeight = self.clientTable.frame.height
        let viewHeight = self.view.frame.height
        tempTableHeight = viewHeight - tableHeight
        let framWidth = self.view.frame.width
        tempTableWidth = framWidth
        var frame = self.clientTable.frame
        print(UIDevice().type)
        switch UIDevice().type {
            
        case .iPhone5, .iPhone5C, .iPhone5S, .iPhoneSE :
            frame.size.height = frame.size.height - 60
            frame.size.width = frame.size.width + 95
        case .iPhoneSE2, .iPhone6, .iPhone6S, .iPhone7, .iPhone8 :
            frame.size.height = frame.size.height - 60
            frame.size.width = frame.size.width + 40
        case .iPhone6SPlus, .iPhone7Plus, .iPhone8Plus :
            frame.size.height = frame.size.height - 55
            break
        case .iPhone11, .iPhoneXR  :
//            frame.size.height = frame.size.height + 200
//            frame.size.width = frame.size.width + 42
            break
        case .iPhone11Pro, .iPhoneXS  :
            frame.size.width = frame.size.width + 42
            break
        case .iPhone12, .iPhone12Pro, .iPhone13Pro, .iPhone13  :
            frame.size.width = frame.size.width + 24
            break
        case .iPhone12Mini, .iPhone13Mini  :
            frame.size.height = frame.size.height - 55
            frame.size.width = frame.size.width + 40
            break
        case .iPhone12ProMax, .iPhone13ProMax  :
            frame.size.width = frame.size.width - 14
            break
        default: break
        }
        self.clientTable.frame = frame
    }
    
    func fetchData(){
        guard let token = careKernelDefaults.value(forKey: kLoginToken) as? String else {
            careKernelDefaults.set(false, forKey: kIsLoggedIn)
            return }
        clientDetailsVM.getClientDetails(clientID: "\(self.clientId)", token: token) { response, success in
            if success {
                DispatchQueue.main.async {
                    let dict = JSON(response).dictionaryValue
                    print(dict)
                    self.detailsDict = dict  as [String : Any]
                    self.clientTable.reloadData()
                }
            }else{
                
            }
        }
        
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
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension ClientBasicDetailsViewController : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "clientCell", for: indexPath) as! clientCell

        let dob = JSON(self.detailsDict)["dob"].stringValue
//        let formatedDOB = getFormattedDate(date: iso860ToString(dateString: dob), format: "dd/MM/yyyy")
        let phone = JSON(self.detailsDict)["phone"].stringValue
        let gender = JSON(self.detailsDict)["gender"].stringValue
//        let email = JSON(self.detailsDict)["email"].stringValue
        let religion = JSON(self.detailsDict)["religion"]["name"].stringValue
        let nationality = JSON(self.detailsDict)["nationality"]["name"].stringValue
        let language = JSON(self.detailsDict)["language"]["name"].stringValue
        let address = JSON(self.detailsDict)["fullAddress"].stringValue
        for (key,value) in detailsPermissions {
            let isAllowed = JSON(value).boolValue
            switch key {
                
            case "dob":
                
                break
            case "phone":
                if isAllowed {
                    if phone == "" {
                        cell.phoneLabel.text = "NA"
                    }else{
                        cell.phoneLabel.text = phone
                    }
                    
                }else{
                    cell.phoneLabel.text = "NA"
                }
                break
            case "gender":
                if isAllowed {
                    if gender == "" {
                        cell.genderLabel.text = "NA"
                    }else{
                        cell.genderLabel.text = gender.capitalized
                    }
                    
                }else{
                    cell.genderLabel.text = "NA"
                }
                break
            case "email":
                
                break
            case "religion":
                if isAllowed {
                    if religion == "" {
                        cell.religionLabel.text = "NA"
                    }else{
                        cell.religionLabel.text = religion
                    }
                    
                }else{
                    cell.religionLabel.text = "NA"
                }
                break
            case "nationality":
                if isAllowed {
                    if nationality == "" {
                        cell.nationalityLabel.text = "NA"
                    }else{
                        cell.nationalityLabel.text = nationality
                    }
                    
                }else{
                    cell.nationalityLabel.text = "NA"
                }
                break
            case "language":
                if isAllowed {
                    if language == "" {
                        cell.languageLabel.text = "NA"
                    }else{
                        cell.languageLabel.text = language
                    }
                    
                }else{
                    cell.languageLabel.text = "NA"
                }
                break
            case "fullAddress":
                if isAllowed {
                    if address == "" {
                        cell.addressLabel.text = "NA"
                    }else{
                        cell.addressLabel.text = address
                    }
                    
                }else{
                    cell.addressLabel.text = "NA"
                }
                break
            default:
                break
            }
        }
        
        
        
        
        
        
        
        
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {

        
    }
    
}
class clientCell : UITableViewCell {
    
    @IBOutlet var phoneLabel: UILabel!
    @IBOutlet var genderLabel: UILabel!
    @IBOutlet var religionLabel: UILabel!
    @IBOutlet var nationalityLabel: UILabel!
    @IBOutlet var languageLabel: UILabel!
    @IBOutlet var addressLabel: UILabel!
    
    
    
    
    
}
