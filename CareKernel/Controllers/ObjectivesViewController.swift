//
//  ObjectivesViewController.swift
//  CareKernel
//
//  Created by Mohit Sharma on 13/05/22.
//

import UIKit
import SwiftyJSON
import JGProgressHUD
class ObjectivesViewController: UIViewController {
    @IBOutlet weak var noRecordLabel: UILabel!
    @IBOutlet weak var descriptionButton: UIButton!
    @IBOutlet weak var achievementsButton: UIButton!
    @IBOutlet weak var achievementsTableView: UITableView!
    @IBOutlet weak var descriptionView: UIScrollView!
    @IBOutlet var fileBlackView: UIView!
    @IBOutlet var fileImageView: UIImageView!
    @IBOutlet weak var objectiveDescription: UILabel!
    @IBOutlet weak var objectiveInstruction: UILabel!
    @IBOutlet weak var objectiveMeasurements: UILabel!
    @IBOutlet weak var achievementLabel: UILabel!
    
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var achievementsTextView: UITextView!
    @IBOutlet weak var addAttachmentButton: UIButton!
    @IBOutlet weak var notesTextView: UITextView!
    @IBOutlet weak var fileNameButton: UIButton!
    var isKeyboardDismiss = Bool()
    var detailsArray = NSMutableArray()
    var objectiveDetails = [String: Any]()
    var achievementsValue = String()
    var notesValue = String()
    var descriptionViewOriginY = CGFloat()
    var notesTextViewIsActive = Bool()
    var hasAttachment = false
    let hud = JGProgressHUD()
    var measurementType = String()
    
    private var caseNotesImage: UIImage?

