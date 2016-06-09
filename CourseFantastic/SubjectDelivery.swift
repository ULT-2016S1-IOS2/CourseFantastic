//
//  SubjectDelivery.swift
//  CourseFantastic
//
//  Created by Lee Kelly on 19/04/2016.
//  Copyright © 2016 LMK Technologies. All rights reserved.
//

import Foundation
import CoreData


class SubjectDelivery: NSManagedObject {
    
    @NSManaged var itemId: NSNumber
    @NSManaged var startDate: NSDate
    @NSManaged var endDate: NSDate
    @NSManaged var location: String?
    @NSManaged var eventId: String?
    @NSManaged var subject: Subject
    @NSManaged var attendance: Attendance?
    @NSManaged var dateOnly: NSDate
    @NSManaged var hasAlarm: NSNumber
    @NSManaged var hasNote: NSNumber
    
}

extension SubjectDelivery {
    
    static func fetchRequest() -> NSFetchRequest {
        
        let fetchRequest = NSFetchRequest(entityName: "SubjectDelivery")
        let dateOnlySort = NSSortDescriptor(key: "dateOnly", ascending: true)
        let startDateSort = NSSortDescriptor(key: "startDate", ascending: true)
        let endDatePredicate = NSPredicate(format: "endDate >= %@", NSDate())
        
        fetchRequest.sortDescriptors = [dateOnlySort, startDateSort]
        fetchRequest.predicate = endDatePredicate
        
        return fetchRequest
    }
    
    func setDateOnly() {
        
        let calendar = NSCalendar.currentCalendar()
        let unitFlags: NSCalendarUnit = [.Day, .Month, .Year]
        let components = calendar.components(unitFlags, fromDate: startDate)
        
        dateOnly = calendar.dateFromComponents(components)!
    }
    
    func runTime() -> String {
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        
        let start = dateFormatter.stringFromDate(startDate)
        let end = dateFormatter.stringFromDate(endDate)
        
        return "\(start) - \(end)"
    }
    
}