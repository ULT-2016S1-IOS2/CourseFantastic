//
//  SubjectService.swift
//  CourseFantastic
//
//  Created by Lee Kelly on 27/04/2016.
//  Copyright © 2016 LMK Technologies. All rights reserved.
//

import Foundation
import CoreData
import SwiftyJSON


class SubjectService {
    
    static func createSubject(json: JSON) throws -> Subject {
        
        /*
        {
            "Subject" : {
                "Code" : "SD",
                "Name" : "Software Development",
                "Description" : "Learn advanced concepts in Software Development, working on a real world project using the latest technologies."
            },
            "Timetable" : [
                {
                    "Start" : "2016-05-05T09:00:00",
                    "Location" : "GG.28",
                    "End" : "2016-05-05T13:00:00",
                    "Id" : 338
                },
                {
                    "Start" : "2016-05-05T14:00:00",
                    "Location" : "GG.28",
                    "End" : "2016-05-05T18:00:00",
                    "Id" : 354
                }
            ]
        }
        */
        
        guard let code = json["Subject"]["Code"].string else {
            throw NSError(domain: "CourseFantastic", code: -99, userInfo: [NSLocalizedDescriptionKey: "We couldn't process the information received."])
        }
        
        guard let name = json["Subject"]["Name"].string else {
            throw NSError(domain: "CourseFantastic", code: -99, userInfo: [NSLocalizedDescriptionKey: "We couldn't process the information received."])
        }
        
        let info = json["Subject"]["Description"].string
        
        guard let managedObjectContext = (UIApplication.sharedApplication().delegate as? AppDelegate)?.managedObjectContext else {
            throw NSError(domain: "CourseFantastic", code: -99, userInfo: [NSLocalizedDescriptionKey: "We couldn't load the database."])
        }
        
        guard let subject = NSEntityDescription.insertNewObjectForEntityForName("Subject", inManagedObjectContext: managedObjectContext) as? Subject else {
            throw NSError(domain: "CourseFantastic", code: -99, userInfo: [NSLocalizedDescriptionKey: "We couldn't create a subject for the database."])
        }
        
        subject.code = code
        subject.name = name
        subject.info = info
        
        return subject
    }
    
}
