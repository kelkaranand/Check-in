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
    @IBOutlet weak var PushDataView: UIView!
    @IBOutlet weak var PullDataView: UIView!
    @IBOutlet weak var PushDataHeader: UILabel!
    @IBOutlet weak var PushDataMessage: UILabel!
    @IBOutlet weak var PullDataHeader: UILabel!
    @IBOutlet weak var PullDataMessage: UILabel!
    
    
    @objc func pushAction(_ : UITapGestureRecognizer){
        let alert=UIAlertController(title: "Data Upload", message: "You are about to upload the check-in data on this device into the database. Are you sure you want to continue?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: {(alertAction : UIAlertAction) in
            self.pushData()
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(alert, animated: true)
    }

   @objc func pullAction(_ : UITapGestureRecognizer)
    {
        let alert=UIAlertController(title: "Data Import", message: "You are about to import student data on this device from the database. Are you sure you want to continue?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: {(alertAction : UIAlertAction) in
            self.getData()
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(alert, animated: true)
        updateTable()
    }
    
    func updateTable()
    {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "reload"), object: nil)
    }
    
    override func viewDidLayoutSubviews() {
        PushDataView.layer.borderColor=UIColor.black.cgColor
        PushDataView.layer.borderWidth=5
        PushDataView.layer.backgroundColor=UIColor.white.cgColor
        PushDataView.layer.shouldRasterize = false
        PushDataView.layer.cornerRadius = 10
        
        PushDataHeader.text="Push Data"
        PushDataHeader.font = UIFont(name: "HelveticaNeue-Bold", size: 600)
        PushDataHeader.numberOfLines = 0
        PushDataHeader.minimumScaleFactor = 0.1
        PushDataHeader.baselineAdjustment = .alignCenters
        PushDataHeader.textAlignment  = .center
        PushDataHeader.adjustsFontSizeToFitWidth=true
        PushDataHeader.textColor = UIColor(red:253,green:201,blue:16)

        PushDataMessage.text="Push check-in data to cloud storage."
        PushDataMessage.font = UIFont(name: "HelveticaNeue", size: 200)
        PushDataMessage.numberOfLines = 0
        PushDataMessage.minimumScaleFactor = 0.1
        PushDataMessage.baselineAdjustment = .alignCenters
        PushDataMessage.textAlignment  = .center
        PushDataMessage.adjustsFontSizeToFitWidth=true
        PushDataMessage.textColor = UIColor(red:253,green:201,blue:16)
        
        
        
        PullDataView.layer.borderColor=UIColor.black.cgColor
        PullDataView.layer.borderWidth=5
        PullDataView.layer.backgroundColor=UIColor.white.cgColor
        PullDataView.layer.shouldRasterize = false
        PullDataView.layer.cornerRadius = 10
        
        PullDataHeader.text="Pull Data"
        PullDataHeader.font = UIFont(name: "HelveticaNeue-Bold", size: 600)
        PullDataHeader.numberOfLines = 0
        PullDataHeader.minimumScaleFactor = 0.1
        PullDataHeader.baselineAdjustment = .alignCenters
        PullDataHeader.textAlignment  = .center
        PullDataHeader.adjustsFontSizeToFitWidth=true
        PullDataHeader.textColor = UIColor(red:253,green:201,blue:16)
        
        PullDataMessage.text="Pull event data from cloud storage."
        PullDataMessage.font = UIFont(name: "HelveticaNeue", size: 200)
        PullDataMessage.numberOfLines = 0
        PullDataMessage.minimumScaleFactor = 0.1
        PullDataMessage.baselineAdjustment = .alignCenters
        PullDataMessage.textAlignment  = .center
        PullDataMessage.adjustsFontSizeToFitWidth=true
        PullDataMessage.textColor = UIColor(red:253,green:201,blue:16)
        
        
        
        
    }
    
    
    var students: [NSManagedObject] = []
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        
        self.navigationController?.navigationBar.barTintColor=UIColor(red:2,green:86,blue:0)
        self.navigationController?.navigationBar.tintColor = UIColor(red:253,green:201,blue:16)
        
        let pushClick = UITapGestureRecognizer(target:self, action:#selector(pushAction(_ :)))
        
        let pullClick = UITapGestureRecognizer(target: self, action:#selector(pullAction(_ :)))
        
        
        self.PushDataView.addGestureRecognizer(pushClick)
        self.PullDataView.addGestureRecognizer(pullClick)
        
        
        
        let alert = UIAlertController(title: "Warning", message: "You are entering the admin page, do you want to continue?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler:
            {
                (alertAction: UIAlertAction) in
                if (!InternetConnectionTest.isInternetAvailable())
                {
                    let internetAlert = UIAlertController(title: "No internet connection.", message: "The device is not connected to the internet at the moment. Admin functions cannot be performed without an internet connection.", preferredStyle: .alert)
                    internetAlert.addAction(UIAlertAction(title: "Go back", style: .cancel, handler:
                    {
                        (alertAction: UIAlertAction) in
                        self.navigationController?.popToRootViewController(animated: true)
                    }))
                    self.present(internetAlert, animated: true)
                }
        }))
        alert.addAction(UIAlertAction(title: "No", style: .cancel, handler:
            {
                (alertAction: UIAlertAction) in
                self.navigationController?.popToRootViewController(animated: true)
        }))
        self.present(alert, animated: true)
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
                let vip=fields!["vip"] as! String


                student.setValue(fname, forKey: "firstName")
                student.setValue(lname, forKey: "lastName")
                student.setValue(media, forKey: "media")
                student.setValue(id, forKey: "studentId")
                student.setValue(school, forKey: "school")
                student.setValue(vip, forKey: "vip")

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
            let event=NSManagedObject(entity: eventEntity!, insertInto: managedContext)
            //Pull Event Name
            let eventName=snapshot.childSnapshot(forPath: "name").value as! String
            event.setValue(eventName, forKey: "name")
            
            try! managedContext.save()  
        })
        
        //Success alert
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
        
        //Clear Event data
        ReqVar = NSFetchRequest<NSFetchRequestResult>(entityName: "Event")
        DelAllReqVar = NSBatchDeleteRequest(fetchRequest: ReqVar)
        do { try managedContext.execute(DelAllReqVar) }
        catch { print("Error when clearing data"+error.localizedDescription) }
        
        managedContext.reset()
    }
    

}


