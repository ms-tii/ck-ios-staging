//
//  SessionCaseNotesViewController.swift
//  CareKernel
//
//  Created by Mohit Sharma on 20/04/22.
//

import UIKit
import SwiftyJSON
import JGProgressHUD

class SessionCaseNotesViewController: UIViewController {
    
    @IBOutlet weak var caseNotesTableView: UITableView!
    @IBOutlet weak var attachedFileView: UIView!
    @IBOutlet weak var fileImageView: UIImageView!
    @IBOutlet weak var addCaseNoteLabel: UILabel!
    @IBOutlet weak var notAccesibleLabel: UILabel!
    
    var selectedIndex = 0
    var numberOfRows = 0
    var isCellCollapc = Bool()
    var hasAttachment = false
    var clients = NSMutableArray()
    let hud = JGProgressHUD()
    var caseNotesImage: UIImage?
    var cvm = CaseViewModel()
    var notesText = String()
    var sessionId = 0
    var sessionNotesArr = NSMutableArray()
    var tabStatusDelegate : TabStatusDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        attachedFileView.isHidden = true
        caseNotesTableView.register(CasenotesHeaderCell.nib(), forHeaderFooterViewReuseIdentifier: "CasenotesHeaderCell")
        caseNotesTableView.register(CaseNotesCell.nib(), forCellReuseIdentifier: "CaseNotesCell")
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        Storage.remove("sessionCasesData", from: .documents)
    }
    
    func setDetails(){
        //        clients = careKernelDefaults.value(forKey: "clientLineDetails") as! NSMutableArray
        self.view.isUserInteractionEnabled = false
        hud.show(in: self.view)
        clients.removeAllObjects()
        let clientData = Storage.readingFromDD(from: .documents, fileName: "clientLineDetails")
        let clientJson = try! JSON(data: clientData)
        let tempArr = JSON(clientJson).arrayValue
        if tempArr.count == 0 {// case of no clients and session type other
            self.addCaseNoteLabel.isHidden = true
            self.notAccesibleLabel.isHidden = false
            self.hud.dismiss()
        }else{
            self.addCaseNoteLabel.isHidden = false
            self.notAccesibleLabel.isHidden = true
        for value in tempArr {
            //            print(value)
            let clientId = JSON(value)["id"].intValue
            
            self.getCasenoteLists(selectedClientId: clientId, values: value) { response in
                print(self.clients)
                
                //                if self.clients.count == tempArr.count {
                //                    print("reload table")
                //
                //                }else{
                //                    self.caseNotesTableView.reloadData()
                //                }
                self.caseNotesTableView.reloadData()
                self.view.isUserInteractionEnabled = true
                self.hud.dismiss(animated: true)
            }
        }
        self.caseNotesTableView.reloadData()
        //        numberOfRows = clients.count
        //        caseNotesTableView.reloadData()
        //        if clients.count != 0 {
        //            let firstCLientId = JSON(clients)[0]["id"].int ?? 0
        //            self.getCasenoteList(selectedClientId: firstCLientId, tabelIndex: 0)
        //        }
        tabStatusDelegate?.tabStatusChanged(status: "Casenotes")
        }
    }
    
    @IBAction func fileViewCloseButtonAction(_ sender: UIButton) {
        
        attachedFileView.isHidden = true
    }
    
    func getCasenoteLists(selectedClientId: Int, values: JSON, completion: @escaping ([JSON]) -> Void){
        var caseNoteVM = ClientDetailsViewModel()
        caseNoteVM.clientId = selectedClientId
        guard let token = careKernelDefaults.value(forKey: kLoginToken) as? String else {
            careKernelDefaults.set(false, forKey: kIsLoggedIn)
            return}
        caseNoteVM.getSessionCasenotes(sessionID: "\(self.sessionId)", clientID: "\(selectedClientId)", token: token, offset: "\(0)", limit: "\(100)") { response, success in
            if success {
                DispatchQueue.main.async {
                    let tempArray = JSON(response)["data"].arrayValue
                    if tempArray.count != 0 {

                        let completeArr = ["caseNotes": tempArray,"clientDetails":  values] as [String:Any]
                        self.clients.add(completeArr)
                        return completion(tempArray)
                    }else{
//                                                self.noRecordsLabel.isHidden = false
                        let completeArr = ["caseNotes": [],"clientDetails":  values] as [String:Any]
                        self.clients.add(completeArr)
                        self.caseNotesTableView.reloadData()
                        self.view.isUserInteractionEnabled = true
                        self.hud.dismiss(animated: true)
                        completion([JSON()])
                    }
                }
            }
        }
        
    }
    
    func getCasenoteList(selectedClientId: Int, tabelIndex: Int? = 0){
        var caseNoteVM = ClientDetailsViewModel()
        caseNoteVM.clientId = selectedClientId
        guard let token = careKernelDefaults.value(forKey: kLoginToken) as? String else {
            careKernelDefaults.set(false, forKey: kIsLoggedIn)
            return }
        caseNoteVM.getSessionCasenotes(sessionID: "\(self.sessionId)", clientID: "\(selectedClientId)", token: token, offset: "\(0)", limit: "\(100)") { response, success in
            if success {
                DispatchQueue.main.async {
                    let tempArray = JSON(response)["data"].arrayValue
                    print(tempArray)
                    if tempArray.count != 0 {
                        self.sessionNotesArr.removeAllObjects()
                        for value in tempArray {
                            self.sessionNotesArr.add(value)
                        }
                        let encoder = JSONEncoder()
                        
                        do {
                            let sessionCasesData = try! encoder.encode(JSON(self.sessionNotesArr))
                            
                            let documentUrl = Storage.getURL(for: .documents).appendingPathComponent("sessionCasesData", isDirectory: false)
                            
                            Storage.writeToFile(sessionCasesData, documentsURL: documentUrl) { success in
                                if success {
                                    let scData = Storage.readingFromDD(from: .documents, fileName: "sessionCasesData")
                                    let scJsn = try! JSON(data: scData)

                                    self.caseNotesTableView.reloadData()
            self.view.isUserInteractionEnabled = true
            self.hud.dismiss(animated: true)
                                }
                            }
//                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
//                                let topRow = IndexPath(row: tabelIndex ?? 0, section: 0)
//                                self.caseNotesTableView.reloadRows(at: [topRow], with: .automatic)
//                                self.caseNotesTableView.scrollToRow(at: topRow,
//                                                                    at: .top,
//                                                                    animated: true)
                            
                                
                            }
//                        }
                        
                    }else{
                        //                        self.noRecordsLabel.isHidden = false
                        self.caseNotesTableView.reloadData()
                    }
                }
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
    
    func postCaseNotesData(clientId: Int, title: String, description: String, hasAttachment: Bool, completion: @escaping (JSON,Bool) -> Void){
        guard let token = careKernelDefaults.value(forKey: kLoginToken) as? String else {
            careKernelDefaults.set(false, forKey: kIsLoggedIn)
            return }
        
        cvm.token = token
        cvm.title = title
        cvm.description = description
        cvm.clientId = clientId
        cvm.sessionID = sessionId
        let currentDate = getFormattedDate(date: Date(), format: "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'")
        cvm.recordedAt = currentDate
        cvm.postSessionCaseNotes { response in
            if response.success {
                print("true")
                
                if !hasAttachment{
                    self.showAlert("CareKernel", message: "Case notes updated", actions: ["OK"]) { actionTitle in
                        
                    }
                    return completion(JSON(response.data!),false)
                }else{
                    return completion(JSON(response.data!),true)
                }
            }else{
                self.showAlert("Error!", message: response.successMessage ?? "", actions: ["OK"]) { actionTitle in
                    
                }
                return completion(JSON(response.data!),false)
            }
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.resignFirstResponder()
        view.endEditing(true)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let vc = segue.destination as? CasenoteDetailsViewController {
            vc.detailsParam = sender as! [String : Any]
        }else if let vc = segue.destination as? FilesImageViewController {
            vc.fileImage = sender as! UIImage
        }
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
}
extension SessionCaseNotesViewController : UITableViewDelegate, UITableViewDataSource {
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if indexPath.row == selectedIndex && isCellCollapc == true{
            return 540
        }else{
            return 66
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.clients.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SessionCaseNotesCell", for: indexPath) as! SessionCaseNotesCell
        let name = JSON(self.clients)[indexPath.row ]["clientDetails"]["fullName"].stringValue
        
        cell.parentViewController = self
        cell.titleLabel.text = name
        cell.configure(with: name)
        cell.indexPath = indexPath
        cell.delegate = self
        cell.dataDict = JSON(self.clients)[indexPath.row].dictionaryValue
        cell.notesTextView.delegate = self
        cell.notesTextView.isUserInteractionEnabled = true
        self.setupTextFields(textView: cell.notesTextView)
        cell.fileNameButton.isHidden = true
        cell.submitButton.isHidden = true
        cell.delegate = self
        if indexPath.row == selectedIndex && isCellCollapc && hasAttachment{
            cell.notesTextView.text = self.notesText
            cell.fileNameButton.isHidden = false
            cell.submitButton.isHidden = false
        }else if indexPath.row == selectedIndex && isCellCollapc{
            cell.submitButton.isHidden = false
        }else{
            cell.notesTextView.text = ""
            
            hasAttachment = false
            cell.fileNameButton.isHidden = true
            
        }
        sessionNotesArr.removeAllObjects()
        cell.notesArray.removeAllObjects()
        
        let caseNotesTempArr = JSON(self.clients)[indexPath.row ]["caseNotes"].arrayValue
        cell.notesArr.removeAllObjects()
        for item in caseNotesTempArr {
            cell.notesArr.add(item)
            sessionNotesArr.add(item)
        }
        cell.notesArray = cell.notesArr
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if selectedIndex == indexPath.row{
            if !isCellCollapc {

                isCellCollapc = true

            }else{
                
                isCellCollapc = false
                
            }
        }else{
            
            isCellCollapc = true
            
        }
        selectedIndex = indexPath.row
        
        self.caseNotesTableView.reloadRows(at: [indexPath], with: .automatic)
        self.caseNotesTableView.scrollToRow(at: indexPath,
                                                 at: .top,
                                                 animated: true)
        
    }
}

extension SessionCaseNotesViewController: SessionCaseNotesCellDelegate{
    func notesListCelltapped(_ data: [String : Any]) {
        self.performSegue(withIdentifier: "segueToCasenoteDetails", sender: data)
    }
    
    
    func didTapButton(for cell: SessionCaseNotesCell, cellData: [String : Any], title: String) {
        if title == "Submit"{
            if cell.notesTextView.text != "Message" && cell.notesTextView.text != "" {
                
                self.view.isUserInteractionEnabled = false
                hud.show(in: self.view)
                var name = JSON(cellData)["clientDetails"]["fullName"].stringValue
                let clientId = JSON(cellData)["clientDetails"]["id"].intValue
                name = name + " Case Notes"
                
                let notesDesc = cell.notesTextView.text!
                self.postCaseNotesData(clientId: clientId, title: "\(name)", description: notesDesc, hasAttachment: hasAttachment) { response, success in
                    if success {
                        //                    self.fileImageView.image = nil
                        var fileName = JSON(response)["displayId"].stringValue
                        fileName = fileName + ".jpg"
                        cell.fileNameButton.setTitle(fileName, for: .normal)
                        
                        let fileData = self.caseNotesImage?.jpegData(compressionQuality: 0.3)
                        
                        let entityId = JSON(response)["id"].intValue
                        self.cvm.uploadDocuments(fileName: fileName, fileData: fileData ?? Data(), entity: "case-notes", entityId: entityId, clientID: clientId){ success  in
                            if success {
                                self.showAlert("CareKernel", message: "Notes Updated successfully.", actions: ["ok"]) { action in
                                    if action == "ok" {
                                        //                                    self.fileImageView = nil
                                        self.hasAttachment = false
                                        self.notesText = ""
                                        cell.notesTextView.text = ""
                                        cell.fileNameButton.isHidden = true
                                        let indexpath = IndexPath(row: self.selectedIndex, section: 0)
                                        self.setDetails()
                                    }
                                }
                            }
                        }
                    }else{
                        self.notesText = ""
                        cell.notesTextView.text = ""
                        let indexpath = IndexPath(row: self.selectedIndex, section: 0)
                        self.caseNotesTableView.reloadRows(at: [indexpath], with: .fade)
                        self.setDetails()
                    }
                    
                }
            }else{
                showAlert("Alert", message: "Case Note cannot be blank.", actions: ["Ok"]) { action in
                    
                }
            }
        }else if title == "CN-00.png"{
            if self.fileImageView != nil{
                self.attachedFileView.isHidden = false
                self.fileImageView.layer.borderColor = UIColor(named: "Basic Blue")?.cgColor
                self.fileImageView.layer.borderWidth = 3
                self.fileImageView.layer.masksToBounds = true
            }
        }else if title == "Add Attachment"{
            tabStatusDelegate?.tabStatusChanged(status: "Casenotes")
            AttachmentHandler.shared.showAttachmentActionSheet(vc: self)
            AttachmentHandler.shared.imagePickedBlock = { (image) in
                /* get your image here */
                if image.size.width != 0 {
                    DispatchQueue.main.async {
                        cell.fileNameButton.setTitle("CN-00.png", for: .normal)
                        self.hasAttachment = true
                        cell.notesTextView.text = self.notesText
                        self.caseNotesImage = image
                        self.fileImageView.image = image//self.caseNotesImage
                        let indexpath = IndexPath(row: self.selectedIndex, section: 0)
                        self.caseNotesTableView.reloadRows(at: [indexpath], with: .fade)
                    }
                }
            }
            
            
        }
    }
    
}
extension SessionCaseNotesViewController: UITextViewDelegate{
    
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
//            textView.resignFirstResponder()
//            return false
//        }
        return true
    }
    func textViewDidChange(_ textView: UITextView) {
        print(textView)
        self.notesText = textView.text
    }
}

/*
 func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
     let cell = tableView.dequeueReusableCell(withIdentifier: "SessionCaseNotesCell", for: indexPath) as! SessionCaseNotesCell
     var name = JSON(self.clients)[indexPath.row ]["clientDetails"]["fullName"].stringValue
     name = "Add " + name + " Case Notes"
     cell.parentViewController = self
     cell.titleLabel.text = name
     cell.configure(with: name)
     cell.indexPath = indexPath
     cell.delegate = self
     cell.dataDict = JSON(self.clients)[indexPath.row].dictionaryValue
     cell.notesTextView.delegate = self
     cell.notesTextView.isUserInteractionEnabled = true
     cell.fileNameButton.isHidden = true
     cell.submitButton.isHidden = true
     if indexPath.row == selectedIndex && isCellCollapc && hasAttachment{
         cell.notesTextView.text = self.notesText
         cell.fileNameButton.isHidden = false
         cell.submitButton.isHidden = false
     }else if indexPath.row == selectedIndex && isCellCollapc{
         cell.submitButton.isHidden = false
     }else{
         cell.notesTextView.text = ""
         cell.delegate = self
         hasAttachment = false
         cell.fileNameButton.isHidden = true
//            cell.submitButton.isHidden = true
         sessionNotesArr.removeAllObjects()
         cell.notesArray.removeAllObjects()
         do {
             let fileUrl = Storage.getURL(for: .documents).appendingPathComponent("sessionCasesData")
             let fileManager = FileManager.default
             if fileManager.fileExists(atPath: fileUrl.path) {
                 print("File exists")
                 if let scData = fileManager.contents(atPath: fileUrl.path) {
                     let scJsn = try! JSON(data: scData)
                     let tempArr = JSON(scJsn).arrayValue
                     
                     for value in tempArr {
                         sessionNotesArr.add(value)
                     }
                     
                 }else {
                     print("No data at \(fileUrl.path)!")
                 }
             } else {
                 print("File at path \(fileUrl.path) does not exist!")
                 self.sessionNotesArr = NSMutableArray()
             }
//                let scData = try! Storage.readingFromDD(from: .documents, fileName: "sessionCasesData")
             
         }catch {
             print(error.localizedDescription)
         }
         cell.notesArray = sessionNotesArr
//            if isCellCollapc {
//                cell.submitButton.isHidden = false
//            }
     }
     return cell
     
 }
 
 */
