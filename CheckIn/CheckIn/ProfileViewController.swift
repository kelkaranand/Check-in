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
    
    //Data stack view
    @IBOutlet weak var dataView: UIView!
    
    //Headers
    @IBOutlet weak var idHeader: UILabel!
    @IBOutlet weak var fnameHeader: UILabel!
    @IBOutlet weak var lnameHeader: UILabel!
    @IBOutlet weak var snameHeader: UILabel!
    @IBOutlet weak var mediaHeader: UILabel!
    @IBOutlet weak var guestsHeader: UILabel!
    
    //Data labels
    @IBOutlet weak var idLabel: UILabel!
    @IBOutlet weak var fnameLabel: UILabel!
    @IBOutlet weak var lnameLabel: UILabel!
    @IBOutlet weak var snameLabel: UILabel!
    @IBOutlet weak var mediaLabel: UILabel!
    @IBOutlet weak var guestCount: UITextField!
    
    @IBOutlet weak var vipBanner: UIImageView!
    @IBOutlet weak var picture: UIImageView!
    @IBAction func checkIn(_ sender: UIButton) {
        //Get status of media switch
        var flag:String
        if(media=="Y")
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
    }
    
    
    override func viewDidLayoutSubviews() {
        picture.layer.shadowColor = UIColor.black.cgColor
        picture.layer.backgroundColor=UIColor.white.cgColor
        picture.layer.shadowOpacity = 1
        picture.layer.shadowOffset = CGSize.zero
        picture.layer.shadowRadius = 10
        picture.layer.shadowPath = UIBezierPath(rect: picture.bounds).cgPath
        picture.layer.shouldRasterize = false
        picture.layer.cornerRadius = 10
        
//        dataView.layer.shadowColor = UIColor.black.cgColor
//        dataView.layer.backgroundColor=UIColor.white.cgColor
//        dataView.layer.shadowOpacity = 1
//        dataView.layer.shadowOffset = CGSize.zero
//        dataView.layer.shadowRadius = 10
//        dataView.layer.shadowPath = UIBezierPath(rect: dataView.bounds).cgPath
//        dataView.layer.shouldRasterize = false
//        dataView.layer.cornerRadius = 10
    }
    
    
    override func viewDidLoad() {
        super .viewDidLoad()
        
        
        //Code to move view with keyboard
        NotificationCenter.default.addObserver(self, selector: #selector(ProfileViewController.keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ProfileViewController.keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        //Code to dismiss keyboard when user clicks on the view
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self.view, action: Selector("endEditing:")))
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
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        self.navigationController?.navigationBar.barTintColor=UIColor(red:2,green:86,blue:0)
        self.navigationController?.navigationBar.tintColor = UIColor(red:253,green:201,blue:16)
        
        let backButtonAttributes: NSDictionary = [NSAttributedStringKey.foregroundColor: UIColor(red:253,green:201,blue:16)]
        UIBarButtonItem.appearance().setTitleTextAttributes(backButtonAttributes as? [NSAttributedStringKey:Any], for: UIControlState.normal)
        
        picture.image=spicture
        idLabel.text=id
        fnameLabel.text=fname
        lnameLabel.text=lname
        snameLabel.text=sname
        
        //Set media waiver values
        if(media=="Y")
        {
            mediaLabel.text="Signed"
        }
        else if(media=="N")
        {
            mediaLabel.text="Not Signed"
        }
        
        //Check VIP status
        if(vip=="Y")
        {
            vipBanner.isHidden=false
        }
        else if(vip=="N")
        {
            vipBanner.isHidden=true
        }
        
        formatLabel(label: idHeader, header: true)
        formatLabel(label: idLabel, header: false)
        formatLabel(label: fnameHeader, header: true)
        formatLabel(label: fnameLabel, header: false)
        formatLabel(label: lnameHeader, header: true)
        formatLabel(label: lnameLabel, header: false)
        formatLabel(label: snameHeader, header: true)
        formatLabel(label: snameLabel, header: false)
        formatLabel(label: mediaHeader, header: true)
        formatLabel(label: mediaLabel, header: false)
        formatLabel(label: guestsHeader, header: true)
        
    }
    
    //Function to configure the labels properties to resize and color
    func formatLabel(label:UILabel,header:Bool)
    {
        var color:UIColor
        var font:UIFont
        if(header)
        {
            color=UIColor(red:3,green:129,blue:0)
            font=UIFont(name: "HelveticaNeue-Bold", size: 20)!
        }
        else{
            color=UIColor(red:253,green:201,blue:16)
            font=UIFont(name: "HelveticaNeue-Bold", size: 20)!
        }
        label.numberOfLines=0
        label.font = font
        label.minimumScaleFactor=0.1
        label.adjustsFontSizeToFitWidth=true
        label.textColor=color
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
//        let successAlert=UIAlertController(title:"Success", message:successlabel+fname+space+lname , preferredStyle: .alert)
//        successAlert.addAction(UIAlertAction(title:"OK", style: .default, handler:
//            {
//                (alertAction: UIAlertAction) in
//                self.navigationController?.popToRootViewController(animated: true)
//                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "scanEnable"), object: nil)
//
//
//        }))
//        self.present(successAlert, animated: true)
        
        self.navigationController?.popToRootViewController(animated: true)
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "scanEnable"), object: nil)
        
    }
    
}








