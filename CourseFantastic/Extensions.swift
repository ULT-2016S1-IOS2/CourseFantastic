//
//  Extensions.swift
//  CourseFantastic
//
//  Created by Lee Kelly on 21/04/2016.
//  Copyright © 2016 LMK Technologies. All rights reserved.
//

import Foundation


extension NSDate {
    
    func extFormat() -> String {
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy"
        return dateFormatter.stringFromDate(self)
        
    }
    
    func titleFormat() -> String {
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "E, d MMM"
        return dateFormatter.stringFromDate(self)
        
    }
    
    func timeFormat() -> String {
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "h:mm a"
        return dateFormatter.stringFromDate(self)
        
    }
    
    func format(dateFormat: String) -> String {
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = dateFormat
        return dateFormatter.stringFromDate(self)
        
    }
    
    func isGreaterThanDate(dateToCompare : NSDate) -> Bool {
        return self.compare(dateToCompare) == NSComparisonResult.OrderedDescending
    }
    
    func isLessThanDate(dateToCompare : NSDate) -> Bool {
        return self.compare(dateToCompare) == NSComparisonResult.OrderedAscending
    }
    
    convenience init(day: Int, month: Int, year: Int) {
        let dateComponents = NSDateComponents()
        dateComponents.day = day
        dateComponents.month = month
        dateComponents.year = year
        
        let userCalendar = NSCalendar.currentCalendar()
        if let newDate = userCalendar.dateFromComponents(dateComponents) {
            self.init(timeIntervalSinceReferenceDate: newDate.timeIntervalSinceReferenceDate)
        } else {
            self.init()
        }
    }
    
}

extension String {
    
    func toDateString() -> String {
        
        let dateFormatter = NSDateFormatter()
        
        // 2016-05-01 14:00:00 +0000
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss ZZ"
        if let date = dateFormatter.dateFromString(self) {
            
            dateFormatter.dateFormat = "E, d MMM"
            
            return dateFormatter.stringFromDate(date)
        }
        
        return self
    }
    
    func toDate(dateFormat: String) -> NSDate? {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = dateFormat
        return dateFormatter.dateFromString(self)
    }
    
}

extension SequenceType {
    
    // Groups elements of self into a dictionary, by the keys given to keyFunc
    // Usage: <SequencType>.groupBy{ $0.property }
    
    func groupBy<U : Hashable>(@noescape keyFunc: Generator.Element -> U) -> [U:[Generator.Element]] {
        var dict: [U:[Generator.Element]] = [:]
        for el in self {
            let key = keyFunc(el)
            if case nil = dict[key]?.append(el) { dict[key] = [el] }
        }
        return dict
    }
    
}
