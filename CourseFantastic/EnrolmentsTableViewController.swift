//
//  EnrolmentsTableViewController.swift
//  CourseFantastic
//
//  Created by Lee Kelly on 22/04/2016.
//  Copyright © 2016 LMK Technologies. All rights reserved.
//

import UIKit
import CoreData
import SwiftyJSON

class EnrolmentsTableViewController: UITableViewController, NSFetchedResultsControllerDelegate, APIServiceDelegate {
    
    var courses: [Course] = []
    var fetchedResultsController: NSFetchedResultsController!
    var courseDeliveryId: Int!
    var enrolmentId: Int!
    var course: Course!
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        // Allow auto resizing of tableview row
        tableView.estimatedRowHeight = 60.0
        tableView.rowHeight = UITableViewAutomaticDimension
        
        // Core Data
        if let managedObjectContext = AppDelegate.instance()?.managedObjectContext {
            
            fetchedResultsController = NSFetchedResultsController(fetchRequest: Course.fetchRequest(), managedObjectContext: managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
            fetchedResultsController.delegate = self
            
            do {
                try fetchedResultsController.performFetch()
                courses = fetchedResultsController.fetchedObjects as! [Course]
            } catch {
                print(error)
            }
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return courses.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! EnrolmentsTableViewCell
        
        let course = courses[indexPath.row]
        
        // Configure the cell...
        cell.colourView.backgroundColor = UIColor(red: 0, green: 128.0/255.0, blue: 1, alpha: 1.0)   // TODO: Implement Colour Handler
        cell.courseLabel.text = course.name
        
        return cell
    }

    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    
    override func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        
        // Delete Button
        let deleteAction = UITableViewRowAction(style: .Destructive, title: "Withdraw", handler: { (action, indexPath) -> Void in
            
            // Attempt withdraw from course
            self.course = self.fetchedResultsController.objectAtIndexPath(indexPath) as! Course
            self.attemptWithdraw(self.course)
            
        })
        
//        deleteAction.backgroundColor = UIColor(red: 202.0/255.0, green: 202.0/255.0, blue: 203.0/255.0, alpha: 1.0)
        
        return [deleteAction]
    }

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */
    
