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
    
    @IBOutlet weak var StudentNumberView: UIView!
    @IBOutlet weak var StudentNumberMessage: UILabel!
    @IBOutlet weak var StudentNumber: UILabel!
    
    @IBOutlet weak var GuestNumberView: UIView!
    @IBOutlet weak var GuestNumberMessage: UILabel!
    @IBOutlet weak var GuestNumber: UILabel!
    
    @IBOutlet weak var VipNumberView: UIView!
    @IBOutlet weak var VipNumberMessage: UILabel!
    @IBOutlet weak var VipNumber: UILabel!
    
    var checkInList : [String] = []
    var vipList : [String] = []
    
    var EventName:String=""
    var checkIns:Int=0
    var guests:Int=0
    var vips:Int=0
    var studentRecords:Int=0
    
    /*
     1-CheckInList
     2-VipList
    */
    var click:Int?
    
    
    @objc func checkInClickAction(_ : UITapGestureRecognizer){
        self.click=1
        self.performSegue(withIdentifier: "showCheckInList", sender: self)
    }
    
    @objc func vipClickAction(_ : UITapGestureRecognizer){
        self.click=2
        self.performSegue(withIdentifier: "showCheckInList", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if let view = segue.destination as? CheckInListViewController
        {
            if self.click==1
            {
                view.image=UIImage(named:"checkmark")
                view.data=self.checkInList
            }
            else{
                view.image=UIImage(named:"vip")
                view.data=self.vipList
            }
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
            StudentNumberView.isHidden=true
            GuestNumberView.isHidden=true
            VipNumberView.isHidden=true
            
        }
        else{
            
            
            self.view.backgroundColor=UIColor.white
            LoadDataMessage.isHidden=true
            NumberView.isHidden=false
            EventNameView.isHidden=false
            LineView.isHidden=false
            StudentNumberView.isHidden=false
            GuestNumberView.isHidden=false
            VipNumberView.isHidden=false
            LineView.backgroundColor=UIColor(red:3,green:129,blue:0)
            
            addBorderToView(view: NumberView)
            addBorderToView(view: StudentNumberView)
            addBorderToView(view: GuestNumberView)
            addBorderToView(view: VipNumberView)
            
        }
    }
    
    
    func addBorderToView(view:UIView)
    {
        view.layer.borderColor=UIColor(red:3,green:129,blue:0).cgColor
        view.layer.borderWidth=2
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
        label.textColor = UIColor(red:253,green:201,blue:16)
    }
    
    func formatNumbers(label:UILabel)
    {
        label.font = UIFont(name: "HelveticaNeue-Bold", size: 600)
        label.numberOfLines = 0
        label.minimumScaleFactor = 0.1
        label.baselineAdjustment = .alignCenters
        label.textAlignment  = .center
        label.adjustsFontSizeToFitWidth=true
        label.textColor = UIColor(red:253,green:201,blue:16)
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
        
        let checkInClick = UITapGestureRecognizer(target: self, action:#selector(checkInClickAction(_ :)))
        self.NumberView.addGestureRecognizer(checkInClick)
        
        let vipClick = UITapGestureRecognizer(target: self, action:#selector(vipClickAction(_ :)))
        self.VipNumberView.addGestureRecognizer(vipClick)
        
        
        
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
        
        self.checkIns=0
        self.vips=0
        self.guests=0
        self.studentRecords=0
        
        self.checkInList=[]
        self.vipList=[]
        
        
        self.navigationController?.navigationBar.barTintColor=UIColor(red:2,green:86,blue:0)
        self.navigationController?.navigationBar.tintColor = UIColor(red:253,green:201,blue:16)
        
        LoadDataMessage.text="Load data from the admin controls to set up the device for the event."
        LoadDataMessage.font = UIFont(name: "HelveticaNeue-Bold", size: 25)
        LoadDataMessage.numberOfLines = 0
        LoadDataMessage.minimumScaleFactor = 0.1
        LoadDataMessage.baselineAdjustment = .alignCenters
        LoadDataMessage.textAlignment  = .center
        LoadDataMessage.adjustsFontSizeToFitWidth=true
        LoadDataMessage.textColor = UIColor(red:253,green:201,blue:16)
        
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
            GuestNumber.text=(String) (self.guests)
            VipNumber.text=(String) (self.vips)
        } catch _ as NSError {
            print ("Could not fetch data")
        }
        

        formatNumbers(label: NumberLabel)

        formatHeaders(label: StudentNumberMessage, text: "Students records")
        
        //Get number of student records
        let studentfetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Student")
        do {
            StudentNumber.text = (String)(try (managedContext.fetch(studentfetchRequest)).count)
        } catch _ as NSError {
            print ("Could not fetch data")
        }

        formatNumbers(label: StudentNumber)

        formatHeaders(label: GuestNumberMessage, text: "Guests checked in")
        
        formatNumbers(label: GuestNumber)
        
        

        formatHeaders(label: VipNumberMessage, text: "VIPs checked in")
        formatNumbers(label: VipNumber)
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

