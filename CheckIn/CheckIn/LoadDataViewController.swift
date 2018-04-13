//
//  LoadDataViewController.swift
//  CheckIn
//
//  Created by Anand Kelkar on 11/04/18.
//  Copyright © 2018 Sam Walk. All rights reserved.
//

import Foundation
import CoreData
import UIKit
import Firebase

class LoadDataViewController : UIViewController
{
    @IBOutlet weak var DataView: UIView!
    @IBOutlet weak var ButtonImage: UIImageView!
    @IBOutlet weak var LoadDataMessage: UILabel!
    
    
    @objc func pullAction(_ : UITapGestureRecognizer){
        self.getData()
        self.performSegue(withIdentifier: "loadScreenToLanding", sender: self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        ButtonImage.isUserInteractionEnabled=true
        let pullClick = UITapGestureRecognizer(target: self, action:#selector(pullAction(_ :)))
        self.ButtonImage.addGestureRecognizer(pullClick)
    }
    
    
    override func viewDidLoad() {
        ButtonImage.image=UIImage(named:"LJFF-logo")
        LoadDataMessage.text="To get started, click on the logo above to pull event data onto the device."
        LoadDataMessage.font = UIFont(name: "HelveticaNeue-Bold", size: 25)
        LoadDataMessage.numberOfLines = 0
        LoadDataMessage.minimumScaleFactor = 0.1
        LoadDataMessage.baselineAdjustment = .alignCenters
        LoadDataMessage.textAlignment  = .center
        LoadDataMessage.adjustsFontSizeToFitWidth=true
        LoadDataMessage.textColor = UIColor(red:253,green:201,blue:16)
    }
    
    //Function to get data after clearing current data
    func getData()
    {
        self.clearData()
        self.pullData()
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
    
    //Function to read Student data from Firebase
    func pullData()
    {
        initializeDecrypter()
        
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
                
                student.setValue(self.decrypt(x:fname), forKey: "firstName")
                student.setValue(self.decrypt(x:lname), forKey: "lastName")
                student.setValue(media, forKey: "media")
                student.setValue(id, forKey: "studentId")
                student.setValue(self.decrypt(x:school), forKey: "school")
                student.setValue(vip, forKey: "vip")
                student.setValue(false, forKey: "checkedIn")
                
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
                print(String(x[i]))
                temp=temp+String(x[i])
            }
        }
        return temp
    }

    
}
