//
//  StudentDetailsViewController.swift
//  CheckIn
//
//  Created by Anand Kelkar on 15/02/18.
//  Copyright © 2018 Sam Walk. All rights reserved.
//

import UIKit
import CoreData
import os.log

class StudentDetailsViewController: UIViewController {

    @IBOutlet weak var studentFirstName: UILabel!
    @IBOutlet weak var studentLastName: UILabel!
    @IBOutlet weak var studentId: UILabel!
    @IBOutlet weak var school: UILabel!
    
    @IBOutlet weak var numGuestsTextField: UITextField!
    @IBOutlet weak var checkInButton: UIButton!
    
    @IBOutlet weak var backButton: UIBarButtonItem!
    
    
    var student = NSManagedObject()
    var numGuestsInt: Int16 = 0
    var studentIdString: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        studentFirstName.text = student.value(forKey: "firstName") as? String
        studentLastName.text = student.value(forKey: "firstName") as? String
        studentId.text = student.value(forKey: "firstName") as? String
        school.text = student.value(forKey: "firstName") as? String
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        guard let button = sender as? UIBarButtonItem, button === backButton else {
            guard let button = sender as? UIButton, button === checkInButton else {
                    return
            }
            numGuestsInt = Int16(numGuestsTextField.text!)!
            studentIdString = studentId.text!
            
            return
        }
    }
    
    func setStudent(student: NSManagedObject){
        self.student = student
    }

}
