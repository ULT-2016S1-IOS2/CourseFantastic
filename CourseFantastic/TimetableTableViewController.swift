//
//  TimetableTableViewController.swift
//  CourseFantastic
//
//  Created by Lee Kelly on 19/04/2016.
//  Copyright © 2016 LMK Technologies. All rights reserved.
//

import UIKit
import CoreData
import SwiftyJSON
import CoreLocation
import CoreBluetooth

enum CheckType {
    case In
    case Out
}

class TimetableTableViewController: UITableViewController, NSFetchedResultsControllerDelegate, APIServiceDelegate, CLLocationManagerDelegate, CBPeripheralManagerDelegate {
    
    var subjectDeliveries: [SubjectDelivery] = []
    var fetchedResultsController: NSFetchedResultsController!
    var subjectDelivery: SubjectDelivery!
    var student: Student!
    
    var locationManager: CLLocationManager!
    var beaconRegion: CLBeaconRegion!
    var lastFoundBeacon: CLBeacon! = CLBeacon()
    var lastProximity: CLProximity! = CLProximity.Unknown
    
    var bluetoothManager = CBPeripheralManager()
    var btOn = false
    var canRange = false
    var isRanging = false
    var attemptingAttendanceCheckType = CheckType.In
    var hasAttemptedAttendanceCheck = false
    var attemptedRanges = 0
    

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
        if let managedObjectContext = (UIApplication.sharedApplication().delegate as? AppDelegate)?.managedObjectContext {
            
            fetchedResultsController = NSFetchedResultsController(fetchRequest: SubjectDelivery.fetchRequest(), managedObjectContext: managedObjectContext, sectionNameKeyPath: "dateOnly", cacheName: nil)
            fetchedResultsController.delegate = self
            
            do {
                try fetchedResultsController.performFetch()
                subjectDeliveries = fetchedResultsController.fetchedObjects as! [SubjectDelivery]
                
            } catch {
                print(error)
            }
        }
        
        // Location Manager
        locationManager = CLLocationManager()
        locationManager.delegate = self

        let uuid = NSUUID(UUIDString: "B0702880-A295-A8AB-F734-031A98A512DE")!
        beaconRegion = CLBeaconRegion(proximityUUID: uuid, identifier: "GG.21")

//        beaconRegion.notifyOnEntry = true
//        beaconRegion.notifyOnExit = true

//        locationManager.requestWhenInUseAuthorization()
        
//        locationManager.startMonitoringForRegion(beaconRegion)
//        locationManager.startUpdatingLocation()
        
        // Bluetooth Manager
        bluetoothManager.delegate = self
        
        // Refresh Control
        refreshControl = UIRefreshControl()
//        refreshControl?.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl?.addTarget(self, action: #selector(refresh), forControlEvents: .ValueChanged)
//        tableView.addSubview(refreshControl!)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
//    override func viewDidAppear(animated: Bool) {
//        ActivityIndicator().show()
//    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return fetchedResultsController.sections!.count
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sections = fetchedResultsController.sections! as [NSFetchedResultsSectionInfo]
        let sectionInfo = sections[section]
        return sectionInfo.numberOfObjects
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let sections = fetchedResultsController.sections!
        let sectionInfo = sections[section]
        return sectionInfo.name.toDateString()
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! TimetableTableViewCell
        
        let subjectDelivery = fetchedResultsController.objectAtIndexPath(indexPath) as! SubjectDelivery
        
        // Configure the cell...
        cell.startTimeLabel.text = subjectDelivery.startDate.timeFormat()
        cell.endTimeLabel.text = subjectDelivery.endDate.timeFormat()
        cell.subjectLabel.text = subjectDelivery.subject.name
        cell.locationLabel.text = subjectDelivery.location
        
        // Colour the time labels
        cell.startTimeLabel.textColor = UIColor.grayColor()
        cell.endTimeLabel.textColor = UIColor.grayColor()
        let now = NSDate()
        if subjectDelivery.startDate.isGreaterThanDate(now) {
            cell.startTimeLabel.textColor = UIColor.blackColor()
        } else {
            if subjectDelivery.endDate.isGreaterThanDate(now) {
                cell.endTimeLabel.textColor = UIColor.blackColor()
            }
        }

