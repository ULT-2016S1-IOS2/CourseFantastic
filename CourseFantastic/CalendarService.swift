//
//  CalendarService.swift
//  CourseFantastic
//
//  Created by Lee Kelly on 19/04/2016.
//  Copyright © 2016 LMK Technologies. All rights reserved.
//

import Foundation
import EventKit


class CalendarService {
    
    let eventStore: EKEventStore
    let calendarId = "TAFECalendar"
    
    private var calendar: EKCalendar?
    
    init() {
        eventStore = EKEventStore()
    }
    
    // MARK: - Authorization
    
    func attemptAccess(accessGrantedHandler: () -> Void) {
        
        let status = EKEventStore.authorizationStatusForEntityType(.Event)
        switch (status) {
        case .NotDetermined:
            // Occurs on first-run
            requestAccessToCalendar(accessGrantedHandler)
            
        case .Authorized:
            // We have access to the Calendar app
            accessGrantedHandler()
            
        case .Restricted, .Denied:
            // Take user to Settings to give us permission
            displaySettings()
        }
        
    }
    
    private func requestAccessToCalendar(accessGrantedHandler: () -> Void) {
        
        eventStore.requestAccessToEntityType(.Event, completion: {
            (accessGranted: Bool, error: NSError?) in
            
            if accessGranted {
                dispatch_async(dispatch_get_main_queue(), {
                    
                    accessGrantedHandler()
                    
                })
            } else {
                dispatch_async(dispatch_get_main_queue(), {
                    self.displaySettings()
                })
            }
        })
        
    }
    
    private func displaySettings() {
        
        let openSettingsUrl = NSURL(string: AppDelegate.settingsURLString())
        AppDelegate.sharedApplication().openURL(openSettingsUrl!)
        
    }
    
    // MARK: - Calendar
    
    func createCalendar() throws -> EKCalendar {
        
        // Check calendar already exists
        if let calendar = getCalendar() {
            return calendar
        }
        
        // Use Event Store to create a new calendar instance
        // Configure its title
        let newCalendar = EKCalendar(forEntityType: .Event, eventStore: eventStore)
        newCalendar.title = "TAFE"
        newCalendar.source = eventStore.defaultCalendarForNewEvents.source
        
        // Save the calendar using the Event Store instance
        try eventStore.saveCalendar(newCalendar, commit: true)
        
        // Store the new Calenders identifier in UserDefaults
        NSUserDefaults.standardUserDefaults().setObject(newCalendar.calendarIdentifier, forKey: calendarId)
        
        return newCalendar
    }
    
    func getCalendar() -> EKCalendar? {
        
        guard let calendar = self.calendar else {
            
            if let identifier = NSUserDefaults.standardUserDefaults().stringForKey(calendarId) {
                if let calendar = eventStore.calendarWithIdentifier(identifier) {
                    self.calendar = calendar
                    return calendar
                }
            }
            
            return nil
        }
        
        return calendar
    }
    
    static func displayCalendar(atDate date: NSDate) {
        
        let timeInterval = date.timeIntervalSinceReferenceDate
        let openCalendarUrl = NSURL(string: "calshow:\(timeInterval)")
        AppDelegate.sharedApplication().openURL(openCalendarUrl!)
        
    }
    
    // MARK: - Event
    
    func createEvent(inCalendar calendar: EKCalendar, forSubjectDelivery subjectDelivery: SubjectDelivery) throws -> SubjectDelivery {
        
        guard let calendar = getCalendar() else {
            throw NSError(domain: "CourseFantastic", code: -99, userInfo: [NSLocalizedDescriptionKey: "We couldn't load the \(calendarId)."])
        }
        
        if getEvent(subjectDelivery) != nil {
            throw NSError(domain: "CourseFantastic", code: -99, userInfo: [NSLocalizedDescriptionKey: "There's already an event for \(subjectDelivery.subject) @ \(subjectDelivery.startDate)."])
        }
        
        let event = EKEvent(eventStore: eventStore)
        
        event.title = subjectDelivery.subject.name
        event.startDate = subjectDelivery.startDate
        event.endDate = subjectDelivery.endDate
        event.calendar = calendar
        event.location = subjectDelivery.location
        
        subjectDelivery.eventId = try saveEvent(event).eventIdentifier
        
        return subjectDelivery
    }
    
    func createEvents(inCalendar calendar: EKCalendar, forCourse course: Course) throws {
        
        for subject in course.subjects! {
            
            for subjectDelivery in subject.timetable! {
                
                try createEvent(inCalendar: calendar, forSubjectDelivery: subjectDelivery)
                
            }
            
        }
        
    }
    
    private func saveEvent(event: EKEvent) throws -> EKEvent {
        
        try eventStore.saveEvent(event, span: .ThisEvent)
        
        return event
    }
    
    private func getEvent(subjectDelivery: SubjectDelivery) -> EKEvent? {
        
        if let identifier = subjectDelivery.eventId {
            if let event = eventStore.eventWithIdentifier(identifier) {
                return event
            }
        }
        
        return nil
    }
    
    func removeEvent(subjectDelivery: SubjectDelivery) throws {
        
        if let event = getEvent(subjectDelivery) {
            
            try eventStore.removeEvent(event, span: .ThisEvent)
            
        }
        
        subjectDelivery.eventId = nil
        
    }
    
    func removeEvents(forCourse course: Course) throws {
        
        for subject in course.subjects! {
            
            for subjectDelivery in subject.timetable! {
                
                try removeEvent(subjectDelivery)
                
            }
            
        }
        
    }
    
    // MARK: - Event Note
    
    func setNote(note: String, forSubjectDelivery subjectDelivery: SubjectDelivery) throws {
        
        guard let event = getEvent(subjectDelivery) else {
            throw NSError(domain: "CourseFantastic", code: -99, userInfo: [NSLocalizedDescriptionKey: "We couldn't load the event."])
        }
        
        event.notes = note
        try saveEvent(event)
        
    }
    
    // MARK: - Event Alarm
    
    func setAlarm(date: NSDate, forSubjectDelivery subjectDelivery: SubjectDelivery) throws {
        
        guard let event = getEvent(subjectDelivery) else {
            throw NSError(domain: "CourseFantastic", code: -99, userInfo: [NSLocalizedDescriptionKey: "We couldn't load the event."])
        }
        
        removeAlarms(event)
        
        let alarm = EKAlarm(absoluteDate: date)
        event.addAlarm(alarm)
        
        try saveEvent(event)
        
    }
    
    private func removeAlarms(event: EKEvent) {
        
        if let alarms = event.alarms {
            for alarm in alarms {
                event.removeAlarm(alarm)
            }
        }
        
    }
    
}
