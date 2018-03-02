//
//  LandingViewController.swift
//  CheckIn
//
//  Created by Anand Kelkar on 01/03/18.
//  Copyright © 2018 Sam Walk. All rights reserved.
//

import Foundation
import CoreData
import UIKit
import Firebase

class LandingViewController: UIViewController {
    @IBOutlet weak var EventName: UILabel!
    
    @IBOutlet weak var StudentCountLabel: UILabel!
    
    @IBOutlet weak var CheckInCountLabel: UILabel!
    override func viewWillAppear(_ animated: Bool) {
        super .viewWillAppear(animated)
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        let managedContext = appDelegate.persistentContainer.viewContext
        
        var flag=false;
        
        //Get event name
        var fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Event")
        do{
            EventName.text = try managedContext.fetch(fetchRequest).first?.value(forKey: "name") as! String
            flag=true;
        }
        catch _ as NSError {
            EventName.text = "Load data from the admin controls to set up the device for the event."
        }
        
        if(flag)
        {
            //Get number of Checkins on the device
            fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "CheckedInStudent")
            do {
                let CheckInText = "Number of students checked-in on device: "
                CheckInCountLabel.text = CheckInText + (String)(try (managedContext.fetch(fetchRequest)).count)
            } catch _ as NSError {
                print ("Could not fetch data")
            }
        
            //Get number of student records loaded on the device
            fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Student")
            do {
                let StudentDataText = " student records in memory."
                StudentCountLabel.text = (String)(try (managedContext.fetch(fetchRequest)).count) + StudentDataText
            } catch _ as NSError {
                print ("Could not fetch data")
            }
            
        }
        
    }
    
    
}