    override func viewDidLoad() {
        super.viewDidLoad()
        noRecordLabel.isHidden = true
        descriptionView.isHidden = false
        achievementsTableView.isHidden = true
        setUIView()
        self.getObjectiDetails()
        descriptionViewOriginY = self.descriptionView.frame.origin.y
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name:UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name:UIResponder.keyboardWillHideNotification, object: nil)
        self.fileNameButton.isHidden = true
        fileBlackView.isHidden = true
        fileImageView.layer.borderColor = UIColor(named: "Basic Blue")?.cgColor
        fileImageView.layer.borderWidth = 3
        setupTextFields()
    }
    
    @IBAction func backButtonAction(_ sender: UIButton) {
        self.dismiss(animated: true)
    }
    @IBAction func closeButtonAction(_ sender: UIButton) {
        fileBlackView.isHidden = true
    }
    @IBAction func descriptionButtonAction(_ sender: UIButton) {
        descriptionView.isHidden = false
        achievementsTableView.isHidden = true
        descriptionButton.setTitleColor(.white, for: .normal)
        achievementsButton.titleLabel?.textColor = UIColor(named: "light white tab font")
    }
    
    @IBAction func achievementsButtonAction(_ sender: UIButton) {
        achievementsTableView.isHidden = false
        descriptionView.isHidden = true
        achievementsButton.setTitleColor(.white, for: .normal)
        descriptionButton.titleLabel?.textColor = UIColor(named: "light white tab font")
    }
    
    @IBAction func addButtonAction(_ sender: UIButton) {
        if achievementsTextView.text == "" || achievementsTextView.text == "Quantity/Percentage"{
            showAlert("Alert!", message: "Achievement field cannot be empty.", actions: ["Ok"]) { action in
                
            }
        }else{
            self.view.isUserInteractionEnabled = false
            hud.show(in: self.view)
            let params = ["value": achievementsValue, "notes": notesValue]
            self.addAchievements(params: params)
        }
        
    }
    
    @IBAction func attachmentButtonAction(_ sender: UIButton) {
        self.hasAttachment = true
            AttachmentHandler.shared.showAttachmentActionSheet(vc: self)
            AttachmentHandler.shared.imagePickedBlock = { (image) in
            /* get your image here */
                if image.size.width != 0 {
                    DispatchQueue.main.async {
                        self.hasAttachment = true
                        self.caseNotesImage = image
                        self.fileNameButton.isHidden = false
                    }
                    }else{
                        self.hasAttachment = false
                    }
        }

    
    }
    
    @IBAction func fileNameButtonAction(_ sender: UIButton) {
        if self.caseNotesImage != nil {
            self.fileBlackView.isHidden = false
            self.fileImageView.image = self.caseNotesImage
        }
    }
    
    
    
    @objc func keyboardWillShow(notification:NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
                    if self.view.frame.origin.y == 0 {
                        self.view.frame.origin.y -= keyboardSize.height
                    }
                }
    }

    @objc func keyboardWillHide(notification:NSNotification) {

        if self.view.frame.origin.y != 0 {
                    self.view.frame.origin.y = 0
                }
    }
    
    func setUIView(){
      
        self.measurementType = JSON(objectiveDetails)["measurementType"].stringValue
        let operation = JSON(objectiveDetails)["operation"].stringValue
        let targetValue = JSON(objectiveDetails)["targetValue"].stringValue
        let unitOfMeasurement = JSON(objectiveDetails)["unitOfMeasurement"].stringValue
        
        let objectiveMeasurements = measurementType + " " + operationValue(sign: operation) + " " + targetValue + " " + unitOfMeasurement
        let objectiveInstruction = JSON(objectiveDetails)["instructions"].stringValue
        let objectiveDescription = JSON(objectiveDetails)["description"].stringValue
        
        self.objectiveDescription.text = objectiveDescription
        if objectiveInstruction == "" {
            self.objectiveInstruction.text = "NA"
        }else{
            self.objectiveInstruction.text = objectiveInstruction
        }
        
        self.objectiveMeasurements.text = objectiveMeasurements
        
        DispatchQueue.main.async {
            if self.measurementType == "Qualitative" {
                self.achievementLabel.text = "Achievement(Qualitative)"
                self.achievementsTextView.keyboardType = .default
                self.achievementsTextView.text = "Describe"
            }else{
                self.achievementLabel.text = "Achievement(Quantity/Percentage)"
                self.achievementsTextView.keyboardType = .decimalPad
                self.achievementsTextView.text = "Quantity/Percentage"
            }
        }
        
    }
    
    func operationValue(sign: String) -> String {
        
        var value = String()
        
        switch sign {
        case "=":
            value = "Equal to"
        break
        case "<":
            value = "Less than"
        break
        case "<=":
            value = "Less than or equal to"
        break
        case ">":
            value = "Greater than"
        break
        case ">=":
            value = "Greater than or equal to"
        break
        default:
            value = ""
        }
        
        return value
    }
    
    func getObjectiDetails(){
        let clientId = JSON(objectiveDetails)["clientId"].intValue
        let goalId = JSON(objectiveDetails)["goalId"].intValue
        let goalObjectivesId = JSON(objectiveDetails)["id"].intValue
        guard let token = careKernelDefaults.value(forKey: kLoginToken) as? String else {
            careKernelDefaults.set(false, forKey: kIsLoggedIn)
            return }
        var clientVM = ClientDetailsViewModel()
        clientVM.clientId = clientId
        clientVM.token = token
        clientVM.getClientGoalsObjective(goalId: goalId, goalObjectiveId: goalObjectivesId) { response, success in
            if success {
                DispatchQueue.main.async {
                    let tempArray = JSON(response)["data"].arrayValue
                    
                    if tempArray.count != 0 {
                        
                        for value in tempArray {
                            self.detailsArray.add(value)
                        }
                        print(self.detailsArray)
                        self.achievementsTableView.reloadData()
                    }else{
                        self.noRecordLabel.isHidden = false
                    }
                }
            }
        }
    }
    
    func addAchievements(params: [String : Any]){
        addButton.isUserInteractionEnabled = false
        let clientId = JSON(objectiveDetails)["clientId"].intValue
        let goalId = JSON(objectiveDetails)["goalId"].intValue
        let goalObjectivesId = JSON(objectiveDetails)["id"].intValue
        guard let token = careKernelDefaults.value(forKey: kLoginToken) as? String else {
            careKernelDefaults.set(false, forKey: kIsLoggedIn)
            return }
        var clientVM = ClientDetailsViewModel()
        clientVM.clientId = clientId
        clientVM.token = token
        clientVM.addClientAchivemets(goalId: goalId, goalObjectiveId: goalObjectivesId, params: params) { response, success in
            if success {
                print(response)
                var cvm = CaseViewModel()
                let entityId = JSON(response)["caseNote"]["id"].intValue
                var fileName = "Note: " + "\(entityId)"
                fileName = fileName + ".jpg"
                DispatchQueue.main.async {
                    self.fileNameButton.setTitle(fileName, for: .normal)
                }
                let fileData = self.caseNotesImage?.jpegData(compressionQuality: 0.3)
                
               
                cvm.uploadDocuments(fileName: fileName, fileData: fileData ?? Data(), entity: "case-notes", entityId: entityId, clientID: clientId){ success in
                    if success {
                        self.showAlert("CareKernel", message: "Added successfully.", actions: ["Ok"]) { action in
                            if action == "Ok" {
                                self.hasAttachment = false
                                self.fileNameButton.isHidden = true
                                self.getObjectiDetails()
                            }
                        }
                        self.view.isUserInteractionEnabled = true
                        self.hud.dismiss()
                    }
                }

            }
            self.achievementsTextView.text = "Quantity/Percentage"
            self.notesTextView.text = "Message"
            self.isKeyboardDismiss = true
            self.resignFirstResponder()
            self.view.endEditing(true)
            self.addButton.isUserInteractionEnabled = true
        }
        
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        isKeyboardDismiss = true
        self.resignFirstResponder()
        view.endEditing(true)
        
    }

    func setupTextFields() {
            let toolbar = UIToolbar()
            let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace,
                                            target: nil, action: nil)
            let doneButton = UIBarButtonItem(title: "Done", style: .done,
                                             target: self, action: #selector(doneButtonTapped))
            
            toolbar.setItems([flexSpace, doneButton], animated: true)
            toolbar.sizeToFit()
            
        achievementsTextView.inputAccessoryView = toolbar
        notesTextView.inputAccessoryView = toolbar
        }
        
        @objc func doneButtonTapped() {
            isKeyboardDismiss = true
            view.endEditing(true)
        }
}

