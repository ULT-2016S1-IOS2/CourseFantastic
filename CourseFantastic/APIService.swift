//
//  APIService.swift
//  CourseFantastic
//
//  Created by Lee Kelly on 21/04/2016.
//  Copyright © 2016 LMK Technologies. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON


enum APIServiceResponseType {
    case POSTStudent
    case POSTEnrol
    case POSTWithdraw
    case GETCourse
    case GETTimetable
    case GETTimetableVersion
    case POSTCheckIn
    case POSTCheckOut
}

protocol APIServiceDelegate {
    
    func apiServiceResponse(responseType: APIServiceResponseType, error: String?, json: JSON?)
    
}

class APIService {
    
    var delegate: APIServiceDelegate?
    
    let endpointDomain = "http://192.168.15.66:5000"
    let endpointLearner = "/api/learner"
    let endpointEnrol = "/api/enrolment/enrol"
    let endpointWithdraw = "/api/enrolment/withdraw"
    let endpointCourse = "/api/coursedeliveries"
    let endpointTimetableCourse = "/api/timetable/course"
    let endpointTimetableStudent = "/api/timetable/student"
    let endpointCheckIn = "/api/attendance/checkin"
    let endpointCheckOut = "/api/attendance/checkout"
    
    
    // MARK: - Student/Learner
    
    func postStudent(student: Student) {
        
        let endpoint = "\(endpointDomain)\(endpointLearner)"
        
        Alamofire.request(.POST, endpoint, parameters: student.toJSONParam(), encoding: .JSON)
            .validate()
            .responseData { response in
                
                var error = response.result.error?.localizedDescription
                if error != nil {
                    if let data = response.data {
                        error = String(data: data, encoding: NSUTF8StringEncoding)
                    }
                }
                
                var result: JSON?
                if let value = response.result.value {
                    result = JSON(data: value)
                }
                
                if let delegate = self.delegate {
                    delegate.apiServiceResponse(.POSTStudent, error: error, json: result)
                }
                
            }
        
    }
    
    // MARK: - Enrolment
    
    func postEnrolmentEnrol(student: Student, courseDeliveryId: Int) {
        
        let endpoint = "\(endpointDomain)\(endpointEnrol)"
        
        let params: [String : AnyObject] = [
            "StudentId": student.studentId,
            "CourseDeliveryId": courseDeliveryId
        ]
        
        Alamofire.request(.POST, endpoint, parameters: params, encoding: .JSON)
            .validate()
            .responseData { response in
                
                var error = response.result.error?.localizedDescription
                if error != nil {
                    if let data = response.data {
                        error = String(data: data, encoding: NSUTF8StringEncoding)
                    }
                }
                
                var result: JSON?
                if let value = response.result.value {
                    result = JSON(data: value)
                }
                
                if let delegate = self.delegate {
                    delegate.apiServiceResponse(.POSTEnrol, error: error, json: result)
                }
                
            }
        
    }
    
    func postEnrolmentWithdraw(student: Student, enrolmentId: Int) {
        
        let endpoint = "\(endpointDomain)\(endpointWithdraw)"
        
        let params: [String : AnyObject] = [
            "StudentId": student.studentId,
            "EnrolmentId": enrolmentId
        ]
        
        Alamofire.request(.POST, endpoint, parameters: params, encoding: .JSON)
            .validate()
            .responseData { response in
                
                var error = response.result.error?.localizedDescription
                if error != nil {
                    if let data = response.data {
                        error = String(data: data, encoding: NSUTF8StringEncoding)
                    }
                }
                
                var result: JSON?
                if let value = response.result.value {
                    result = JSON(data: value)
                }
                
                if let delegate = self.delegate {
                    delegate.apiServiceResponse(.POSTWithdraw, error: error, json: result)
                }
                
            }
        
    }
    
    // MARK: - Course
    
