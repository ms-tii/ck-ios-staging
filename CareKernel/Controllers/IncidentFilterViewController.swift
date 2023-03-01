//
//  IncidentFilterViewController.swift
//  CareKernel
//
//  Created by Mohit Sharma on 17/02/22.
//

import UIKit

class IncidentFilterViewController: UIViewController {

    @IBOutlet var datePicker: UIDatePicker!
    
    var selectedDateType = String()
    var minimumToDate = Date()
    var maximumFromDate = Date()
    var fromDate = ""
    var toDate = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if selectedDateType == "From" {
            datePicker.minimumDate = .distantPast
            if self.toDate == "" || toDate == "To" {
                datePicker.maximumDate = Date()
            }else{
                maximumFromDate = iso860ToString(dateString: toDate)
                datePicker.maximumDate = maximumFromDate
                
            }
          
        }else{
            if fromDate != "" || fromDate != "From"{
                let dateFormatter = DateFormatter()
                        dateFormatter.dateStyle = DateFormatter.Style.long
                        dateFormatter.dateFormat = "dd/MM/yyyy"
                minimumToDate = dateFormatter.date(from: fromDate) ?? Date()
                print(minimumToDate)
            datePicker.minimumDate = minimumToDate
            }
        }

    }
    
    @IBAction func doneButtonAction(_ sender: UIButton) {
        
        if selectedDateType == "From" {
            if fromDate == "" || fromDate == "From"{
                setDateUI(selectedDate: Date())
            }
        }else{
            if self.toDate == "" || toDate == "To" {
                setDateUI(selectedDate: Date())
            }
        }
        let dateFilters = ["fromDate": self.fromDate, "toDate": self.toDate] as [String : Any]
        careKernelDefaults.set(dateFilters, forKey: "incidentsFilterDate")
        self.dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func cancleButtonAction(_ sender: UIButton) {
        if selectedDateType == "From" {
            let dateFilters = ["fromDate": "From", "toDate": "To"] as [String : Any]
            careKernelDefaults.set(dateFilters, forKey: "incidentsFilterDate")
        }else{
            let dateFilters = ["fromDate": fromDate, "toDate": "To"] as [String : Any]
            careKernelDefaults.set(dateFilters, forKey: "incidentsFilterDate")
        }
        
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func datePickerValueChanged(_ sender: UIDatePicker) {
        setDateUI(selectedDate: datePicker.date)
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
    
    func setDateUI(selectedDate: Date){
        let date = getFormattedDate(date: selectedDate, format: "dd/MM/yyyy")
        print(date)
        if selectedDateType == "From" {
            minimumToDate = selectedDate
            self.fromDate = date
          
        }else{
            self.toDate = date
            
            maximumFromDate = selectedDate

        }
        let dateFilters = ["fromDate": self.fromDate, "toDate": self.toDate] as [String : Any]
        careKernelDefaults.set(dateFilters, forKey: "incidentsFilterDate")
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
