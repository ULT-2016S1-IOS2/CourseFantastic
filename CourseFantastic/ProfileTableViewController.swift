//
//  ProfileTableViewController.swift
//  CourseFantastic
//
//  Created by Lee Kelly on 21/04/2016.
//  Copyright © 2016 LMK Technologies. All rights reserved.
//

import UIKit
import CoreData
import SwiftyJSON
import FBSDKLoginKit

class ProfileTableViewController: UITableViewController, UITextFieldDelegate, APIServiceDelegate, FBSDKLoginButtonDelegate {
    
    var student: Student!
    var datePicker = UIDatePicker()
    var newUser = true
    var loggedIn = false

    @IBOutlet var fbLoginButton: FBSDKLoginButton!
    @IBOutlet var fbLoginLabel: UILabel!
    @IBOutlet var firstNameTextField: UITextField!
    @IBOutlet var lastNameTextField: UITextField!
    @IBOutlet var emailTextField: UITextField!
    @IBOutlet var dobTextField: UITextField!
    @IBOutlet var studentIdTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        // Attempt to load existing student
        loadStudent()
        
        // FB Login Button
        fbLoginButton.delegate = self
        fbLoginButton.readPermissions = ["public_profile", "email", "user_birthday"]
        
        // Register TextField Delegates
        firstNameTextField.delegate = self
        lastNameTextField.delegate = self
        emailTextField.delegate = self
        dobTextField.delegate = self
        
        // Configure DatePicker
        datePicker.datePickerMode = .Date
        datePicker.addTarget(self, action: #selector(datePickerValueChanged), forControlEvents: .ValueChanged)
        dobTextField.inputView = datePicker
        dobTextField.inputAccessoryView = getPickerToolBar()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Student
    
    func loadStudent() {
        
        do {
            if let student = try StudentService.getStudent() {
                self.student = student
                newUser = false
                
                studentIdTextField.text = student.studentId
                firstNameTextField.text = student.firstName
                lastNameTextField.text = student.lastName
                emailTextField.text = student.email
                if let dob = student.dob {
                    dobTextField.text = dob.extFormat()
                    datePicker.date = dob
                }
                
            }
        } catch let error as NSError {
            displayAlert("Oops!", message: error.localizedDescription)
        }
        
    }
    
    // MARK: - Table view data source

    /*
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 0
    }
    */

    /*
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 0
    }
    */
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if !newUser && !loggedIn && indexPath.section == 0 && indexPath.row == 0 {
            return 0
        } else {
            return super.tableView(tableView, heightForRowAtIndexPath: indexPath)
        }
    }

    /*
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("reuseIdentifier", forIndexPath: indexPath)

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

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
    
    // MARK: - Facebook Button Delegate
    
    func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!) {
        print(result)
        loggedIn = true
        getFacebookUserDetails()
    }
    
    func getFacebookUserDetails() {
        
        if(FBSDKAccessToken.currentAccessToken() != nil) {
            print(FBSDKAccessToken.currentAccessToken().permissions)
            
            let graphRequest = FBSDKGraphRequest(graphPath: "me", parameters: ["fields" : "first_name, last_name, email, birthday"])
            graphRequest.startWithCompletionHandler({ (connection, result, error) -> Void in
                
                print(result)
                self.firstNameTextField.text = result.valueForKey("first_name") as? String
                self.lastNameTextField.text = result.valueForKey("last_name") as? String
                self.emailTextField.text = result.valueForKey("email") as? String
                
                if let birthday = result.valueForKey("birthday") as? String {
                    if let date = birthday.toDate("MM/dd/yyyy") {
                        self.datePicker.date = date
                        self.dobTextField.text = date.extFormat()
                    }
                }
                
                self.fbLoginLabel.text = "thank you, you can log out now"
                self.newUser = false
            })
        }
    }
    
    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) {
        loggedIn = false
        print("logged out")
        tableView.beginUpdates()
        tableView.endUpdates()
    }
    
    // MARK: - TextField Delegate
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        
        switch textField {
        case firstNameTextField:
            lastNameTextField.becomeFirstResponder()
        case lastNameTextField:
            emailTextField.becomeFirstResponder()
        case emailTextField:
            dobTextField.becomeFirstResponder()
        default:
            textField.resignFirstResponder()
        }
        
        return true
    }
    
    // MARK: - DatePicker
    
    func datePickerValueChanged(sender: UIDatePicker) {
        dobTextField.text = sender.date.extFormat()
    }
    
    func getPickerToolBar() -> UIToolbar {
        
        let toolbar = UIToolbar()
        let doneButton = UIBarButtonItem(title: "Done", style: .Done, target: self, action: #selector(datePickerDone))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil)
        toolbar.translucent = false
        toolbar.sizeToFit()
        toolbar.setItems([spaceButton, doneButton], animated: false)
        toolbar.userInteractionEnabled = true
        
        return toolbar
    }
    
    func datePickerDone() {
        textFieldShouldReturn(dobTextField)
    }
    
    // MARK: - Save
    
    @IBAction func save() {
        
        let activityIndicator = ActivityIndicator()
        activityIndicator.show()
        
        if let managedObjectContext = AppDelegate.instance()?.managedObjectContext {
            
            if student == nil {
                // No existing student loaded, let's create one
                guard let newStudent = NSEntityDescription.insertNewObjectForEntityForName("Student", inManagedObjectContext: managedObjectContext) as? Student else {
                    // Could not create a new student
                    activityIndicator.hide()
                    displayAlert("Oops!", message: "We couldn't save your details.")
                    
                    return
                }
                student = newStudent
            }
            
//            student.studentId = studentIdTextField.text!
            student.firstName = firstNameTextField.text!
            student.lastName = lastNameTextField.text!
            student.dob = datePicker.date
            student.email = emailTextField.text!
            
            // API Request
            let apiService = APIService()
            apiService.delegate = self
            apiService.postStudent(student)
            
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
            print(json.description)
            
            guard let studentId = json["StudentId"].string else {
                displayAlert("Oops!", message: "Couldn't obtain StudentId.")
                return
            }
            
            student.studentId = studentId
            studentIdTextField.text = studentId
            saveStudent()
        }
        
    }
    
    func saveStudent() {
        if let managedObjectContext = AppDelegate.instance()?.managedObjectContext {
            do {
                try managedObjectContext.save()
            } catch {
                displayAlert("Oops!", message: "We couldn't save your details.")
            }
        }
    }
    
    // MARK: - Error Alert
    
    func displayAlert(title: String, message: String) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        let okAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
        alert.addAction(okAction)
        self.presentViewController(alert, animated: true, completion: nil)
        
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
