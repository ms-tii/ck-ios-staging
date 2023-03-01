//
//  FiltersModel.swift
//  CareKernel
//
//  Created by Mohit Sharma on 23/11/21.
//

import Foundation

struct FiltersModel {
    var todoStatus: String? = nil
    var inprogressStatus: String? = nil
    var doneStatus: String? = nil
    var blockedStatus: String? = nil
    var priority: String? = nil
    var isArchived: String? = nil
    var category: String? = nil
    var fromDate: String? = nil
    var toDate: String? = nil
    
    init(todoStatus: String, inprogressStatus: String, doneStatus: String, blockedStatus: String, priority: String, isArchived: String, category: String, fromDate: String, toDate: String) {
        self.todoStatus = todoStatus
        self.inprogressStatus = inprogressStatus
        self.doneStatus = doneStatus
        self.blockedStatus = blockedStatus
        self.priority = priority
        self.isArchived = isArchived
        self.category = category
        self.fromDate = fromDate
        self.toDate = toDate
    }
    
    func getJson() -> [String:Any] {
        return ["TodoStatus": todoStatus!, "InprogressStatus": inprogressStatus!, "DoneStatus": doneStatus!, "BlockedStatus": blockedStatus!, "Priority": priority!, "Is Archived": isArchived!, "Category": category!, "From": fromDate!, "To": toDate!]
    }
}