    func getCourse(courseDeliveryId: Int) {
        
        let endpoint = "\(endpointDomain)\(endpointCourse)/\(courseDeliveryId)"
        
        Alamofire.request(.GET, endpoint)
            .validate()
            .responseData { response in
                
                var error = response.result.error?.localizedDescription
                if error != nil {
                    if let data = response.data {
                        error = String(data: data, encoding: NSUTF8StringEncoding)
                    }
                }
                
                var result: JSON?
                if let value = response.result.value {
                    result = JSON(data: value)
                }
                
                if let delegate = self.delegate {
                    delegate.apiServiceResponse(.GETCourse, error: error, json: result)
                }
                
            }
        
    }
    
    // MARK: - Timetable
    
    func getTimetable(forCourseId id: Int) {
        
        let endpoint = "\(endpointDomain)\(endpointTimetableCourse)/\(id)"
        
        print(endpoint)
        
        Alamofire.request(.GET, endpoint)
            .validate()
            .responseData { response in
                
                var error = response.result.error?.localizedDescription
                if error != nil {
                    if let data = response.data {
                        error = String(data: data, encoding: NSUTF8StringEncoding)
                    }
                }
                
                var result: JSON?
                if let value = response.result.value {
                    result = JSON(data: value)
                }
                
                if let delegate = self.delegate {
                    delegate.apiServiceResponse(.GETTimetable, error: error, json: result)
                }
                
            }
        
    }
    
    func getTimetableVersion(forStudentId id: String) {
        
        let endpoint = "\(endpointDomain)\(endpointTimetableStudent)/\(id)/version"
        
        print(endpoint)
        
        Alamofire.request(.GET, endpoint)
            .validate()
            .responseData { response in
                
                var error = response.result.error?.localizedDescription
                if error != nil {
                    if let data = response.data {
                        error = String(data: data, encoding: NSUTF8StringEncoding)
                    }
                }
                
                var result: JSON?
                if let value = response.result.value {
                    result = JSON(data: value)
                }
                
                if let delegate = self.delegate {
                    delegate.apiServiceResponse(.GETTimetableVersion, error: error, json: result)
                }
                
        }
        
    }
    
    // MARK: - Attendance
    
    func postCheckIn(student: Student, subjectDelivery: SubjectDelivery) {
        
        let endpoint = "\(endpointDomain)\(endpointCheckIn)"
        
        let params: [String : AnyObject] = [
            "StudentId": student.studentId,
            "TimetableItemId": subjectDelivery.itemId
        ]
        
        Alamofire.request(.POST, endpoint, parameters: params, encoding: .JSON)
            .validate()
            .responseData { response in
                
                var error = response.result.error?.localizedDescription
                if error != nil {
                    if let data = response.data {
                        error = String(data: data, encoding: NSUTF8StringEncoding)
                    }
                }
                
                var result: JSON?
                if let value = response.result.value {
                    result = JSON(data: value)
                }
                
                if let delegate = self.delegate {
                    delegate.apiServiceResponse(.POSTCheckIn, error: error, json: result)
                }
                
        }
        
    }
    
    func postCheckOut(student: Student, subjectDelivery: SubjectDelivery) {
        
        let endpoint = "\(endpointDomain)\(endpointCheckOut)"
        
        let params: [String : AnyObject] = [
            "StudentId": student.studentId,
            "TimetableItemId": subjectDelivery.itemId
        ]
        
        Alamofire.request(.POST, endpoint, parameters: params, encoding: .JSON)
            .validate()
            .responseData { response in
                
                var error = response.result.error?.localizedDescription
                if error != nil {
                    if let data = response.data {
                        error = String(data: data, encoding: NSUTF8StringEncoding)
                    }
                }
                
                var result: JSON?
                if let value = response.result.value {
                    result = JSON(data: value)
                }
                
                if let delegate = self.delegate {
                    delegate.apiServiceResponse(.POSTCheckOut, error: error, json: result)
                }
                
            }
        
    }
    
}