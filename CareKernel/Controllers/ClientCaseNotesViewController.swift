//
//  ClientCaseNotesViewController.swift
//  CareKernel
//
//  Created by Mohit Sharma on 25/11/21.
//

import UIKit
import SwiftyJSON
import JGProgressHUD

class ClientCaseNotesViewController: UIViewController  {
    
    

    @IBOutlet var caseNotesTableView: UITableView!
    @IBOutlet var tableHeightConstraint: NSLayoutConstraint!
    @IBOutlet var noRecordsLabel: UILabel!
    
    var offset = "0"
    var totalPage = 1
    var currentPage = 1
    var numberOfRows = 1
    let hud = JGProgressHUD()
    var hasAttachment = false
    var cvm = CaseViewModel()
    var notesText = String()
    var detailsDict: [String:Any] = [:]
    var clientDetailsVM = ClientDetailsViewModel()
    var clientId = 0
    var casenotesArray = NSMutableArray()
    var tempTableHeight = 0.0
    var tempTableWidth = 0.0
    
    private var caseNotesImage: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        noRecordsLabel.isHidden = true
        caseNotesTableView.register(CasenotesHeaderCell.nib(), forHeaderFooterViewReuseIdentifier: "CasenotesHeaderCell")
        caseNotesTableView.register(ClientCasenotesCell.nib(), forCellReuseIdentifier: "ClientCasenotesCell")
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name:UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name:UIResponder.keyboardWillHideNotification, object: nil)
        if #available(iOS 15.0, *) {
            caseNotesTableView.sectionHeaderTopPadding = 0
        }
        
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        refreshTableView()
        self.casenotesArray.removeAllObjects()
        clientId = careKernelDefaults.value(forKey: "clientID") as! Int
        DispatchQueue.main.asyncAfter(deadline: .now() + 0) {
            self.fetchData(page: 1)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        offset = "0"
        totalPage = 1
        currentPage = 1
    }
    
    override func viewDidLayoutSubviews(){
            super.viewDidLayoutSubviews()
        let tableHeight = self.caseNotesTableView.frame.height
        let viewHeight = self.view.frame.height
        tempTableHeight = viewHeight - tableHeight
        let framWidth = self.view.frame.width
        tempTableWidth = framWidth
        var frame = self.caseNotesTableView.frame
        
        switch UIDevice().type {
        case .iPhone5, .iPhone5C, .iPhone5S, .iPhoneSE:
            frame.size.height = frame.size.height - 25
            frame.size.width = frame.size.width + 95
        case .iPhoneSE2, .iPhone6, .iPhone6S, .iPhone7, .iPhone8 :
            frame.size.height = frame.size.height - 25
            frame.size.width = frame.size.width + 40
        case .iPhone6SPlus, .iPhone7Plus, .iPhone8Plus :
            frame.size.height = frame.size.height - 24
            break
        case .iPhone11Pro, .iPhoneXS  :
            frame.size.height = frame.size.height - 24
            frame.size.width = frame.size.width + 42
            break
        case .iPhone11, .iPhoneXR  :
            frame.size.height = frame.size.height - 60
            break
        case .iPhone12, .iPhone12Pro, .iPhone13Pro, .iPhone13 :
            frame.size.width = frame.size.width + 24
            frame.size.height = tableHeight - 55
            break
        case .iPhone12Mini, .iPhone13Mini :
            frame.size.width = frame.size.width + 40
            frame.size.height = frame.size.height - 55
            break
        case .iPhone12ProMax, .iPhone13ProMax  :
            frame.size.width = frame.size.width - 14
            break
        default: break
        }
        self.caseNotesTableView.frame = frame
    }
    func refreshTableView(){
        self.caseNotesTableView.refreshControl = UIRefreshControl()
        self.caseNotesTableView.refreshControl?.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        
    }
    
    @objc private func refreshData(){
        print("Refreshed")
        self.fetchData(page: 1)
    }
    func fetchData(page: Int){
        
        guard let token = careKernelDefaults.value(forKey: kLoginToken) as? String else {
            careKernelDefaults.set(false, forKey: kIsLoggedIn)
            return }
        let limitPerPage = 10
        self.offset = "\((page - 1) * limitPerPage)"
        clientDetailsVM.getClientCasenotes(clientID: "\(self.clientId)", token: token, offset: offset, limit: "\(limitPerPage)") { response, success in
            if success {
                
                self.numberOfRows = 1
                DispatchQueue.main.async {
                    let tempArray = JSON(response)["data"].arrayValue
                    if tempArray.count != 0 {
                        for value in tempArray {
                            self.casenotesArray.add(value)
                        }
                        self.numberOfRows = self.numberOfRows + self.casenotesArray.count
                        print(self.casenotesArray)
                        self.caseNotesTableView.reloadData()
                    }else{
                        self.noRecordsLabel.isHidden = false
                    }
                }
                let metaResponse = JSON(response)["meta"].dictionaryValue
                self.totalPage = metaResponse["pages"]!.intValue
            }else{
                let statusCode = JSON(response)["statusCode"].intValue
                let message = JSON(response)["message"].stringValue
                if statusCode == 401 && message == "Unauthorized" {
                    careKernelDefaults.set(false, forKey: kIsLoggedIn)
                    careKernelDefaults.set("", forKey: kUserEmailId)
                    careKernelDefaults.set("", forKey: kLoginToken)
                    self.dismiss(animated: false, completion: nil)
                }
            }
            self.caseNotesTableView.refreshControl?.endRefreshing()
        }
        
    }

    func postCaseNotesData(clientId: Int, title: String, description: String, hasAttachment: Bool, completion: @escaping (JSON,Bool) -> Void){
        guard let token = careKernelDefaults.value(forKey: kLoginToken) as? String else {
            careKernelDefaults.set(false, forKey: kIsLoggedIn)
            return }
        cvm.token = token
        cvm.title = title
        cvm.description = description
        cvm.clientId = clientId
        
        let currentDate = getFormattedDate(date: Date(), format: "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'")
        cvm.recordedAt = currentDate
        cvm.postCaseNotes { response in
            if response.success {
                print("true")
//                self.view.isUserInteractionEnabled = true
//                self.hud.dismiss()
                if !hasAttachment{
                    self.showAlert("CareKernel", message: "Case notes updated.", actions: ["OK"]) { actionTitle in
                        
                    }
                    return completion(JSON(response.data!),false)
                }else{
                    return completion(JSON(response.data!),true)
                }
//                return completion(JSON(response.data!),false)
            }else{
                self.showAlert("Error!", message: response.successMessage ?? "", actions: ["OK"]) { actionTitle in
                    
                }
                return completion(JSON(response.data!),false)
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let vc = segue.destination as? CasenoteDetailsViewController {
            vc.detailsParam = sender as! [String : Any]
        }else if let vc = segue.destination as? FilesImageViewController {
            vc.fileImage = sender as! UIImage
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.resignFirstResponder()
        view.endEditing(true)
        
    }
    
    func setupTextFields(textView: UITextView) {
            let toolbar = UIToolbar()
            let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace,
                                            target: nil, action: nil)
            let doneButton = UIBarButtonItem(title: "Done", style: .done,
                                             target: self, action: #selector(doneButtonTapped))
            
            toolbar.setItems([flexSpace, doneButton], animated: true)
            toolbar.sizeToFit()
            
        textView.inputAccessoryView = toolbar
        }
        
    @objc func doneButtonTapped() {
            view.endEditing(true)
        }
    
    @objc func keyboardWillShow(notification:NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
                    if self.view.frame.origin.y == 0 {
                        self.view.frame.origin.y -= self.caseNotesTableView.frame.origin.y + 80
                    }
                }
    }

    @objc func keyboardWillHide(notification:NSNotification) {

        if self.view.frame.origin.y != 0 {
                    self.view.frame.origin.y = 0
                }
    }
}

extension ClientCaseNotesViewController : UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
            return 66
        }
    func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
            return 66
        }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let cell = tableView.dequeueReusableHeaderFooterView(withIdentifier: "CasenotesHeaderCell") as? CasenotesHeaderCell else {
          return nil
          }
        cell.headerTitleLabel.text = "Case Notes"
        cell.iconImageView.image = UIImage(named: "icon-casenote")
          return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return numberOfRows
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if indexPath.row == 0 {
            return 365
        }else{
            return 80
        }
        
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ClientCasenotesCell", for: indexPath) as! ClientCasenotesCell
           
            cell.indexPath = indexPath
            cell.delegate = self
            
            cell.notesTextView.delegate = self
            cell.notesTextView.isUserInteractionEnabled = true
            setupTextFields(textView: cell.notesTextView)
            cell.notesTextView.autocorrectionType = .no
            cell.notesTextView.textContentType = .oneTimeCode
            if self.hasAttachment {
                cell.fileNameButton.isHidden = false
            }else{
                cell.fileNameButton.isHidden = true
            }
            
