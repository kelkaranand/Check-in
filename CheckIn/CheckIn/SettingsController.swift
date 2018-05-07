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
    @IBOutlet weak var FilterListView: UIView!
    @IBOutlet weak var FilterListHeader: UILabel!
    @IBOutlet weak var FilterListMessage: UILabel!
    @IBOutlet weak var EventDetailsView: UIView!
    @IBOutlet weak var EventDetailsHeader: UILabel!
    @IBOutlet weak var EventDetailsMessage: UILabel!
    
    @IBOutlet var mainView: UIView!
    
    //Fields used for event details button
    var checkInList:[String]=[]
    var eventName:String=""
    var guests:Int=0
    var vipList:[String]=[]
    var studentRecords:String=""
    var filterStatus:Bool = false
    var filterType:Int = 0
    var FilterString:String = "message"
    
    
    
    var schoolList:[String]=[]
    //Flag to check if coming from landing screen. Allows to manage admin alert
    var comingFromLanding = false
    
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
            self.updateTable()
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(alert, animated: true)
    }
   
    @objc func filterAction(_ : UITapGestureRecognizer)
    {
        self.performSegue(withIdentifier: "filterList", sender: self)
        self.comingFromLanding=false
    }
    
    @objc func detailsClickAction(_ : UITapGestureRecognizer){
        self.performSegue(withIdentifier: "showEventDetails", sender: self)
        self.comingFromLanding=false
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if let view = segue.destination as? SetFilterViewController
        {
            view.schoolList=self.schoolList
        }
        if let view = segue.destination as? EventDetailViewController
        {
            view.checkInList=self.checkInList
            view.EventName=self.eventName
            view.guests=self.guests
            view.vipList=self.vipList
            view.studentRecords=self.studentRecords
        }
    }
    
    
    func updateTable()
    {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "reload"), object: nil)
    }
    
    //Function to set up the schoolList from the schools captured from the latest data pull
    func initializeSchoolList()
    {
        self.schoolList=[]
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "School")
        
        do {
            let localData = try managedContext.fetch(fetchRequest)
            
            for data in localData
            {
                self.schoolList.append(data.value(forKey: "name") as! String)
            }
        }
        catch _ as NSError
        {
            print("Error reading school list")
        }
    }
    
    
    //Function to format the look of the individual views
    func formatView(view: UIView, header: UILabel, message: UILabel)
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
        
        header.font = UIFont(name: "HelveticaNeue-Bold", size: 600)
        header.numberOfLines = 0
        header.minimumScaleFactor = 0.01
        header.baselineAdjustment = .alignCenters
        header.textAlignment  = .center
        header.adjustsFontSizeToFitWidth=true
        header.textColor = ColorSettings.textColor
        
        message.font = UIFont(name: "HelveticaNeue", size: 200)
        message.numberOfLines = 0
        message.minimumScaleFactor = 0.01
        message.baselineAdjustment = .alignCenters
        message.textAlignment  = .center
        message.adjustsFontSizeToFitWidth=true
        message.textColor = ColorSettings.textColor
    }
    
    override func viewDidLayoutSubviews() {
        
        formatView(view: PushDataView, header: PushDataHeader, message: PushDataMessage)
        PushDataHeader.text="Push Data"
        PushDataMessage.text="Push check-in data to cloud storage"
        
        formatView(view: PullDataView, header: PullDataHeader, message: PullDataMessage)
        PullDataHeader.text="Pull Data"
        PullDataMessage.text="Pull event data from cloud storage"
        
        formatView(view: FilterListView, header: FilterListHeader, message: FilterListMessage)
        FilterListHeader.text="Set Filter"
        FilterListMessage.text="Select who can check in from this device"
        
        formatView(view: EventDetailsView, header: EventDetailsHeader, message: EventDetailsMessage)
        EventDetailsHeader.text="Event Details"
        EventDetailsMessage.text="View check-in details for current event"
        

    }
