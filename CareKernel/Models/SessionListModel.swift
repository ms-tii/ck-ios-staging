//
//  SessionListModel.swift
//  CareKernel
//
//  Created by Mohit Sharma on 15/10/21.
//

import Foundation

// MARK: - Session
struct SessionResponseList {
    let data: [Datum]
    let meta: Meta
}

// MARK: - Datum
struct Datum {
    let displayID: String
    let id: Int
    let startDate, endDate, datumDescription: String
    let otherLocation, comments: NSNull
    let serviceWorkerMessage: String
    let isRecurring, isCancelled: Bool
    let cancellationReason, isTravelClaimable, travelArea, daysOfWeek: NSNull
    let repeatInterval, repeatEnds, repeatEndDate, repeatEndOccurences: NSNull
    let batchID: NSNull
    let isDelivered: Bool
    let siteID, organisationID, creatorID: Int
    let updaterID: NSNull
    let clientID, serviceAgreementID, serviceAgreementLineItemID, serviceAgreementCategoryID: Int
    let invoiceID, extractID: NSNull
    let createdAt, updatedAt: String
    let deletedAt: NSNull
    let site: Site
    let client: Client
    let clients: [Any?]
    let sessionUsers: [Client]
    let extract: NSNull
}

// MARK: - Client
struct Client {
    let fullName: String
    let avatarURL: NSNull?
    let id: Int
    let firstName, lastName: String
    let avatar: NSNull
}

// MARK: - Site
struct Site {
    let id: Int
    let name: String
}

// MARK: - Meta
struct Meta {
    let limit, offset, totalRows, pages: Int
}


struct SessionResponseModel {
    var success = false
    var errorMessage: String?
    var successMessage: String?
    var data: [Any]?
    var meta: [String:Any]?
}

// MARK: - Client
struct ClientDetails: Codable {
    let id: Int
    let fullName: String
    let hasAlerts: Bool
    let lineItem: [String]
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case fullName = "fullName"
        case hasAlerts = "hasAlerts"
        case lineItem = "lineItem"
    }
}
/*{
    "displayId": "SES-18",
    "id": 18,
    "startDate": "2021-10-31T08:33:59.182Z",
    "endDate": "2021-10-31T17:30:11.359Z",
    "description": "Baby care",
    "otherLocation": "Riverstone",
    "comments": "2 year old baby",
    "serviceWorkerMessage": "Client is very fragile to handle",
    "isRecurring": true,
    "isCancelled": false,
    "cancellationReason": null,
    "isTravelClaimable": true,
    "travelArea": "very-remote",
    "daysOfWeek": [
        "SUN"
    ],
    "repeatInterval": "week",
    "repeatEnds": "on",
    "repeatEndDate": "2021-11-08T05:40:26.924Z",
    "repeatEndOccurences": null,
    "batchID": null,
    "isDelivered": false,
    "siteId": null,
    "organisationId": 3,
    "creatorId": 7,
    "updaterId": null,
    "clientId": 25,
    "serviceAgreementId": 1,
    "serviceAgreementLineItemId": 1,
    "serviceAgreementCategoryId": 1,
    "invoiceId": null,
    "extractId": null,
    "createdAt": "2021-11-01T05:41:03.436Z",
    "updatedAt": "2021-11-01T05:41:03.436Z",
    "deletedAt": null,
    "site": null,
    "client": {
        "fullName": "Jack Smith",
        "id": 25,
        "firstName": "Jack",
        "lastName": "Smith"
    },
    "clients": [],
    "sessionUsers": [
        {
            "fullName": "Taranjeet Singh",
            "id": 8,
            "firstName": "Taranjeet",
            "lastName": "Singh",
            "SessionUser": {
                "sessionId": 18,
                "userId": 8,
                "clockOnAt": null,
                "clockOnLat": null,
                "clockOnLong": null,
                "clockOffAt": null,
                "clockOffLat": null,
                "clockOffLong": null,
                "travelKm": null,
                "notes": null,
                "createdAt": "2021-11-01T05:41:03.486Z",
                "updatedAt": "2021-11-01T05:41:03.486Z"
            }
        },
        {
            "fullName": "Komal Gupta",
            "id": 11,
            "firstName": "Komal",
            "lastName": "Gupta",
            "SessionUser": {
                "sessionId": 18,
                "userId": 11,
                "clockOnAt": null,
                "clockOnLat": null,
                "clockOnLong": null,
                "clockOffAt": null,
                "clockOffLat": null,
                "clockOffLong": null,
                "travelKm": null,
                "notes": null,
                "createdAt": "2021-11-01T05:41:03.500Z",
                "updatedAt": "2021-11-01T05:41:03.500Z"
            }
        },
        {
            "fullName": "Mohit Sharma",
            "id": 12,
            "firstName": "Mohit",
            "lastName": "Sharma",
            "SessionUser": {
                "sessionId": 18,
                "userId": 12,
                "clockOnAt": null,
                "clockOnLat": null,
                "clockOnLong": null,
                "clockOffAt": null,
                "clockOffLat": null,
                "clockOffLong": null,
                "travelKm": null,
                "notes": null,
                "createdAt": "2021-11-01T05:41:03.481Z",
                "updatedAt": "2021-11-01T05:41:03.481Z"
            }
        },
        {
            "fullName": "Aman Kaur",
            "id": 17,
            "firstName": "Aman",
            "lastName": "Kaur",
            "SessionUser": {
                "sessionId": 18,
                "userId": 17,
                "clockOnAt": null,
                "clockOnLat": null,
                "clockOnLong": null,
                "clockOffAt": null,
                "clockOffLat": null,
                "clockOffLong": null,
                "travelKm": null,
                "notes": null,
                "createdAt": "2021-11-01T05:41:03.474Z",
                "updatedAt": "2021-11-01T05:41:03.474Z"
            }
        }
    ],
    "invoice": null
}*/
