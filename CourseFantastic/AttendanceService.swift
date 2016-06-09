//
//  AttendanceService.swift
//  CourseFantastic
//
//  Created by Lee Kelly on 3/05/2016.
//  Copyright © 2016 LMK Technologies. All rights reserved.
//

import Foundation
import CoreData


class AttendanceService {
    
    static func checkIn(subjectDelivery: SubjectDelivery) throws {
        
        guard let managedObjectContext = AppDelegate.instance()?.managedObjectContext else {
            throw NSError(domain: "CourseFantastic", code: -99, userInfo: [NSLocalizedDescriptionKey: "We couldn't load the database."])
        }
        
        guard let attendance = NSEntityDescription.insertNewObjectForEntityForName("Attendance", inManagedObjectContext: managedObjectContext) as? Attendance else {
            throw NSError(domain: "CourseFantastic", code: -99, userInfo: [NSLocalizedDescriptionKey: "We couldn't create an attendance for the database."])
        }
        
        subjectDelivery.attendance = attendance
        
        try managedObjectContext.save()
        
    }
    
    static func checkOut(subjectDelivery: SubjectDelivery) throws {
        
        guard let managedObjectContext = AppDelegate.instance()?.managedObjectContext else {
            throw NSError(domain: "CourseFantastic", code: -99, userInfo: [NSLocalizedDescriptionKey: "We couldn't load the database."])
        }
        
        subjectDelivery.attendance?.complete = true
        
        try managedObjectContext.save()
        
    }
    
}
