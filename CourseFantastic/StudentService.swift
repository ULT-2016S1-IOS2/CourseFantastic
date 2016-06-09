//
//  StudentService.swift
//  CourseFantastic
//
//  Created by Lee Kelly on 19/04/2016.
//  Copyright © 2016 LMK Technologies. All rights reserved.
//

import Foundation
import CoreData


class StudentService {
    
    static func createStudent(studentId: String, firstName: String, lastName: String, dob: NSDate?, email: String?) -> Student? {
        
        if let managedObjectContext = AppDelegate.instance()?.managedObjectContext {
            
            if let student = NSEntityDescription.insertNewObjectForEntityForName("Student", inManagedObjectContext: managedObjectContext) as? Student {
            
                student.studentId = studentId
                student.firstName = firstName
                student.lastName = lastName
                student.dob = dob
                student.email = email
                
                do {
                    try managedObjectContext.save()
                    return student
                } catch {
                    print(error)
                }
                
            }
            
        }
        
        return nil
    }
    
    static func getStudent() throws -> Student? {
        
        guard let managedObjectContext = AppDelegate.instance()?.managedObjectContext else {
            throw NSError(domain: "CourseFantastic", code: -99, userInfo: [NSLocalizedDescriptionKey: "We couldn't load the database."])
        }
        
        let students = try managedObjectContext.executeFetchRequest(Student.fetchRequest()) as! [Student]
        
        return students.first
    }
    
}