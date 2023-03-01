//
//  Constants.swift
//  CareKernel
//
//  Created by Mohit Sharma on 02/09/21.
//

import Foundation
let careKernelDefaults = UserDefaults.standard

var kLoginToken = "loginToken"
var kUserId = "userId"
var kWorkerID = "serviceWorkerId"
var kUserEmailId = "email"
var kIsLoggedIn = "isLoggedIn"
let kLoggedInKey = "loggedIn"
var kSuccessfullLogin = false
var kTypeOfVerification = "email" // or code value taken from segue

let aboutURL = "https://carekernel.com/about/"
let helpURL = "https://carekernel.com/f-a-q/"

//Mock URL
let baseURL = "https://api.staging.carekernel.net/v1/"
//Production URL
//let baseURL = "https://api.carekernel.net/v1/"

let verifyUrl = baseURL + "auth/verify"
let setPasswordUrl = baseURL + "auth/password"
let loginUrl = baseURL + "auth/login"
let verifyCodeUrl = baseURL + "auth/verify-code"
let forgotPassUrl = baseURL + "auth/forgot"
let sessionsURL = baseURL + "sessions"
let sessionsListURL = sessionsURL + "?sessionUserIds="//append  userId&endDate=yyyy-mm-dd&startDate=yyyy-mm-dd
let clientDetailsURL = baseURL + "clients" // append clientID
let sessionDetailsURL = sessionsURL + "/" // append session ID
let caseNotesURL = baseURL + "clients/"// append (clientId)/case-notes"
let filesURL = baseURL + "files"
let tasksURL = baseURL + "tasks"
let userURL = baseURL + "users"
let taskCategoriesURL = baseURL + "task-categories"
let getFilesURL = baseURL + "files?entity="// append entityName & clientId=0
let getWorkerProfileURL = baseURL + "service-workers/" // append workerId (fetch from token with "sub" key )
let profileURL = baseURL + "users/" // append userID and change-password param
let incidentsURL = baseURL + "incidents?clientId="
let notificationURL = baseURL + "notifications?isRead=false&entityId=true&entityType=true"
let notificationOnOffURL = baseURL + "auth/logout"
let allowancesURL = baseURL + "allowances"
let wakeTimesURL = sessionsURL // append "/{sessionId}/wakeups"
/**
 * Global Instance of Header required for each API request
 */
let HEADER = [
    "Content-Type": "application/json"
]

let BearerHeader = [
    "Content-Type": "application/json",
    "Authorization": "Bearer \(String(describing: careKernelDefaults.value(forKey: kLoginToken)))"
]

enum verificationType: String {
    case signUp = "signUp"
    case verifyOTP = "verifyOTP"
}