//    
//    override func viewDidAppear(_ animated: Bool) {
//        formatView(view: PushDataView, header: PushDataHeader, message: PushDataMessage)
//        PushDataHeader.text="Push Data"
//        PushDataMessage.text="Push check-in data to cloud storage"
//        
//        formatView(view: PullDataView, header: PullDataHeader, message: PullDataMessage)
//        PullDataHeader.text="Pull Data"
//        PullDataMessage.text="Pull event data from cloud storage"
//        
//        formatView(view: FilterListView, header: FilterListHeader, message: FilterListMessage)
//        FilterListHeader.text="Set Filter"
//        FilterListMessage.text="Select who can check in from this device"
//        
//        formatView(view: EventDetailsView, header: EventDetailsHeader, message: EventDetailsMessage)
//        EventDetailsHeader.text="Event Details"
//        EventDetailsMessage.text="View check-in details for current event"
//    }
    
    
    var students: [NSManagedObject] = []
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //Hide page control
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "hidePageControl"), object: nil)
        
        self.navigationController?.navigationBar.barTintColor=ColorSettings.navBarColor
        self.navigationController?.navigationBar.tintColor = ColorSettings.navTextColor
        
        let pushClick = UITapGestureRecognizer(target:self, action:#selector(pushAction(_ :)))
        
        let pullClick = UITapGestureRecognizer(target: self, action:#selector(pullAction(_ :)))
        
        let filterClick = UITapGestureRecognizer(target: self, action:#selector(filterAction(_:)))
        
        let detailsClick = UITapGestureRecognizer(target: self, action: #selector(detailsClickAction(_:)))
        
        self.PushDataView.addGestureRecognizer(pushClick)
        self.PullDataView.addGestureRecognizer(pullClick)
        self.FilterListView.addGestureRecognizer(filterClick)
        self.EventDetailsView.addGestureRecognizer(detailsClick)
        
        self.initializeSchoolList()
        
        if comingFromLanding
        {
            let alert = UIAlertController(title: "Warning", message: "You are entering the admin page, do you want to continue?", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Yes", style: .default, handler:
                {
                    (alertAction: UIAlertAction) in
                    
                    //Disable swipe
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "clearSwipeList"), object: nil)
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
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler:
                {
                    (alertAction: UIAlertAction) in
                    self.navigationController?.popToRootViewController(animated: true)
            }))
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
    
    
    var decrypter = [String:String]()
    
    func initializeDecrypter()
    {
        decrypter["d"]="a"
        decrypter["q"]="b"
        decrypter["e"]="c"
        decrypter["r"]="d"
        decrypter["f"]="e"
        decrypter["s"]="f"
        decrypter["g"]="g"
        decrypter["t"]="h"
        decrypter["h"]="i"
        decrypter["u"]="j"
        decrypter["i"]="k"
        decrypter["v"]="l"
        decrypter["j"]="m"
        decrypter["w"]="n"
        decrypter["k"]="o"
        decrypter["x"]="p"
        decrypter["l"]="q"
        decrypter["y"]="r"
        decrypter["m"]="s"
        decrypter["z"]="t"
        decrypter["n"]="u"
        decrypter["c"]="v"
        decrypter["o"]="w"
        decrypter["b"]="x"
        decrypter["p"]="y"
        decrypter["a"]="z"
    
        decrypter["D"]="A"
        decrypter["Q"]="B"
        decrypter["E"]="C"
        decrypter["R"]="D"
        decrypter["F"]="E"
        decrypter["S"]="F"
        decrypter["G"]="G"
        decrypter["T"]="H"
        decrypter["H"]="I"
        decrypter["U"]="J"
        decrypter["I"]="K"
        decrypter["V"]="L"
        decrypter["J"]="M"
        decrypter["W"]="N"
        decrypter["K"]="O"
        decrypter["X"]="P"
        decrypter["L"]="Q"
        decrypter["Y"]="R"
        decrypter["M"]="S"
        decrypter["Z"]="T"
        decrypter["N"]="U"
        decrypter["C"]="V"
        decrypter["O"]="W"
        decrypter["B"]="X"
        decrypter["P"]="Y"
        decrypter["A"]="Z"
    }
    
    func decrypt(x:String) -> String
    {
        var temp = ""
        for i in x.indices
        {
            if(decrypter.keys.contains(String(x[i])))
            {
                temp=temp+decrypter[String(x[i])]!
            }
            else{
                temp=temp+String(x[i])
            }
        }
        return temp
    }
    
    
    //Function to read Student data from Firebase
    func pullData()
    {
        initializeDecrypter()
        schoolList=[]
        
        //Pull data from database
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }

        let managedContext = appDelegate.persistentContainer.viewContext
        let entity = NSEntityDescription.entity(forEntityName: "Student", in: managedContext)
        let schoolEntity = NSEntityDescription.entity(forEntityName: "School", in: managedContext)



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

                student.setValue(self.decrypt(x:fname), forKey: "firstName")
                student.setValue(self.decrypt(x:lname), forKey: "lastName")
                student.setValue(media, forKey: "media")
                student.setValue(id, forKey: "studentId")
                student.setValue(self.decrypt(x:school), forKey: "school")
                student.setValue(vip, forKey: "vip")
                student.setValue(false, forKey: "checkedIn")
                
                //Generate a list of schools
                let temp=self.decrypt(x: school)
                if !(self.schoolList.contains(temp))
                {
                    self.schoolList.append(temp)
                    let schoolName = NSManagedObject(entity: schoolEntity!, insertInto: managedContext)
                    schoolName.setValue(temp, forKey: "name")
                    schoolName.setValue(false, forKey: "filter")
                }

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
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler:
            {
                (alertAction: UIAlertAction) in
                self.navigationController?.popToRootViewController(animated: true)
        }))
        self.present(alert, animated: true)
        
        
    }
    
    //Function to clear all local data
    func clearData()
    {
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
        
        //Clear School data
        ReqVar = NSFetchRequest<NSFetchRequestResult>(entityName: "School")
        DelAllReqVar = NSBatchDeleteRequest(fetchRequest: ReqVar)
        do { try managedContext.execute(DelAllReqVar) }
        catch { print("Error when clearing data"+error.localizedDescription) }
        
        //Clear Filter data
        ReqVar = NSFetchRequest<NSFetchRequestResult>(entityName: "Filter")
        DelAllReqVar = NSBatchDeleteRequest(fetchRequest: ReqVar)
        do { try managedContext.execute(DelAllReqVar) }
        catch { print("Error when clearing data"+error.localizedDescription) }
        
        managedContext.reset()
    }
    

}


