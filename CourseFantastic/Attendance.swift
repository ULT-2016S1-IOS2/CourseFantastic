//
//  Attendance.swift
//  CourseFantastic
//
//  Created by Lee Kelly on 19/04/2016.
//  Copyright © 2016 LMK Technologies. All rights reserved.
//

import Foundation
import CoreData


class Attendance: NSManagedObject {
    
    @NSManaged var complete: NSNumber
    @NSManaged var subjectDelivery: SubjectDelivery
    
}
