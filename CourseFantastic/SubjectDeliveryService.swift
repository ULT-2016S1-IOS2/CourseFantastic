//
//  SubjectDeliveryService.swift
//  CourseFantastic
//
//  Created by Lee Kelly on 27/04/2016.
//  Copyright © 2016 LMK Technologies. All rights reserved.
//

import Foundation
import CoreData
import SwiftyJSON


class SubjectDeliveryService {
    
    static func createSubjectDelivery(json: JSON) throws -> SubjectDelivery {
        
        /*
        {
            "Start" : "2016-05-09T13:00:00",
            "Location" : "GG.27",
            "End" : "2016-05-09T17:00:00",
            "Id" : 323
        }
        */
        
        guard let itemId = json["Id"].int else {
            throw NSError(domain: "CourseFantastic", code: -99, userInfo: [NSLocalizedDescriptionKey: "We couldn't process the information received."])
        }
        
        guard let start = json["Start"].string else {
            throw NSError(domain: "CourseFantastic", code: -99, userInfo: [NSLocalizedDescriptionKey: "We couldn't process the information received."])
        }
        
        guard let end = json["End"].string else {
            throw NSError(domain: "CourseFantastic", code: -99, userInfo: [NSLocalizedDescriptionKey: "We couldn't process the information received."])
        }
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        
        guard let startDate = dateFormatter.dateFromString(start) else {
            throw NSError(domain: "CourseFantastic", code: -99, userInfo: [NSLocalizedDescriptionKey: "We couldn't process the date format."])
        }
        
        guard let endDate = dateFormatter.dateFromString(end) else {
            throw NSError(domain: "CourseFantastic", code: -99, userInfo: [NSLocalizedDescriptionKey: "We couldn't process the date format."])
        }
        
        let location = json["Location"].string
        
        guard let managedObjectContext = (UIApplication.sharedApplication().delegate as? AppDelegate)?.managedObjectContext else {
            throw NSError(domain: "CourseFantastic", code: -99, userInfo: [NSLocalizedDescriptionKey: "We couldn't load the database."])
        }
        
        guard let subjectDelivery = NSEntityDescription.insertNewObjectForEntityForName("SubjectDelivery", inManagedObjectContext: managedObjectContext) as? SubjectDelivery else {
            throw NSError(domain: "CourseFantastic", code: -99, userInfo: [NSLocalizedDescriptionKey: "We couldn't create a subject delivery for the database."])
        }
        
        subjectDelivery.itemId = itemId
        subjectDelivery.startDate = startDate
        subjectDelivery.endDate = endDate
        subjectDelivery.location = location
        subjectDelivery.setDateOnly()
        
        return subjectDelivery
    }
    
}