//            cell.submitButton.topAnchor.constraint(equalTo: cell.fileNameButton.bottomAnchor, constant: 1).isActive = true
            return cell
        }else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "CasenoteListCell", for: indexPath) as! CasenoteListCell
            
            let goalID = JSON(casenotesArray)[indexPath.row - 1]["goalId"].intValue
            var displayId = ""
            if goalID == 0 {
                cell.icnonImage.image = UIImage(named: "icon-casenote")
                let sessionDisplayId = JSON(casenotesArray)[indexPath.row - 1]["session"]["displayId"].stringValue
                if sessionDisplayId != "" {
                    displayId = sessionDisplayId + ": "
                }else{
                    displayId = ""
                }
            }else{
                cell.icnonImage.image = UIImage(named: "icon-goal")
                let goalDisplayID = JSON(casenotesArray)[indexPath.row - 1]["objective"]["displayId"].stringValue
                displayId = "GL-\(goalID) / " + "\(goalDisplayID): "
            }
            let createdBy = JSON(casenotesArray)[indexPath.row - 1]["creator"]["fullName"].stringValue
            let createdAt = JSON(casenotesArray)[indexPath.row - 1]["createdAt"].stringValue
            let date = getFormattedDate(date: iso860ToString(dateString: createdAt), format: "dd/MM/yyyy hh:mm a")
            cell.caseTitleLabel.text = JSON(casenotesArray)[indexPath.row - 1]["displayId"].stringValue
            cell.caseDateLabel.text = date
            cell.caseDescriptionLabel.text = displayId + JSON(casenotesArray)[indexPath.row - 1]["description"].stringValue.capitalized
            cell.createdByLabel.text = createdBy + " at" 
            return cell
        }

    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if currentPage < totalPage && indexPath.row == self.casenotesArray.count - 1 {
            currentPage = currentPage + 1
            
            self.fetchData(page: currentPage)
            
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row != 0 {
        let caseNoteId = JSON(casenotesArray)[indexPath.row - 1]["id"].intValue
        let title = JSON(casenotesArray)[indexPath.row - 1]["title"].stringValue
        let goalID = JSON(casenotesArray)[indexPath.row - 1]["goalId"].intValue
        let desc = JSON(casenotesArray)[indexPath.row - 1]["description"].stringValue
            let createdBy = JSON(casenotesArray)[indexPath.row - 1]["creator"]["fullName"].stringValue
            let createdAt = JSON(casenotesArray)[indexPath.row - 1]["createdAt"].stringValue
            let date = getFormattedDate(date: iso860ToString(dateString: createdAt), format: "dd/MM/yyyy hh:mm a")
            let detailsParam : [String : Any] = ["id":caseNoteId, "title":title, "description":desc, "goalId": goalID, "creator": createdBy, "createdAt": date]
        self.performSegue(withIdentifier: "segueToCasenoteDetails", sender: detailsParam)
        }
    }
}