    // MARK: - Fetched Results Controller
    
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        tableView.beginUpdates()
    }
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        
        switch type {
        case .Insert:
            if let _newIndexPath = newIndexPath {
                tableView.insertRowsAtIndexPaths([_newIndexPath], withRowAnimation: .Fade)
            }
        case .Delete:
            if let _indexPath = indexPath {
                tableView.deleteRowsAtIndexPaths([_indexPath], withRowAnimation: .Fade)
            }
        case .Update:
            if let _indexPath = indexPath {
                tableView.reloadRowsAtIndexPaths([_indexPath], withRowAnimation: .Fade)
            }
            
        default:
            tableView.reloadData()
        }
        
        // Sync our array with the fetchedResultsController
        courses = controller.fetchedObjects as! [Course]
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        tableView.endUpdates()
    }
    
    // MARK: - Barcode
    
    func barcodeCaptured(barcode: String) {
        
        print("barcodeCaptured: \(barcode)")
        
        courseDeliveryId = Int(barcode)
        
        do {
            if let student = try StudentService.getStudent() {
                
                ActivityIndicator().show()
                
                let apiService = APIService()
                apiService.delegate = self
                apiService.postEnrolmentEnrol(student, courseDeliveryId: courseDeliveryId)
                
            }
            
        } catch {
            displayAlert("Oops!", message: "We couldn't load your profile.")
        }
        
    }
    
    // MARK: - APIService Calls
    
    func fetchCourse() {
        
        ActivityIndicator().show()
        
        let apiService = APIService()
        apiService.delegate = self
        apiService.getCourse(courseDeliveryId)
        
    }
    
    func fetchTimetable() {
        
        ActivityIndicator().show()
        
        let apiService = APIService()
        apiService.delegate = self
        apiService.getTimetable(forCourseId: courseDeliveryId)
        
    }
    
    func attemptWithdraw(course: Course) {
        
        do {
            if let student = try StudentService.getStudent() {
                
                ActivityIndicator().show()
                
                let apiService = APIService()
                apiService.delegate = self
                apiService.postEnrolmentWithdraw(student, enrolmentId: course.enrolmentId.integerValue)
            }
            
        } catch {
            displayAlert("Oops!", message: "We couldn't load your profile.")
        }
        
    }
    
    // MARK: - APIService Delegate
    
    func apiServiceResponse(responseType: APIServiceResponseType, error: String?, json: JSON?) {
        
        ActivityIndicator().hide()
        
        if let error = error {
            displayAlert("Oops!", message: error)
            return
        }
        
        if let json = json {
            
            switch responseType {
            case .POSTEnrol:
                handlePostEnrol(json)
                
            case .GETCourse:
                handleGetCourse(json)
                
            case .GETTimetable:
                handleGetTimetable(json)
                
            case .POSTWithdraw:
                handlePostWithdraw()
                
            default:
                print(json.description)
            }
        }
        
    }
    
    // MARK: - Handle Enrolment
    
    func handlePostEnrol(json: JSON) {
        
        /*
        {
            "CourseDeliveryId" : 4,
            "EnrolmentId" : 22,
            "StudentId" : "12345"
        }
        */
        
        guard let id = json["EnrolmentId"].int else {
            displayAlert("Oops!", message: "We couldn't process the information received.")
            return
        }
        
        enrolmentId = id
        
        fetchCourse()
    }
    
    func handlePostWithdraw() {
        
        do {
            try CourseService.removeCourse(course)
            
        } catch let error as NSError {
            displayAlert("Oops!", message: error.localizedDescription)
        }
        
    }
    
    // MARK: - Handle Course
    
    func handleGetCourse(json: JSON) {
        
        do {
            let course = try CourseService.createCourse(json)
            
            course.enrolmentId = enrolmentId
            course.id = courseDeliveryId    // TODO: change API to include id
            
            self.course = course
            
//            try managedObjectContext.save()
            
            fetchTimetable()
            
        } catch let error as NSError {
            displayAlert("Oops!", message: error.localizedDescription)
        }
    }
    
    // MARK: - Handle Timetable
    
    func handleGetTimetable(json: JSON) {
        
        /*
         [
             {
                 "Version" : "1",
                 "Subjects" : [
                     {
                         "Subject" : {
                         "Code" : "SAD",
                         "Name" : "Advanced System Analysis & Design",
                         "Description" : "Learn advanced concepts in Analysis & Design. Software architecture fundamentals and contemporary software development methodologies delivered in the context of your major project."
                         },
                         "Timetable" : [
                             {
                             "Start" : "2016-05-23T13:00:00",
                             "Location" : "GG.27",
                             "End" : "2016-05-23T17:00:00",
                             "Id" : 325
                             },
                             {
                             "Start" : "2016-05-30T13:00:00",
                             "Location" : "GG.27",
                             "End" : "2016-05-30T17:00:00",
                             "Id" : 326
                             }
                         ]
                     },
                     {
                         "Subject" : {
                         "Code" : "SD",
                         "Name" : "Software Development",
                         "Description" : "Learn advanced concepts in Software Development, working on a real world project using the latest technologies."
                         },
                         "Timetable" : [
                             {
                             "Start" : "2016-05-19T09:00:00",
                             "Location" : "GG.28",
                             "End" : "2016-05-19T13:00:00",
                             "Id" : 340
                             },
                             {
                             "Start" : "2016-05-19T14:00:00",
                             "Location" : "GG.28",
                             "End" : "2016-05-19T18:00:00",
                             "Id" : 356
                             }
                         ]
                     }
                 ]
             }
         ]
        */
        
        guard let subjects = json[0]["Subjects"].array else {
            displayAlert("Oops!", message: "We couldn't process the information received.")
            return
        }
        
        do {
            
            for item in subjects {
                
                let subject = try SubjectService.createSubject(item)
                
                guard let events = item["Timetable"].array else {
                    displayAlert("Oops!", message: "We couldn't process the information received.")
                    return
                }
                
                for event in events {
                    
                    let subjectDelivery = try SubjectDeliveryService.createSubjectDelivery(event)
                    subject.addTimetableItem(subjectDelivery)
                    
                }
                
                course.addSubject(subject)
                
            }
            
            guard let managedObjectContext = (UIApplication.sharedApplication().delegate as? AppDelegate)?.managedObjectContext else {
                throw NSError(domain: "CourseFantastic", code: -99, userInfo: [NSLocalizedDescriptionKey: "We couldn't load the database."])
            }
            
            try managedObjectContext.save()
            
            print("Successfully Saved the Course Structure")
            
            integrateCalendar()
            
        } catch let error as NSError {
            displayAlert("Oops!", message: error.localizedDescription)
        }
        
    }
    
    // MARK: - Calendar Integration
    
    func integrateCalendar() {
        
        let calendarService = CalendarService()
        
        calendarService.attemptAccess({
            
            do {
                
                let calendar = try calendarService.createCalendar() // returns existing calendar if already exists
                
                try calendarService.createEvents(inCalendar: calendar, forCourse: self.course)
                
                guard let managedObjectContext = (UIApplication.sharedApplication().delegate as? AppDelegate)?.managedObjectContext else {
                    throw NSError(domain: "CourseFantastic", code: -99, userInfo: [NSLocalizedDescriptionKey: "We couldn't load the database."])
                }
                
                try managedObjectContext.save()
                
            } catch let error as NSError {
                self.displayAlert("Oops!", message: error.localizedDescription)
            }
            
        })
        
    }

    // MARK: - Error Alert

    func displayAlert(title: String, message: String) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        let okAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
        alert.addAction(okAction)
        self.presentViewController(alert, animated: true, completion: nil)
        
    }

    // MARK: - Navigation
    /*
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        if let identifier = segue.identifier {
            if identifier == "scanBarcode" {
                // Get the new view controller using segue.destinationViewController
                let vc = segue.destinationViewController as! BarcodeViewController
                vc.delegate = self
            }
        }
        
    }
    */
    
    @IBAction func unwindToEnrolments(segue: UIStoryboardSegue) {
        
        if let vc = segue.sourceViewController as? BarcodeViewController {
            if let barcode = vc.scannedBarcode {
                barcodeCaptured(barcode)
            }
        }
        
    }

}
