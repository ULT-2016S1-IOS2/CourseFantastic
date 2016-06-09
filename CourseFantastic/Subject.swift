//
//  Subject.swift
//  CourseFantastic
//
//  Created by Lee Kelly on 19/04/2016.
//  Copyright © 2016 LMK Technologies. All rights reserved.
//

import Foundation
import CoreData


class Subject: NSManagedObject {
    
    @NSManaged var code: String
    @NSManaged var name: String
    @NSManaged var info: String?
    @NSManaged var timetable: Set<SubjectDelivery>?
    @NSManaged var course: Course
    
}

extension Subject {
    
    func addTimetableItem(subjectDelivery: SubjectDelivery) -> SubjectDelivery {
        
        subjectDelivery.subject = self
//        timetable?.insert(subjectDelivery)
        
        return subjectDelivery
    }
    
}
