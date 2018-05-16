//
//  ProfileViewController.swift
//  CheckIn
//
//  Created by Anand Kelkar on 27/02/18.
//  Copyright © 2018 Sam Walk. All rights reserved.
//

import Foundation
import CoreData
import Firebase
import UIKit

class ProfileViewController : UIViewController,UIPickerViewDataSource, UIPickerViewDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 11
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return (String)(row+1)
    }
    
    
    var id : String = ""
    var fname : String = ""
    var lname : String = ""
    var sname : String = ""
    var media : String = ""
    var vip : String = ""
    var spicture : UIImage = UIImage(named:"default")!
    var checked : Bool = false
    var checkedRecord : NSManagedObject?
    
    let alphabets:[String]=["A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z"]
    
    /*
     method used
     1-QRCode
     2-Manual Search
    */
    var method : Int? = nil
    
    @IBOutlet weak var CardView: UIView!
    
    
    //Headers
    @IBOutlet weak var guestsHeader: UILabel!
    
    //Data labels
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var schoolLabel: UILabel!
    @IBOutlet weak var apsLabel: UILabel!
    @IBOutlet weak var partySizePicker: UIPickerView!
    
    @IBOutlet weak var picture: UIImageView!
    @IBAction func checkIn(_ sender: UIButton) {
        //Get status of media switch
        var flag:String
        if(media=="")
        {
            flag="Y"
        }
        else{
            flag="N"
        }
        
        
        let guests=(String)(self.partySizePicker.selectedRow(inComponent: 0))
//        if(!(guests?.isEmpty)!)
//        {
//            guests=self.guestCount.text!
//        }
//        else{
//            guests="0";
//        }
        self.checkMediaWaiver(indicator: flag, id:self.id, fname:self.fname, lname:self.lname, guests: guests, documents: media)
    }
    
    
    override func viewDidLayoutSubviews() {
        CardView.layer.shadowColor = UIColor.black.cgColor
        CardView.layer.backgroundColor=UIColor.white.cgColor
        CardView.layer.shadowOpacity = 1
        CardView.layer.shadowOffset = CGSize.zero
        CardView.layer.shadowRadius = 10
        CardView.layer.shadowPath = UIBezierPath(rect: CardView.bounds).cgPath
        CardView.layer.shouldRasterize = false
        CardView.layer.cornerRadius = 10
        
    }
    
    
    override func viewDidLoad() {
        super .viewDidLoad()
        
        partySizePicker.dataSource=self
        partySizePicker.delegate=self
        partySizePicker.autoresizesSubviews=true
        
        //Code to move view with keyboard
        NotificationCenter.default.addObserver(self, selector: #selector(ProfileViewController.keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ProfileViewController.keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        //Hide page control
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "hidePageControl"), object: nil)
        
        //Code to dismiss keyboard when user clicks on the view
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self.view, action: Selector("endEditing:")))
        
        //Check if filtered
        self.checkWithFilter(x: self.sname, last: self.lname)
        
        //Check if already checked in
        self.checkIfAlreadyCheckedIn(id: self.id)
        
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0{
                self.view.frame.origin.y -= keyboardSize.height
            }
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y != 0{
                self.view.frame.origin.y += keyboardSize.height
            }
        }
    }
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        super .viewWillAppear(animated)
        //Disable swipe
        
        self.navigationController?.navigationBar.barTintColor=ColorSettings.navBarColor
        self.navigationController?.navigationBar.tintColor = ColorSettings.navTextColor
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "clearSwipeList"), object: nil)
        
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        
//        let backButtonAttributes: NSDictionary = [NSAttributedStringKey.foregroundColor: ColorSettings.navTextColor]
//        UIBarButtonItem.appearance().setTitleTextAttributes(backButtonAttributes as? [NSAttributedStringKey:Any], for: UIControlState.normal)
        
        picture.image=spicture
        nameLabel.text=fname+" "+lname
        schoolLabel.text=sname
        apsLabel.text="APS ID:  "+id
        formatLabel(label: nameLabel, header: true, background: true)
        formatLabel(label: schoolLabel, header: false, background: false)
        formatLabel(label: apsLabel, header: false, background: false)
        formatLabel(label: guestsHeader, header: true, background: false)
        
    }
    
    //Function to configure the labels properties to resize and color
    func formatLabel(label:UILabel,header:Bool,background:Bool)
    {
        var color:UIColor
        var font:UIFont
        if(header)
        {
            color=ColorSettings.labelColor
            font=UIFont(name: "HelveticaNeue", size: 24)!
            if background {
                label.backgroundColor=ColorSettings.lineColor
                color=ColorSettings.navTextColor
            }
        }
        else{
            color=ColorSettings.textColor
            if !background {
             color=ColorSettings.labelColor
            }
            font=UIFont(name: "HelveticaNeue", size: 18)!
        }
        label.numberOfLines=0
        label.font = font
        label.minimumScaleFactor=0.1
        label.adjustsFontSizeToFitWidth=true
        label.textColor=color
    }
    
    //Function to check if student has already checkedIn
    func checkIfAlreadyCheckedIn(id:String)
    {
        var checkIn : [NSManagedObject]
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "CheckedInStudent")
        fetchRequest.predicate = NSPredicate(format: "id == %@", id)
        do {
            checkIn = try managedContext.fetch(fetchRequest)
            
            if(!checkIn.isEmpty)
            {
                let checkInAlert = UIAlertController(title:"Warning", message:"Student has already checked-in on this device", preferredStyle: .alert)
                checkInAlert.addAction(UIAlertAction(title:"OK", style: .cancel, handler:nil))
//                guestCount.text=(String)(Int(checkIn.first?.value(forKey: "guests") as! String)!+1)
                let partySize=Int(checkIn.first?.value(forKey: "guests") as! String)!
                partySizePicker.selectRow(partySize, inComponent: 0, animated: true)
                checkedRecord=checkIn.first
                checked=true
                self.present(checkInAlert, animated:true)
            }
        }
        catch _ as NSError {
            print ("Error when checking if already checked in")
        }
    }
    
    //Function to check if media waiver has been accepted
    func checkMediaWaiver(indicator: String, id:String, fname: String, lname: String, guests: String, documents:String)
    {
        
        //If media waiver is not accepted, display alert
        if indicator=="N"
        {
            let docs:[String]=documents.components(separatedBy: "-")
            var tempDocumentString=""
            for value in docs{
                tempDocumentString=tempDocumentString+value+"\n"
            }
            let mediaAlert = UIAlertController(title:"Documents not Signed", message: tempDocumentString, preferredStyle: .alert)
            
            
            //Make Check in call once accepted
            mediaAlert.addAction(UIAlertAction(title:"Continue", style: .default, handler: {(alert:UIAlertAction) in
                self.checkInStudent(id: id, fname: fname, lname: lname, guests:guests, media: indicator)
            }))
//            mediaAlert.addAction(UIAlertAction(title: "Go back", style: .cancel, handler: nil))
            self.present(mediaAlert, animated: true)
        }
            //If media waiver is accepted, proceed with check-in
        else{
            self.checkInStudent(id: id, fname:fname, lname:lname, guests:guests, media:indicator)
        }
    }
    
    
    //Function to complete the check in
    func checkInStudent(id: String, fname: String, lname: String, guests:String, media: String)
    {
        //Write to local data
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        
        if !checked
        {
            //Write to CheckInStudent object
            let entity = NSEntityDescription.entity(forEntityName: "CheckedInStudent", in: managedContext)
            let checkedStudent = NSManagedObject(entity: entity!, insertInto: managedContext)
            
            checkedStudent.setValue(id, forKey: "id")
            checkedStudent.setValue(media, forKey: "media")
            if(!guests.isEmpty){
                //Subtract 1 to get guest count
                if(Int(guests)! as Int > 0)
                {
//                    let temp=Int(guests)!-1
                    checkedStudent.setValue(guests, forKey: "guests")
                }
                    //Set guests to 0 if number goes below 0 after subtracting student
                else
                {
                    checkedStudent.setValue("0", forKey: "guests")
                }
            }
                //Set guests to 0 if field is left empty on check in
            else {
                checkedStudent.setValue("0", forKey: "guests")
            }
            if(self.vip=="Y")
            {
                checkedStudent.setValue(true, forKey: "vip")
            }
            else{
                checkedStudent.setValue(false, forKey: "vip")
            }
            checkedStudent.setValue(method, forKey: "method")
            
            //Update checkedIn flag
            var studentResult : [NSManagedObject]
            let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Student")
            fetchRequest.predicate = NSPredicate(format: "studentId == %@", id)
            do {
                studentResult = try managedContext.fetch(fetchRequest)
                let student=studentResult.first
                student?.setValue(true, forKey: "checkedIn")
                try managedContext.save()
            }
            catch _ as NSError{
                print("Could not check-in student")
            }
        }
        else if checked{
            if(!guests.isEmpty){
                //Subtract 1 to get guest count
                if(Int(guests)! as Int > 0)
                {
//                    let temp=Int(guests)!-1
                    checkedRecord?.setValue(guests, forKey: "guests")
                }
                    //Set guests to 0 if number goes below 0 after subtracting student
                else
                {
                    checkedRecord?.setValue("0", forKey: "guests")
                }
            }
                //Set guests to 0 if field is left empty on check in
            else {
                checkedRecord?.setValue("0", forKey: "guests")
            }
            do {
                try managedContext.save()
            }
            catch _ as NSError{
                print("Error updating guest count")
            }
        }
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "reload"), object: nil)
        self.navigationController?.popToRootViewController(animated: true)
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "scanEnable"), object: nil)
        
    }
    
    //Function to check if profile passes the filter if any
    func checkWithFilter(x:String ,last:String)
    {
        guard let appDelegate = UIApplication.shared.delegate as?AppDelegate else {
            return
        }
        let managedContext = appDelegate.persistentContainer.viewContext
        //Get event name
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Filter")
        do{
            let temp = try managedContext.fetch(fetchRequest).first
            if(!(temp?.value(forKey: "killSwitch")==nil) && temp?.value(forKey: "killSwitch") as! Bool)
            {
                if (temp?.value(forKey: "type") as! Int)==1
                {
                    if !(x == (temp?.value(forKey: "school")) as! String)
                    {
                        self.showFilterAlert(x: (temp?.value(forKey: "school")) as! String)
                    }
                }
                else if (temp?.value(forKey: "type") as! Int)==2
                {
                    let from = alphabets.index(of: temp?.value(forKey: "from") as! String)!
                    let to = alphabets.index(of: temp?.value(forKey: "to") as! String)!
                    let testIndex = alphabets.index(of: String((last.first)!))!
                    
                    if testIndex<from || testIndex>to {
                        self.showFilterAlert(x: (temp?.value(forKey: "from") as! String+" to "+(temp?.value(forKey: "to") as! String)))
                    }
                    
                }
            }
        }
        catch _ as NSError
        {
            print("Error checking profile against filter")
        }
    }
    
    
    //Function to display a filtering alert
    func showFilterAlert(x: String)
    {
        let checkFilterAlert = UIAlertController(title:"Warning", message:"Student cannot be checked-in on this device. Filter active for "+x, preferredStyle: .alert)
        checkFilterAlert.addAction(UIAlertAction(title:"OK", style: .cancel, handler:{(alertAction : UIAlertAction) in
            self.navigationController?.popToRootViewController(animated: true)
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "scanEnable"), object: nil)
        }))
        self.present(checkFilterAlert, animated:true)
    }
    
}








