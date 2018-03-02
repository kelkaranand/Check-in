//
//  FirTableViewController.swift
//  CheckIn
//
//  Created by Anand Kelkar on 22/02/18.
//  Copyright © 2018 Sam Walk. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import CoreData


struct student {
    let fname:String
    let lname:String
    let media:String
    let id:String
}


class FirTableViewController : UITableViewController{
    
    var ref: DatabaseReference!
    
    var students=[student]()
    
    
    override func viewDidLoad() {
        super .viewDidLoad()
        
        ref=Database.database().reference(withPath: "students")
        
        ref.observe(.value, with: { snapshot in

            for data in snapshot.children {
                let studentData = data as! DataSnapshot
                var fields = studentData.value as? [String:AnyObject]
                let fname=fields!["fname"] as! String
                let lname=fields!["lname"] as! String
                let media=fields!["media"] as! String
                let id=fields!["id"] as! String
                let studentRecord = student(fname: fname, lname: lname, media: media, id: id)
                self.students.append(studentRecord)
                
                print(fname)
            }
        })
        
        
        
        
        
        
    }
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return students.count
    }
    
//    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//
//    }
    
}
