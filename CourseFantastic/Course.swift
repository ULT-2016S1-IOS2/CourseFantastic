//
//  Course.swift
//  CourseFantastic
//
//  Created by Lee Kelly on 19/04/2016.
//  Copyright © 2016 LMK Technologies. All rights reserved.
//

import Foundation
import CoreData


class Course: NSManagedObject {
    
    @NSManaged var id: NSNumber
    @NSManaged var enrolmentId: NSNumber
    @NSManaged var code: String
    @NSManaged var name: String
    @NSManaged var info: String?
    @NSManaged var version: NSNumber?
    @NSManaged var subjects: Set<Subject>?
    @NSManaged var student: Student
    
}

extension Course {
    
    func addSubject(subject: Subject) -> Subject {
        
        subject.course = self
//        subjects?.insert(subject)
        
        return subject
    }
    
    static func fetchRequest() -> NSFetchRequest {
        
        let fetchRequest = NSFetchRequest(entityName: "Course")
        let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        return fetchRequest
    }
    
}
