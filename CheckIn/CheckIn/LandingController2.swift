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
    @IBOutlet weak var FilterView: UIView!
    @IBOutlet weak var FilterLabel: UILabel!
    
    var checkInList : [String] = []
    var vipList : [String] = []
    
    var EventName:String=""
    var checkIns:Int=0
    var guests:Int=0
    var vips:Int=0
    var studentRecords:String="StudentRecords"
    
    var filterStatus:Bool = false
    var filterType:Int = 0
    var FilterString:String = "message"
    
    var easterEggSwitchCount:Int=0
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if let view = segue.destination as? SettingsController
        {
            view.comingFromLanding=true
            view.checkInList=self.checkInList
            view.eventName=self.EventName
            view.guests=self.guests
            view.vipList=self.vipList
            view.studentRecords=self.studentRecords
            view.filterStatus=self.filterStatus
            view.filterType=self.filterType
            view.FilterString=self.FilterString
        }
    }
    
    @objc func eventNameClickAction(_ : UITapGestureRecognizer){
        self.easterEggSwitchCount=self.easterEggSwitchCount+1
        if easterEggSwitchCount==23{
            ColorSettings.switchToColor()
            self.viewWillAppear(true)
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "changeColor"), object: nil)
        }
    }

    
    
    
    override func viewDidLayoutSubviews() {
        //Check if data has been loaded by checking if event name is present
        if(EventName=="")
        {
            
//            self.view.backgroundColor=UIColor(red:2,green:86,blue:0)
            NumberView.isHidden=true
            EventNameView.isHidden=true
            LoadDataMessage.isHidden=false
            LineView.isHidden=true
            FilterView.isHidden=true
            
        }
        else{
            
            
            self.view.backgroundColor=UIColor.white
            LoadDataMessage.isHidden=true
            NumberView.isHidden=false
            EventNameView.isHidden=false
            LineView.isHidden=false
            
//            addBorderToView(view: NumberView)
            
        }
    }
    
    
    func addBorderToView(view:UIView)
    {
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 1
        view.layer.shadowOffset = CGSize.zero
        view.layer.shadowRadius = 10
        view.layer.shadowPath = UIBezierPath(rect: view.bounds).cgPath
        
        view.layer.borderColor=UIColor.black.cgColor
        view.layer.borderWidth=1
        view.layer.backgroundColor=UIColor.white.cgColor
        view.layer.shouldRasterize = false
        view.layer.cornerRadius = 10
    }
    
    func formatHeaders(label:UILabel, text:String)
    {
        label.text=text
        label.font = UIFont(name: "HelveticaNeue-Bold", size: 100)
        label.numberOfLines = 0
        label.minimumScaleFactor = 0.1
        label.baselineAdjustment = .alignCenters
        label.textAlignment  = .center
        label.adjustsFontSizeToFitWidth=true
        label.textColor = ColorSettings.textColor
    }
    
    func formatNumbers(label:UILabel)
    {
        label.font = UIFont(name: "HelveticaNeue-Bold", size: 600)
        label.numberOfLines = 0
        label.minimumScaleFactor = 0.1
        label.baselineAdjustment = .alignCenters
        label.textAlignment  = .center
        label.adjustsFontSizeToFitWidth=true
        label.textColor = ColorSettings.textColor
    }
    
    func toInt(s: String?) -> Int {
        var result = 0
        if let str: String = s,
            let i = Int(str) {
            result = i
        }
        return result
    }
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        super .viewWillAppear(animated)
        
        let backButtonAttributes: NSDictionary = [NSAttributedStringKey.foregroundColor: ColorSettings.navTextColor]
        UIBarButtonItem.appearance().setTitleTextAttributes(backButtonAttributes as? [NSAttributedStringKey:Any], for: UIControlState.normal)
        
        easterEggSwitchCount=0
        let eventNameClick = UITapGestureRecognizer(target: self, action: #selector(eventNameClickAction(_:)))
        self.EventNameView.addGestureRecognizer(eventNameClick)
        LineView.backgroundColor=ColorSettings.lineColor
        
        //Reset flags to default values
        filterStatus=false
        EventName=""
        
        checkEventName()
        if(EventName=="")
        {
            //Disable swipe
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "clearSwipeList"), object: nil)
        }
        else{
            //Enable swipe
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "createSwipeList"), object: nil)
            //Unhide page control
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "unhidePageControl"), object: nil)
        }
        
        self.checkIns=0
        self.vips=0
        self.guests=0
        self.studentRecords="StudentRecords"
        
        self.checkInList=[]
        self.vipList=[]
        
        
        self.navigationController?.navigationBar.barTintColor=ColorSettings.navBarColor
        self.navigationController?.navigationBar.tintColor = ColorSettings.navTextColor
        
        LoadDataMessage.text="Load data from the admin controls to set up the device for the event."
        LoadDataMessage.font = UIFont(name: "HelveticaNeue-Bold", size: 25)
        LoadDataMessage.numberOfLines = 0
        LoadDataMessage.minimumScaleFactor = 0.1
        LoadDataMessage.baselineAdjustment = .alignCenters
        LoadDataMessage.textAlignment  = .center
        LoadDataMessage.adjustsFontSizeToFitWidth=true
        LoadDataMessage.textColor = ColorSettings.textColor
        
        formatHeaders(label: EventNameLabel, text: self.EventName)

        formatHeaders(label: NumberMessageLabel, text: "Students checked in")
        
        //Get number of Checkins on the device
        //Set default value
        guard let appDelegate = UIApplication.shared.delegate as?AppDelegate else{
            return
        }
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "CheckedInStudent")
        do {
            let checkInRecords = try managedContext.fetch(fetchRequest)
            for record in checkInRecords
            {
                //Find student record for the id
                let id = record.value(forKey: "id") as! String
                
                //Add id to checkIn list
                self.checkInList.append(id)
                
                self.checkIns=self.checkIns+1
                let temp=self.toInt(s: record.value(forKey: "guests") as? String)
                if temp>0
                {
                    self.guests=self.guests+temp
                }
                if (record.value(forKey: "vip") != nil)
                {
                    if record.value(forKey: "vip") as! Bool == true
                    {
                        self.vips=self.vips+1
                        //Add id to vip list
                        self.vipList.append(id)
                    }
                }
            }
            NumberLabel.text=(String) (self.checkIns)
        } catch _ as NSError {
            print ("Could not fetch data")
        }
        

        formatNumbers(label: NumberLabel)
        
        //Get number of student records
        let studentfetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Student")
        do {
            studentRecords = (String)(try (managedContext.fetch(studentfetchRequest)).count)
        } catch _ as NSError {
            print ("Could not fetch data")
        }

        
        checkFilters()
        
        FilterLabel.font = UIFont(name: "HelveticaNeue-Bold", size: 25)
        FilterLabel.numberOfLines = 0
        FilterLabel.minimumScaleFactor = 0.01
        FilterLabel.baselineAdjustment = .alignCenters
        FilterLabel.textAlignment  = .center
        FilterLabel.adjustsFontSizeToFitWidth=true
        FilterLabel.textColor = ColorSettings.textColor
        
        if filterStatus
        {
            FilterView.isHidden=false
            FilterLabel.text=FilterString
        }
        else{
            FilterView.isHidden=true
        }
    }
    
    func formatDataViewElement(label:UILabel)
    {
        label.font = UIFont(name: "Chalkboard", size: 100)
        label.numberOfLines = 0
        label.minimumScaleFactor = 0.1
        label.baselineAdjustment = .alignCenters
        label.textAlignment  = .center
        label.adjustsFontSizeToFitWidth=true
        label.textColor = ColorSettings.textColor
    }
    
    
    
    //Function to get event name
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
    
    //Function to check if any filters are active
    func checkFilters()
    {
        guard let appDelegate = UIApplication.shared.delegate as?AppDelegate else {
            return
        }
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Filter")
        do{
            let temp = try managedContext.fetch(fetchRequest).first
            if (!(temp==nil))
            {
                let type=temp?.value(forKey: "type")! as! Int
                filterType=type
                let killSwitch=temp?.value(forKey: "killSwitch")! as! Bool
                if killSwitch
                {
                    filterStatus=true
                    if type==1
                    {
                        let mainString = "Device set up for "
                        FilterString = mainString+(temp?.value(forKey: "school")! as! String)
                    }
                    else if type==2
                    {
                        let mainString = "Device set up for last names from "
                        FilterString = mainString+(temp?.value(forKey: "from")! as! String)+" to "+(temp?.value(forKey: "to")! as! String)
                    }
                    
                }
                else{
                    filterStatus=false
                }
            }
        }
        catch _ as NSError{
            print("Error checking filter status")
        }
    }
    
    
}

