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

class LandingController2: UIViewController {
    
    
    @IBOutlet weak var LoadDataMessage: UILabel!
    @IBOutlet weak var NumberMessageLabel: UILabel!
    
    @IBOutlet weak var EventNameLabel: UILabel!
    @IBOutlet weak var NumberView: UIView!
    
    @IBOutlet weak var LineView: UIView!
    @IBOutlet weak var NumberLabel: UILabel!
    @IBOutlet weak var EventNameView: UIView!
    
    var EventName:String=""
    
    override func viewDidLayoutSubviews() {
        //Check if data has been loaded by checking if event name is present
        if(EventName=="")
        {
            
            self.view.backgroundColor=UIColor(red:2,green:86,blue:0)
            NumberView.isHidden=true
            EventNameView.isHidden=true
            LoadDataMessage.isHidden=false
            LineView.isHidden=true
            
//            LoadDataMessage.text="Load data from the admin controls to set up the device for the event."
//            LoadDataMessage.font = UIFont(name: "Helvetica", size: 40)
//            LoadDataMessage.numberOfLines = 0
//            LoadDataMessage.minimumScaleFactor = 0.1
//            LoadDataMessage.baselineAdjustment = .alignCenters
//            LoadDataMessage.textAlignment  = .center
//            LoadDataMessage.adjustsFontSizeToFitWidth=true
//            LoadDataMessage.textColor = UIColor(red:253,green:201,blue:16)
            
        }
        else{
            
            
            self.view.backgroundColor=UIColor.white
            LoadDataMessage.isHidden=true
            NumberView.isHidden=false
            EventNameView.isHidden=false
            LineView.isHidden=false
            LineView.backgroundColor=UIColor(red:3,green:129,blue:0)
            
//            EventNameView.layer.borderColor=UIColor.black.cgColor
//            EventNameView.layer.borderWidth=1
//            EventNameView.layer.shadowColor = UIColor.black.cgColor
//            EventNameView.layer.backgroundColor=UIColor.white.cgColor
//            EventNameView.layer.shadowOpacity = 1
//            EventNameView.layer.shadowOffset = CGSize.zero
//            EventNameView.layer.shadowRadius = 10
//            EventNameView.layer.shadowPath = UIBezierPath(rect: EventNameView.bounds).cgPath
//            EventNameView.layer.shouldRasterize = false
//            EventNameView.layer.cornerRadius = 10
            
            
//            EventNameLabel.text=EventName
//            EventNameLabel.font = UIFont(name: "Helvetica", size: 60)
//            EventNameLabel.numberOfLines = 0
//            EventNameLabel.minimumScaleFactor = 0.1
//            EventNameLabel.baselineAdjustment = .alignCenters
//            EventNameLabel.textAlignment  = .center
//            EventNameLabel.adjustsFontSizeToFitWidth=true
//            EventNameLabel.textColor = UIColor(red:253,green:201,blue:16)
            
//            NumberView.layer.borderColor=UIColor.black.cgColor
//            NumberView.layer.borderWidth=1
//            NumberView.layer.shadowColor = UIColor.black.cgColor
//            NumberView.layer.backgroundColor=UIColor.white.cgColor
//            NumberView.layer.shadowOpacity = 1
//            NumberView.layer.shadowOffset = CGSize.zero
//            NumberView.layer.shadowRadius = 10
//            NumberView.layer.shadowPath = UIBezierPath(rect: NumberView.bounds).cgPath
//            NumberView.layer.shouldRasterize = false
//            NumberView.layer.cornerRadius = 10
            
            
//            NumberMessageLabel.text="Number of students checked in on this device:"
//            NumberMessageLabel.font = UIFont(name: "Helvetica", size: 60)
//            NumberMessageLabel.numberOfLines = 0
//            NumberMessageLabel.minimumScaleFactor = 0.1
//            NumberMessageLabel.baselineAdjustment = .alignCenters
//            NumberMessageLabel.textAlignment  = .center
//            NumberMessageLabel.adjustsFontSizeToFitWidth=true
//            NumberMessageLabel.textColor = UIColor(red:253,green:201,blue:16)
//            
//            //Get number of Checkins on the device
//            //Set default value
//            NumberLabel.text="0"
//            guard let appDelegate = UIApplication.shared.delegate as?AppDelegate else{
//                return
//            }
//            let managedContext = appDelegate.persistentContainer.viewContext
//            let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "CheckedInStudent")
//            do {
//                    NumberLabel.text = (String)(try (managedContext.fetch(fetchRequest)).count)
//            } catch _ as NSError {
//                    print ("Could not fetch data")
//            }
//
//            NumberLabel.font = UIFont(name: "Helvetica", size: 600)
//            NumberLabel.numberOfLines = 0
//            NumberLabel.minimumScaleFactor = 0.1
//            NumberLabel.baselineAdjustment = .alignCenters
//            NumberLabel.textAlignment  = .center
//            NumberLabel.adjustsFontSizeToFitWidth=true
//            NumberLabel.textColor = UIColor(red:253,green:201,blue:16)
            
        }
    }
    
    
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        super .viewWillAppear(animated)
        
        
        checkEventName()
        if(EventName=="")
        {
            //Disable swipe
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "clearSwipeList"), object: nil)
        }
        else{
            //Enable swipe
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "createSwipeList"), object: nil)
        }
        
        
        self.navigationController?.navigationBar.barTintColor=UIColor(red:2,green:86,blue:0)
        self.navigationController?.navigationBar.tintColor = UIColor(red:253,green:201,blue:16)
        
        LoadDataMessage.text="Load data from the admin controls to set up the device for the event."
        LoadDataMessage.font = UIFont(name: "HelveticaNeue-Bold", size: 200)
        LoadDataMessage.numberOfLines = 0
        LoadDataMessage.minimumScaleFactor = 0.1
        LoadDataMessage.baselineAdjustment = .alignCenters
        LoadDataMessage.textAlignment  = .center
        LoadDataMessage.adjustsFontSizeToFitWidth=true
        LoadDataMessage.textColor = UIColor(red:253,green:201,blue:16)
        
        EventNameLabel.text=EventName
        EventNameLabel.font = UIFont(name: "HelveticaNeue-Bold", size: 100)
        EventNameLabel.numberOfLines = 0
        EventNameLabel.minimumScaleFactor = 0.1
        EventNameLabel.baselineAdjustment = .alignCenters
        EventNameLabel.textAlignment  = .center
        EventNameLabel.adjustsFontSizeToFitWidth=true
        EventNameLabel.textColor = UIColor(red:253,green:201,blue:16)
        
        NumberMessageLabel.text="Number of students checked in on this device:"
        NumberMessageLabel.font = UIFont(name: "HelveticaNeue-Bold", size: 100)
        NumberMessageLabel.numberOfLines = 0
        NumberMessageLabel.minimumScaleFactor = 0.1
        NumberMessageLabel.baselineAdjustment = .alignCenters
        NumberMessageLabel.textAlignment  = .center
        NumberMessageLabel.adjustsFontSizeToFitWidth=true
        NumberMessageLabel.textColor = UIColor(red:253,green:201,blue:16)
        
        //Get number of Checkins on the device
        //Set default value
        NumberLabel.text="0"
        guard let appDelegate = UIApplication.shared.delegate as?AppDelegate else{
            return
        }
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "CheckedInStudent")
        do {
            NumberLabel.text = (String)(try (managedContext.fetch(fetchRequest)).count)
        } catch _ as NSError {
            print ("Could not fetch data")
        }
        
        NumberLabel.font = UIFont(name: "HelveticaNeue-Bold", size: 600)
        NumberLabel.numberOfLines = 0
        NumberLabel.minimumScaleFactor = 0.1
        NumberLabel.baselineAdjustment = .alignCenters
        NumberLabel.textAlignment  = .center
        NumberLabel.adjustsFontSizeToFitWidth=true
        NumberLabel.textColor = UIColor(red:253,green:201,blue:16)

        
        
        
        
        
//        
//        if(flag)
//        {
//            //Get number of Checkins on the device
//            fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "CheckedInStudent")
//            do {
//                let CheckInText = "Number of students checked-in on device: "
//                CheckInCountLabel.text = CheckInText + (String)(try (managedContext.fetch(fetchRequest)).count)
//            } catch _ as NSError {
//                print ("Could not fetch data")
//            }
//            
//            //Get number of student records loaded on the device
//            fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Student")
//            do {
//                let StudentDataText = " student records in memory."
//                StudentCountLabel.text = (String)(try (managedContext.fetch(fetchRequest)).count) + StudentDataText
//            } catch _ as NSError {
//                print ("Could not fetch data")
//            }
//            
//        }
        
    }
    
    func checkEventName()
    {
        guard let appDelegate = UIApplication.shared.delegate as?AppDelegate else {
                return
            }
        let managedContext = appDelegate.persistentContainer.viewContext
        //Get event name
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Event")
                do{
                    let temp = try managedContext.fetch(fetchRequest).first?.value(forKey: "name") as? String
                    if(!(temp==nil))
                    {
                        self.EventName=temp!
                    }
                }
                catch _ as NSError {
                    self.EventName = "Load data from the admin controls to set up the device for the event."
                }
    }
    
    
}

