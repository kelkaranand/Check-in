//
//  SettingsController.swift
//  CheckIn
//
//  Created by Anand Kelkar on 15/02/18.
//  Copyright © 2018 Sam Walk. All rights reserved.
//

import Foundation
import UIKit
import CoreData
import Firebase

class SettingsController :UIViewController
{
    @IBOutlet weak var count: UILabel!
    
    //Action on Push Data button
    @IBAction func push(_ sender: UIButton) {
        
        var alert=UIAlertController(title: "Data Upload", message: "You are about to upload the check-in data on this device into the database. Are you sure you want to continue?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: {(alertAction : UIAlertAction) in
            self.pushData()
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(alert, animated: true)
    }
    
    var students: [NSManagedObject] = []
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "CheckedInStudent")
        
        do {
            students = try managedContext.fetch(fetchRequest)
        } catch let error as NSError {
            print ("Could not fetch data")
        }
        count.text = String(students.count)
    }
    
    func pullImages()
    {
        let storageRef = Storage.storage().reference()
        
        
    }
    
    //Function to push CheckIn data to Firebase
    func pushData()
    {
        var databaseRef = Database.database().reference(withPath: "CheckIn")
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "CheckedInStudent")
        
        do {
            var localData = try managedContext.fetch(fetchRequest)
            
            for data in localData
            {
                let post : [String: AnyObject] = ["id" : data.value(forKey: "id") as AnyObject, "media" : data.value(forKey: "media") as AnyObject, "guests" : data.value(forKey: "guests") as AnyObject]
                let locationRef = databaseRef.childByAutoId()
                locationRef.setValue(post)
            }
            
            var alert = UIAlertController(title: "Data Uploaded", message: "Check-in data successfully uploaded.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true)
            
        } catch let error as NSError {
            print ("Could not fetch data")
        }
    }
    
}