        return cell
    }

    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    
    override func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        
        subjectDelivery = fetchedResultsController.objectAtIndexPath(indexPath) as! SubjectDelivery
        
        // Check In/Out Button
        var checkedOut = false
        var checkedIn = false
        var title = "\u{2691}\n Check In"
        if let attendance = subjectDelivery.attendance {
            checkedOut = attendance.complete.boolValue
            if !checkedOut {
                checkedIn = true
                title = "\u{2690}\n Check Out"
            }
        }
        let attendanceAction = UITableViewRowAction(style: .Default, title: title, handler: { (action, indexPath) -> Void in
            self.tableView.setEditing(false, animated: true)    // Close the editActions
            
            checkedIn ? (self.attemptingAttendanceCheckType = .Out) : (self.attemptingAttendanceCheckType = .In)
            self.attemptAttendanceCheck()
        })
        
        // Edit Button
        let editAction = UITableViewRowAction(style: .Default, title: "\u{270E}\n Edit", handler: { (action, indexPath) -> Void in
            self.tableView.setEditing(false, animated: true)    // Close the editActions
            self.performSegueWithIdentifier("showEditEvent", sender: indexPath)
        })
        
        // Doctor Button
        let doctorAction = UITableViewRowAction(style: .Default, title: "\u{2624}\n Doc Cert", handler: { (action, indexPath) -> Void in
            self.tableView.setEditing(false, animated: true)    // Close the editActions
        })
        
        attendanceAction.backgroundColor = checkedIn ? UIColor(red: 230.0/255.0, green: 0, blue: 0, alpha: 1.0) : UIColor(red: 0, green: 230.0/255.0, blue: 0, alpha: 1.0)
        editAction.backgroundColor = UIColor(red: 255.0/255.0, green: 166.0/255.0, blue: 2.0/255.0, alpha: 1.0)
        doctorAction.backgroundColor = UIColor(red: 28.0/255.0, green: 165.0/255.0, blue: 253.0/255.0, alpha: 1.0)
        
        
        if checkedOut {
            return [doctorAction, editAction]
        }
        return [doctorAction, editAction, attendanceAction]
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
    
    func controller(controller: NSFetchedResultsController, didChangeSection sectionInfo: NSFetchedResultsSectionInfo, atIndex sectionIndex: Int, forChangeType type: NSFetchedResultsChangeType) {
        
        switch type {
        case .Insert:
            tableView.insertSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Fade)
        case .Delete:
            tableView.deleteSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Fade)
        default:
            tableView.reloadData()
        }
        
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
        subjectDeliveries = controller.fetchedObjects as! [SubjectDelivery]
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        tableView.endUpdates()
    }
    
    // MARK: - Refresh Control
    
    func refresh(sender: AnyObject) {
        
        // TODO: Move below to a seperate method, to be called upon an API response
        
        self.tableView?.reloadData()
        
        refreshControl?.attributedTitle = NSAttributedString(string: "Last updated \(NSDate().format("h:mm:ss a"))")
        
        // tell refresh control it can stop showing up now
        if refreshControl!.refreshing
        {
            refreshControl!.endRefreshing()
        }
        
    }
    
    // MARK: - APIService Calls
    
    func attemptAttendanceCheck() {
        
        guard btOn else {
            displayAlert("Oops!", message: "Please turn Bluetooth on.")
            return
        }
        
        guard canRange else {
            displayAlert("Oops!", message: "Please authorise location services.")
            return
        }
        
        attemptedRanges = 0
        hasAttemptedAttendanceCheck = false
        
        ActivityIndicator().show()
        
        startRanging()
    }
    
    func attendanceCheck(subjectDelivery: SubjectDelivery) {
        
        do {
            if !hasAttemptedAttendanceCheck {
                if let student = try StudentService.getStudent() {
                    self.student = student
                    
                    let apiService = APIService()
                    apiService.delegate = self
                    
                    if attemptingAttendanceCheckType == .In {
                        apiService.postCheckIn(student, subjectDelivery: subjectDelivery)
                    } else {
                        apiService.postCheckOut(student, subjectDelivery: subjectDelivery)
                    }
                    hasAttemptedAttendanceCheck = true
                    
                }
            }
            
        } catch let error as NSError {
            displayAlert("Oops!", message: error.localizedDescription)
        }
        
    }
    
    func getTimetableVersion() {
        
        do {
            if let student = try StudentService.getStudent() {
                self.student = student
                
                ActivityIndicator().show()
                
                let apiService = APIService()
                apiService.delegate = self
                apiService.getTimetableVersion(forStudentId: student.studentId)
            }
            
        } catch let error as NSError {
            displayAlert("Oops!", message: error.localizedDescription)
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
            case .POSTCheckIn:
                handlePostCheckIn()
                
            case .POSTCheckOut:
                handlePostCheckOut()
                
            case .GETTimetableVersion:
                handleGetTimetableVersion(json)
                
            default:
                print(json.description)
            }
        }
        
    }
    
    // MARK: - Handle Attendance
    
    func handlePostCheckIn() {
        
        do {
            try AttendanceService.checkIn(subjectDelivery)
            
            displayAlert("Thank you", message: "You have checked in.")
            
        } catch let error as NSError {
            displayAlert("Oops!", message: error.localizedDescription)
        }
        
    }
    
    func handlePostCheckOut() {
        
        do {
            try AttendanceService.checkOut(subjectDelivery)
            
            displayAlert("Thank you", message: "You have checked out.")
            
        } catch let error as NSError {
            displayAlert("Oops!", message: error.localizedDescription)
        }
        
    }
    
    func handleGetTimetableVersion(json: JSON) {
        
//        guard let id = json["CourseDeliveryId"].int else {
//            return
//        }
//        
//        guard let version = json["Version"].string else {
//            return
//        }
//        
//        TODO: Write a service to handle checking of CourseDeliveryId and Versions
        
    }
    
    // MARK: - Error Alert
    
    func displayAlert(title: String, message: String) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        let okAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
        alert.addAction(okAction)
        self.presentViewController(alert, animated: true, completion: nil)
        
    }
    
    // MARK: - Bluetooth Manager
    
    func peripheralManagerDidUpdateState(peripheral: CBPeripheralManager) {
        if peripheral.state == .PoweredOff {
            btOn = false
        } else if peripheral.state == .PoweredOn {
            btOn = true
        }
    }
    
    // MARK: - Location Manager Delegate
    
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        switch status {
        case .NotDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .AuthorizedWhenInUse, .AuthorizedAlways:
            canRange = true
        case .Denied, .Restricted:
            canRange = false
            NSNotificationCenter.defaultCenter().postNotificationName("LOCATION_DENIED", object: nil)
        }
    }
    
    func startRanging() {
        if !isRanging {
            locationManager.startRangingBeaconsInRegion(beaconRegion)
            isRanging = true
        }
    }
    
    func stopRanging() {
        if isRanging {
            locationManager.stopRangingBeaconsInRegion(beaconRegion)
            isRanging = false
        }
    }
    
    func locationManager(manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], inRegion region: CLBeaconRegion) {
        
        if isRanging {
            attemptedRanges += 1
            if beacons.count > 0 {
                let closestBeacon = beacons[0]
                if closestBeacon != lastFoundBeacon || lastProximity != closestBeacon.proximity  {
                    lastFoundBeacon = closestBeacon
                    lastProximity = closestBeacon.proximity
                    
                    switch lastFoundBeacon.proximity {
                    case .Immediate, .Near, .Far:
                        print("In Range")
                        stopRanging()
                        attendanceCheck(subjectDelivery)
                        
                    default:
                        print("Not in Range")
                    }
                }
            }
            
            if attemptedRanges > 10 {
                print("Giving up")
                stopRanging()
                ActivityIndicator().hide()
                displayAlert("Oops!", message: "Not in range.")
            }
        }
        
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print(error)
    }
    
    func locationManager(manager: CLLocationManager, monitoringDidFailForRegion region: CLRegion?, withError error: NSError) {
        print(error)
    }
    
    func locationManager(manager: CLLocationManager, rangingBeaconsDidFailForRegion region: CLBeaconRegion, withError error: NSError) {
        print(error)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
