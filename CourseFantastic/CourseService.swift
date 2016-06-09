//
//  CourseService.swift
//  CourseFantastic
//
//  Created by Lee Kelly on 27/04/2016.
//  Copyright © 2016 LMK Technologies. All rights reserved.
//

import Foundation
import CoreData
import SwiftyJSON


class CourseService {
    
    static func createCourse(json: JSON) throws -> Course {
        
        /*
        {
            "Name" : "Diploma of Software Development",
            "EndDate" : "2016-06-17T00:00:00",
            "Description" : "This qualification provides the skills and knowledge for an individual to be competent in programming and software development.\r\n\r\nA person with this qualification would create new software products to meet an initial project brief or customise existing software products to meet customer needs.",
            "Version" : "1",
            "Code" : "P50715PGD1",
            "StartDate" : "2016-02-15T00:00:00"
        }
        */
        
        guard let code = json["Code"].string else {
            throw NSError(domain: "CourseFantastic", code: -99, userInfo: [NSLocalizedDescriptionKey: "We couldn't process the information received."])
        }
        
        guard let name = json["Name"].string else {
            throw NSError(domain: "CourseFantastic", code: -99, userInfo: [NSLocalizedDescriptionKey: "We couldn't process the information received."])
        }
        
        let info = json["Description"].string
        
        guard let student = try StudentService.getStudent() else {
            throw NSError(domain: "CourseFantastic", code: -99, userInfo: [NSLocalizedDescriptionKey: "We couldn't load your profile."])
        }
        
        guard let managedObjectContext = (UIApplication.sharedApplication().delegate as? AppDelegate)?.managedObjectContext else {
            throw NSError(domain: "CourseFantastic", code: -99, userInfo: [NSLocalizedDescriptionKey: "We couldn't load the database."])
        }
        
        guard let course = NSEntityDescription.insertNewObjectForEntityForName("Course", inManagedObjectContext: managedObjectContext) as? Course else {
            throw NSError(domain: "CourseFantastic", code: -99, userInfo: [NSLocalizedDescriptionKey: "We couldn't create a course for the database."])
        }
        
        course.code = code
        course.name = name
        course.info = info
        
        if let version = json["Version"].string {
            course.version = Int(version)
        }
        
//        student.enrol(inCourse: course)
        student.addEnrolmentsObject(course)
        
//        try managedObjectContext.save()
        
        return course
    }
    
    static func removeCourse(course: Course) throws {
        
        guard let managedObjectContext = (UIApplication.sharedApplication().delegate as? AppDelegate)?.managedObjectContext else {
            throw NSError(domain: "CourseFantastic", code: -99, userInfo: [NSLocalizedDescriptionKey: "We couldn't load the database."])
        }
        
        let calendarService = CalendarService()
        calendarService.attemptAccess({
            
            do {
                try calendarService.removeEvents(forCourse: course)
            } catch {
                print(error)
            }
            
        })
        
        managedObjectContext.deleteObject(course)

        try managedObjectContext.save()
    }
    
}
