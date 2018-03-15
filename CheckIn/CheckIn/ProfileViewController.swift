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

class ProfileViewController : UIViewController {
    
    var id : String = ""
    var fname : String = ""
    var lname : String = ""
    var sname : String = ""
    var media : String = ""
    var vip : String = ""
    var spicture : UIImage = UIImage(named:"default")!
    
    
//    @IBOutlet weak var picture: UIImageView!
//    @IBOutlet weak var idLabel: UILabel!
//    @IBOutlet weak var fnameLabel: UILabel!
//    @IBOutlet weak var lnameLabel: UILabel!
//    @IBOutlet weak var snameLabel: UILabel!
//    @IBAction func checkIn(_ sender: UIButton) {
//        let guestAlert=UIAlertController(title: "Guests", message: "Enter the number of guests.", preferredStyle: .alert)
//        guestAlert.addTextField(configurationHandler: {(textField) in
//            textField.placeholder = "Number of Guests"
//        })

    
    @IBOutlet weak var vipBanner: UIImageView!
    @IBOutlet weak var mediaFlag: UISwitch!
    @IBOutlet weak var guestCount: UITextField!
    @IBOutlet weak var idLabel: UILabel!
    @IBOutlet weak var fnameLabel: UILabel!
    @IBOutlet weak var lnameLabel: UILabel!
    @IBOutlet weak var snameLabel: UILabel!
    @IBOutlet weak var picture: UIImageView!
    @IBAction func checkIn(_ sender: UIButton) {
//        let guestAlert=UIAlertController(title: "Guests", message: "Enter the number of guests.", preferredStyle: .alert)
//            guestAlert.addTextField(configurationHandler: {(textField) in
//                textField.placeholder = "Number of Guests"
//        })
//
//        guestAlert.addAction(UIAlertAction(title: "Check-in", style: .default, handler:
//            {
//                (alertAction: UIAlertAction) in
                //Code after Check-in is pressed
                //Check if media waiver is not accepted and show alert as required
        
        //Get status of media switch
        var flag:String
        if(mediaFlag.isOn)
        {
            flag="Y"
        }
        else{
            flag="N"
        }
        
        
        var guests=self.guestCount?.text
        if(!(guests?.isEmpty)!)
        {
            guests=self.guestCount.text!
        }
        else{
            guests="0";
        }
        self.checkMediaWaiver(indicator: flag, id:self.id, fname:self.fname, lname:self.lname, guests: guests!)
//        }))
//        self.present(guestAlert, animated: true)
    }
    
    let idPrefix = "APS ID : "
    let fnamePrefix = "First Name : "
    let lnamePrefix = "Last Name : "
    let snamePrefix = "School Name : "
    
    
    override func viewDidLayoutSubviews() {
        picture.layer.shadowColor = UIColor.black.cgColor
        picture.layer.backgroundColor=UIColor.white.cgColor
        picture.layer.shadowOpacity = 1
        picture.layer.shadowOffset = CGSize.zero
        picture.layer.shadowRadius = 10
        picture.layer.shadowPath = UIBezierPath(rect: picture.bounds).cgPath
        picture.layer.shouldRasterize = false
        picture.layer.cornerRadius = 10
    }
    
    
    override func viewDidLoad() {
        super .viewDidLoad()
        
        
        
        
        //Code to dismiss keyboard when user clicks on the view
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self.view, action: Selector("endEditing:")))
    }
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        self.navigationController?.navigationBar.barTintColor=UIColor(red:2,green:86,blue:0)
        self.navigationController?.navigationBar.tintColor = UIColor(red:253,green:201,blue:16)
        
        let backButtonAttributes: NSDictionary = [NSAttributedStringKey.foregroundColor: UIColor(red:253,green:201,blue:16)]
        UIBarButtonItem.appearance().setTitleTextAttributes(backButtonAttributes as? [NSAttributedStringKey:Any], for: UIControlState.normal)
        
        picture.image=spicture
        idLabel.text=idPrefix+id
        fnameLabel.text=fnamePrefix+fname
        lnameLabel.text=lnamePrefix+lname
        snameLabel.text=snamePrefix+sname
        print(media)
        if(media=="Y")
        {
            mediaFlag.setOn(true, animated: true)
        }
        else if(media=="N")
        {
            mediaFlag.setOn(false, animated: true)
        }
        if(vip=="Y")
        {
            vipBanner.isHidden=false
        }
        else if(vip=="N")
        {
            vipBanner.isHidden=true
        }
    }
    
    //Function to check if media waiver has been accepted
    func checkMediaWaiver(indicator: String, id:String, fname: String, lname: String, guests: String)
    {
        
        //If media waiver is not accepted, display alert
        if indicator=="N"
        {
            let mediaAlert = UIAlertController(title:"Media Waiver not accepted", message:"The student is yet to accept the media waiver!", preferredStyle: .alert)
            
            
            //Make Check in call once accepted
            mediaAlert.addAction(UIAlertAction(title:"Continue", style: .default, handler: {(alert:UIAlertAction) in
                self.checkInStudent(id: id, fname: fname, lname: lname, guests:guests, media: indicator)
            }))
            mediaAlert.addAction(UIAlertAction(title: "Go back", style: .cancel, handler: nil))
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
        let space=" "
        let successlabel="Successfully checked in "
        
        //Write to local data
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        let entity = NSEntityDescription.entity(forEntityName: "CheckedInStudent", in: managedContext)
        let checkedStudent = NSManagedObject(entity: entity!, insertInto: managedContext)
        
        checkedStudent.setValue(id, forKey: "id")
        checkedStudent.setValue(media, forKey: "media")
        if(!guests.isEmpty){
            checkedStudent.setValue(guests, forKey: "guests")
        }
        do{
            try managedContext.save()
        }
        catch _ as NSError{
            print("Could not check-in student")
        }
        
        //Print final success message and move back to QR screen
        let successAlert=UIAlertController(title:"Success", message:successlabel+fname+space+lname , preferredStyle: .alert)
        successAlert.addAction(UIAlertAction(title:"OK", style: .default, handler:
            {
                (alertAction: UIAlertAction) in
                self.navigationController?.popToRootViewController(animated: true)
                
        }))
        self.present(successAlert, animated: true)
    }
    
}








