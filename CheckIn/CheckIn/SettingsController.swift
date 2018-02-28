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
    
    //Action on Load Data button
    @IBAction func pull(_ sender: UIButton) {
    
        var alert=UIAlertController(title: "Data Import", message: "You are about to import student data on this device from the database. Are you sure you want to continue?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: {(alertAction : UIAlertAction) in
            self.getData()
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(alert, animated: true)
        
        
    }
    
    @IBAction func imagePull(_ sender: UIButton) {
        self.pullImages()
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
    
    //Function to get data after clearing current data
    func getData()
    {
        self.clearData()
        self.pullData()
        //self.pullImages()
    }
    
    
    //Function to read Student data from Firebase
    func pullData()
    {
        
        //Pull data from database
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        let entity = NSEntityDescription.entity(forEntityName: "Student", in: managedContext)
        
        
        
        var ref=Database.database().reference(withPath: "students")
            
        ref.observe(.value, with: { snapshot in
            for data in snapshot.children {
                let student = NSManagedObject(entity: entity!, insertInto: managedContext)
                
                var studentData = data as! DataSnapshot
                var fields = studentData.value as? [String:AnyObject]
                var fname=fields!["fname"] as! String
                var lname=fields!["lname"] as! String
                var media=fields!["media"] as! String
                var id=fields!["id"] as! String
                var school=fields!["school"] as! String
                
                
                student.setValue(fname, forKey: "firstName")
                student.setValue(lname, forKey: "lastName")
                student.setValue(media, forKey: "media")
                student.setValue(id, forKey: "studentId")
                student.setValue(school, forKey: "school")
                
                do{
                    try managedContext.save()
                }
                catch let error as NSError{
                    print("Error when pulling new data"+error.localizedDescription)
                }
            }
        })
        
        var alert = UIAlertController(title: "Data Imported", message: "Student data successfully imported.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true)
        
        
    }
    
    //Function to clear all local data
    func clearData()
    {
        print("clearing data")
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        let managedContext = appDelegate.persistentContainer.viewContext
        var ReqVar = NSFetchRequest<NSFetchRequestResult>(entityName: "Student")
        var DelAllReqVar = NSBatchDeleteRequest(fetchRequest: ReqVar)
        do { try managedContext.execute(DelAllReqVar) }
        catch { print("Error when clearing data"+error.localizedDescription) }
        
        ReqVar = NSFetchRequest<NSFetchRequestResult>(entityName: "CheckedInStudent")
        DelAllReqVar = NSBatchDeleteRequest(fetchRequest: ReqVar)
        do { try managedContext.execute(DelAllReqVar) }
        catch { print("Error when clearing data"+error.localizedDescription) }
        
        managedContext.reset()
    }
    
    //Experimental code - Firebase storage to retrieve images
    func pullImages()
    {
        
        var students: [NSManagedObject] = []
        
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Student")
            
        do {
            students = try managedContext.fetch(fetchRequest)
            print("Found students in local memory: "+String(students.count))
        } catch let error as NSError {
            print ("Could not fetch data")
        }
        
        for record in students{
            let id=record.value(forKey: "studentId") as! String
            print(id)
            let image=UIImage(named:"default")!
        
            let storageRef = Storage.storage().reference().child(id+".jpg")
        
            storageRef.getData(maxSize: 1 * 1024 * 1024) { data, error in
                if let error = error {
                    print(error.localizedDescription)
                    record.setValue(UIImageJPEGRepresentation(image, 1), forKey: "image")
                    print("Set default image for "+id)
                } else {
                    let storageimage = UIImage(data: data!)!
                    record.setValue(UIImageJPEGRepresentation(storageimage, 1), forKey: "image")
                }
            }
        }
        
        do{
            try managedContext.save()
        }
        catch let error as NSError{
            print("Error when pulling new image data"+error.localizedDescription)
        }
        
    }


}