extension ClientCaseNotesViewController : ClientcCaseNotesCellDelegate {
    func didTapButton(for cell: ClientCasenotesCell, cellData: [String : Any], title: String) {
        if title == "Submit"{
            if cell.notesTextView.text != "Message" && cell.notesTextView.text != "" {
            
            self.view.isUserInteractionEnabled = false
            hud.show(in: self.view)
//            var name = JSON(cellData)["fullName"].stringValue
            var name = careKernelDefaults.value(forKey: "clientName") as! String
            name = name + " Case Notes"
            print(name)
            
            let notesDesc = cell.notesTextView.text!
                self.postCaseNotesData(clientId: self.clientId, title: "\(name)", description: notesDesc, hasAttachment: hasAttachment) { response, success in
                if success {
                    
                    var fileName = JSON(response)["displayId"].stringValue
                    fileName = fileName + ".jpg"
                    cell.fileNameButton.setTitle(fileName, for: .normal)
                    let fileData = self.caseNotesImage?.jpegData(compressionQuality: 0.3)
                    
                    let entityId = JSON(response)["id"].intValue
                    self.cvm.uploadDocuments(fileName: fileName, fileData: fileData ?? Data(), entity: "case-notes", entityId: entityId, clientID: self.clientId){ success in
                        if success {
                            self.showAlert("CareKernel", message: "Notes Updated successfully.", actions: ["Ok"]) { action in
                                if action == "Ok" {
                                    self.hasAttachment = false
                                    self.notesText = ""
                                    cell.notesTextView.text = ""
                                    cell.fileNameButton.isHidden = true
                                    self.casenotesArray.removeAllObjects()
                                        self.fetchData(page: 1)
//                                    let indexpath = IndexPath(row: 1, section: 0)
//                                self.caseNotesTableView.reloadRows(at: [indexpath], with: .fade)
//
                                }
                            }
                            self.view.isUserInteractionEnabled = true
                            self.hud.dismiss()
                        }
                    }

                }else{
                    self.notesText = ""
                    cell.notesTextView.text = ""
                    cell.fileNameButton.isHidden = true
                    let indexpath = IndexPath(row: 1, section: 0)
                    self.caseNotesTableView.reloadRows(at: [indexpath], with: .fade)
                    self.view.isUserInteractionEnabled = true
                    self.hud.dismiss()
                }
                    
            }
            }else{
                showAlert("Alert", message: "Case Note cannot be blank.", actions: ["Ok"]) { action in
                    
                }
            }
        }else if title == "CN-00.png"{
            if self.caseNotesImage != nil {
            self.performSegue(withIdentifier: "segueToShowFile", sender: self.caseNotesImage)
            }
        }else{
            self.hasAttachment = true
                AttachmentHandler.shared.showAttachmentActionSheet(vc: self)
                AttachmentHandler.shared.imagePickedBlock = { (image) in
                /* get your image here */
                    if image.size.width != 0 {
                        DispatchQueue.main.async {
                            self.hasAttachment = true
                            self.caseNotesImage = image
                            cell.fileNameButton.isHidden = false
                            
                                let indexpath = IndexPath(row: 1, section: 0)
                            self.caseNotesTableView.reloadRows(at: [indexpath], with: .fade)
                        }
                        }else{
                            self.hasAttachment = false
                        }
            }
        }
    }
    
    
}
extension ClientCaseNotesViewController: UITextViewDelegate{
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == "Message"{
            textView.text = ""
        }
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text == ""{
            textView.text = "Message"
        }
    }
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        return true
    }
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool{
//        if text == "\n" {
//                    textView.resignFirstResponder()
//                    return false
//                }
        return true
    }
    func textViewDidChange(_ textView: UITextView) {
        print(textView)
        self.notesText = textView.text
    }
}

class CasenoteListCell : UITableViewCell {
    
    @IBOutlet weak var icnonImage: UIImageView!
    @IBOutlet var caseTitleLabel: UILabel!
    @IBOutlet var caseDateLabel: UILabel!
    
    @IBOutlet weak var createdByLabel: UILabel!
    @IBOutlet var caseDescriptionLabel: UILabel!
}