extension ObjectivesViewController : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        detailsArray.count
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 143
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AchievementsCell", for: indexPath) as! achievementsCell
        
        let objectiveID = JSON(detailsArray)[indexPath.row]["goalObjectiveId"].intValue
        let achievementValue = JSON(detailsArray)[indexPath.row]["value"].stringValue
        let descriptionString = JSON(detailsArray)[indexPath.row]["goalObjective"]["description"].stringValue
        
        cell.objectiveIdLabel.text = "GPID - " + "\(objectiveID)"
        if achievementValue == "" {
            cell.achievementsLabel.text = "NA"
        }else{
            cell.achievementsLabel.text = achievementValue
        }
        
        if descriptionString == "" {
            cell.objectiveDescriptionLabel.text = ""
        }else {
            cell.objectiveDescriptionLabel.text = descriptionString
        }
        
        
        return cell
    }
    
    
}

class achievementsCell : UITableViewCell {
    @IBOutlet weak var objectiveIdLabel: UILabel!
    @IBOutlet weak var achievementsLabel: UILabel!
    
    @IBOutlet weak var objectiveDescriptionLabel: UILabel!
}

extension ObjectivesViewController: UITextViewDelegate{
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView == achievementsTextView {
            if textView.text == "Quantity/Percentage" || textView.text == "Describe"{
                textView.text = ""
            }
        }else if textView == notesTextView {
            if textView.text == "Message"{
                textView.text = ""
            }
        }
        
    }
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView == achievementsTextView {
            if textView.text == ""{
                if self.measurementType == "Qualitative" {
                    textView.text = "Describe"
                }else{
                    textView.text = "Quantity/Percentage"
                }
                
            }
        }else if textView == notesTextView {
            if textView.text == ""{
                textView.text = "Message"
            }
        }
        
        if !isKeyboardDismiss {
            if textView == achievementsTextView{
                notesTextView.becomeFirstResponder()
            }
        }else{
//            self.resignFirstResponder()
        }
        isKeyboardDismiss = false
    }
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        return true
    }
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool{
        if textView == achievementsTextView{
            if text == "\n" {
                isKeyboardDismiss = false
//                textView.resignFirstResponder()
                return false
            }
        }
        return true
    }
    func textViewDidChange(_ textView: UITextView) {
        if textView == achievementsTextView{
            achievementsValue = textView.text
        }else if textView == notesTextView{
            notesValue = textView.text
        }
        
    }
    
}
