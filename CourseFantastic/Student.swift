//
//  Student.swift
//  CourseFantastic
//
//  Created by Lee Kelly on 19/04/2016.
//  Copyright © 2016 LMK Technologies. All rights reserved.
//

import Foundation
import CoreData


class Student: NSManagedObject {
    
    @NSManaged var studentId: String
    @NSManaged var firstName: String
    @NSManaged var lastName: String
    @NSManaged var email: String?
    @NSManaged var dob: NSDate?
    @NSManaged var enrolments: Set<Course>?
    
    @NSManaged func addEnrolmentsObject(course: Course)
    
}

extension Student {
    
    func enrol(inCourse course: Course) -> Course {
        course.student = self
//        enrolments?.insert(course)
        
        return course
    }
    
    // MARK: - JSON
    
    func toJSONParam() -> [String : AnyObject] {
        
        return [
            "Person": [
                "FirstName": firstName,
                "Surname": lastName,
//                "DoB": dob!,
                "Email": email!
            ]
            //,
//            "StudentId": studentId
        ]
        
    }
    
    static func fetchRequest() -> NSFetchRequest {
        
        let fetchRequest = NSFetchRequest(entityName: "Student")
        
        return fetchRequest
    }
    
}
