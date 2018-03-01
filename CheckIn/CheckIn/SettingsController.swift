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
        
        let alert=UIAlertController(title: "Data Upload", message: "You are about to upload the check-in data on this device into the database. Are you sure you want to continue?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: {(alertAction : UIAlertAction) in
            self.pushData()
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(alert, animated: true)
    }
    
    //Action on Load Data button
    @IBAction func pull(_ sender: UIButton) {
    
        let alert=UIAlertController(title: "Data Import", message: "You are about to import student data on this device from the database. Are you sure you want to continue?", preferredStyle: .alert)
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
        } catch _ as NSError {
            print ("Could not fetch data")
        }
        count.text = String(students.count)
    }
    
    
    //Function to push CheckIn data to Firebase
    func pushData()
    {
        let databaseRef = Database.database().reference(withPath: "CheckIn")
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "CheckedInStudent")
        
        do {
            let localData = try managedContext.fetch(fetchRequest)
            
            for data in localData
            {
                let post : [String: AnyObject] = ["id" : data.value(forKey: "id") as AnyObject, "media" : data.value(forKey: "media") as AnyObject, "guests" : data.value(forKey: "guests") as AnyObject]
                let locationRef = databaseRef.childByAutoId()
                locationRef.setValue(post)
            }
            
            let alert = UIAlertController(title: "Data Uploaded", message: "Check-in data successfully uploaded.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true)
            
        } catch _ as NSError {
            print ("Could not fetch data")
        }
    }
    
    
    
    //Function to get data after clearing current data
    func getData()
    {
        self.clearData()
        self.pullData()
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
        
        
        
        let ref=Database.database().reference(withPath: "students")
            
        ref.observe(.value, with: { snapshot in
            for data in snapshot.children {
                let student = NSManagedObject(entity: entity!, insertInto: managedContext)
                
                let studentData = data as! DataSnapshot
                var fields = studentData.value as? [String:AnyObject]
                let fname=fields!["fname"] as! String
                let lname=fields!["lname"] as! String
                let media=fields!["media"] as! String
                let id=fields!["id"] as! String
                let school=fields!["school"] as! String
                
                
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
        
        
        //Get event name
        let eventEntity = NSEntityDescription.entity(forEntityName: "Event", in: managedContext)
        let eventRef=Database.database().reference(withPath: "Event")
        eventRef.observe(.value, with: { snapshot in
            for data in snapshot.children {
                let event=NSManagedObject(entity: eventEntity!, insertInto: managedContext)
                let eventName=(data as! DataSnapshot).value as! String
                event.setValue(eventName, forKey: "name")
                try! managedContext.save()
            }
        })
        
        
        
        
        let alert = UIAlertController(title: "Data Imported", message: "Student data successfully imported.", preferredStyle: .alert)
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
        //Clear Student data
        let managedContext = appDelegate.persistentContainer.viewContext
        var ReqVar = NSFetchRequest<NSFetchRequestResult>(entityName: "Student")
        var DelAllReqVar = NSBatchDeleteRequest(fetchRequest: ReqVar)
        do { try managedContext.execute(DelAllReqVar) }
        catch { print("Error when clearing data"+error.localizedDescription) }
        
        //Clear CheckIn data
        ReqVar = NSFetchRequest<NSFetchRequestResult>(entityName: "CheckedInStudent")
        DelAllReqVar = NSBatchDeleteRequest(fetchRequest: ReqVar)
        do { try managedContext.execute(DelAllReqVar) }
        catch { print("Error when clearing data"+error.localizedDescription) }

        
        //Create custom directory
        let fileManager = FileManager.default
        //Create direcotry path
        let path = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString).appendingPathComponent("customDirectory")
        //Check if directory exists at that path
        if !fileManager.fileExists(atPath: path){
            print("Creating new directory")
            try! fileManager.createDirectory(atPath: path, withIntermediateDirectories: true, attributes: nil)
        }else{
            print("Directory already exists.")
        }
        
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
        } catch _ as NSError {
            print ("Could not fetch image data")
        }
        
        for record in students{
            let id=record.value(forKey: "studentId") as! String
            print(id)
        
            let storageRef = Storage.storage().reference().child(id+".jpg")
        
            storageRef.getData(maxSize: 1 * 1024 * 1024) { data, error in
                if let error = error {
                    print(error.localizedDescription)
                    self.saveImageDocumentDirectory(data: UIImageJPEGRepresentation(UIImage(named:"default")!,1)! as NSData, id: id)
                    print("Set default image for "+id)
                } else {
                    self.saveImageDocumentDirectory(data: data! as NSData, id: id)
                }
            }
            
            do{
                try managedContext.save()
            }
            catch let error as NSError{
                print("Error when pulling new image data"+error.localizedDescription)
            }
        }
        
        let alert = UIAlertController(title: "Images Imported", message: "Student images successfully imported.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true)
        
    }
    
    
    //Function to save image to custom directory
    func saveImageDocumentDirectory(data : NSData, id: String){
        let fileManager = FileManager.default
        let directoryPath = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString).appendingPathComponent("customDirectory")
        let imageName=id+".jpg"
        let path=(NSURL(string: directoryPath)!.appendingPathComponent(imageName))?.path
        let image = UIImage(data: data as Data)
        print(path!)
        let imageData = UIImageJPEGRepresentation(image!, 0.5)
        fileManager.createFile(atPath: path! as String, contents: imageData, attributes: nil)
    }


}


