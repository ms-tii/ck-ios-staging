//
//  SessionsViewController.swift
//  CareKernel
//
//  Created by Mohit Sharma on 05/04/22.
//

import UIKit

class SessionsViewController: UIViewController {

    @IBOutlet weak var detailsButton: UIButton!
    @IBOutlet weak var allowancesButton: UIButton!
    @IBOutlet weak var casenotesButton: UIButton!
    @IBOutlet weak var activityLogButton: UIButton!
    @IBOutlet weak var detailsContainer: UIView!
    @IBOutlet weak var allowancesContainer: UIView!
    @IBOutlet weak var activityLogContainer: UIView!
    @IBOutlet weak var casenotesContainer: UIView!
    
    var sessionId = 0
    var sessionDetailsViewController : SessionDetailsViewController?
    var allowancesViewController : AllowancesViewController?
    var sessionCaseNotesViewController : SessionCaseNotesViewController?
    var activityLogViewController : ActivityLogViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        allowancesContainer.isHidden = true
        casenotesContainer.isHidden = true
        activityLogContainer.isHidden = true
//        detailsButton.setTitleColor(.white, for: .normal)
        if let vc = sessionDetailsViewController {
            vc.sessionId = self.sessionId
            vc.setDetails()
        }
        self.allowancesButton.titleLabel?.adjustsFontSizeToFitWidth = true
        self.activityLogButton.titleLabel?.adjustsFontSizeToFitWidth = true
    }
    
    @IBAction func backButtonAction(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    

    
    @IBAction func detailButtonAction(_ sender: UIButton) {
        self.resignFirstResponder()
        view.endEditing(true)
//        detailsButton.setTitleColor(.white, for: .normal)
        casenotesButton.setTitleColor(.white, for: .normal)
        activityLogButton.setTitleColor(.white, for: .normal)
        detailsButton.setTitleColor(.lightText, for: .normal)
        allowancesButton.setTitleColor(.white, for: .normal)
        detailsContainer.isHidden = false
        allowancesContainer.isHidden = true
        casenotesContainer.isHidden = true
        activityLogContainer.isHidden = true
//        allowancesButton.titleLabel?.textColor = UIColor(named: "light white tab font")
//        casenotesButton.titleLabel?.textColor = UIColor(named: "light white tab font")
//        activityLogButton.titleLabel?.textColor = UIColor(named: "light white tab font")
    }
    
    @IBAction func allowancesButtonAction(_ sender: UIButton) {
        self.resignFirstResponder()
        view.endEditing(true)
        if let vc = allowancesViewController {
            vc.sessionId = self.sessionId
            vc.setDetails()
        }

        casenotesButton.setTitleColor(.white, for: .normal)
        activityLogButton.setTitleColor(.white, for: .normal)
        detailsButton.setTitleColor(.white, for: .normal)
        allowancesButton.setTitleColor(.lightText, for: .normal)
        detailsContainer.isHidden = true
        allowancesContainer.isHidden = false
        casenotesContainer.isHidden = true
        activityLogContainer.isHidden = true
//        detailsButton.titleLabel?.textColor = UIColor(named: "light white tab font")
//        casenotesButton.titleLabel?.textColor = UIColor(named: "light white tab font")
//        activityLogButton.titleLabel?.textColor = UIColor(named: "light white tab font")
    }
    
    @IBAction func caseNotesButtonAction(_ sender: UIButton) {
        self.resignFirstResponder()
        view.endEditing(true)
        if let vc = sessionCaseNotesViewController {
            vc.sessionId = self.sessionId
            vc.setDetails()
        }
        casenotesButton.setTitleColor(.lightText, for: .normal)
        activityLogButton.setTitleColor(.white, for: .normal)
        detailsButton.setTitleColor(.white, for: .normal)
        allowancesButton.setTitleColor(.white, for: .normal)
        activityLogButton.setTitle("Activity Log", for: .normal)
        detailsContainer.isHidden = true
        allowancesContainer.isHidden = true
        casenotesContainer.isHidden = false
        activityLogContainer.isHidden = true
//        detailsButton.titleLabel?.textColor = UIColor(named: "light white tab font")
//        allowancesButton.titleLabel?.textColor = UIColor(named: "light white tab font")
//        activityLogButton.titleLabel?.textColor = UIColor(named: "light white tab font")
    }
    @IBAction func activityLogButtonAction(_ sender: UIButton) {
        self.resignFirstResponder()
        view.endEditing(true)
        if let vc = activityLogViewController {
            vc.sessionId = self.sessionId
            vc.setDetails()
        }
        activityLogButton.setTitleColor(.lightText, for: .normal)
        detailsButton.setTitleColor(.white, for: .normal)
        allowancesButton.setTitleColor(.white, for: .normal)
        casenotesButton.setTitleColor(.white, for: .normal)
        detailsContainer.isHidden = true
        allowancesContainer.isHidden = true
        casenotesContainer.isHidden = true
        activityLogContainer.isHidden = false
//        detailsButton.titleLabel?.textColor = UIColor(named: "light white tab font")
//        allowancesButton.titleLabel?.textColor = UIColor(named: "light white tab font")
//        casenotesButton.titleLabel?.textColor = UIColor(named: "light white tab font")
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "toSessionDetails" {
            if let vc = segue.destination as? SessionDetailsViewController {
                self.sessionDetailsViewController = vc
            }
        }else if segue.identifier == "toSessionAllowances" {
            if let vc = segue.destination as? AllowancesViewController {
                self.allowancesViewController = vc
            }
        }else if segue.identifier == "toSessionCasenotes" {
            if let vc = segue.destination as? SessionCaseNotesViewController {
                self.sessionCaseNotesViewController = vc
            }
        }else if segue.identifier == "toActivityLog" {
            if let vc = segue.destination as? ActivityLogViewController {
                self.activityLogViewController = vc
            }
        }
    }
    

}

extension SessionsViewController: TabStatusDelegate {
    func tabStatusChanged(status: String) {
        switch status {
        case "Details" :
            detailsButton.setTitleColor(.white, for: .normal)
            allowancesButton.titleLabel?.textColor = UIColor(named: "light white tab font")
            casenotesButton.titleLabel?.textColor = UIColor(named: "light white tab font")
        case "Allowances" :
            allowancesButton.setTitleColor(.white, for: .normal)
            detailsButton.titleLabel?.textColor = UIColor(named: "light white tab font")
            casenotesButton.titleLabel?.textColor = UIColor(named: "light white tab font")
        case "Casenotes" :
            casenotesButton.setTitleColor(.white, for: .normal)
            allowancesButton.titleLabel?.textColor = UIColor(named: "light white tab font")
            detailsButton.titleLabel?.textColor = UIColor(named: "light white tab font")
        default:
            break
        }
    }
    
    
}
