//
//  CheckInListViewController.swift
//  CheckIn
//
//  Created by Anand Kelkar on 12/04/18.
//  Copyright © 2018 Sam Walk. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class CustomListCell: UITableViewCell {
    @IBOutlet weak var lName: UILabel!
    @IBOutlet weak var fName: UILabel!
    @IBOutlet weak var sName: UILabel!
    
}

class CheckInListViewController : UIViewController, UITableViewDataSource {
    
    @IBOutlet weak var mainImage: UIImageView!
    @IBOutlet weak var dataView: UITableView!
    @IBOutlet weak var dataHolderView: UIView!
    
    var image:UIImage?
    var data:[String]=[]
    
    struct student{
        var fname:String?
        var lname:String?
        var school:String?
    }
    var tableData:[student]=[]
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
//        dataHolderView.layer.shadowColor = UIColor.black.cgColor
//        dataHolderView.layer.backgroundColor=UIColor.white.cgColor
//        dataHolderView.layer.shadowOpacity = 1
//        dataHolderView.layer.shadowOffset = CGSize.zero
//        dataHolderView.layer.shadowRadius = 10
//        dataHolderView.layer.shadowPath = UIBezierPath(rect: dataHolderView.bounds).cgPath
//        dataHolderView.layer.shouldRasterize = false
//        dataHolderView.layer.cornerRadius = 10
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        //Disable swipe
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "clearSwipeList"), object: nil)
        
        tableData=[]
        mainImage.image=image
        
        
        //Find student record for the id
        var studentRecords : [NSManagedObject]
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Student")
        for studentId in data
        {
            fetchRequest.predicate = NSPredicate(format: "studentId == %@", studentId)
            do {
                studentRecords = try managedContext.fetch(fetchRequest)
                let temp=studentRecords.first
                tableData.append(student(fname: (temp?.value(forKey: "firstName") as! String), lname: (temp?.value(forKey: "lastName") as! String), school: (temp?.value(forKey: "school") as! String)))
            }
            catch _ as NSError
            {
                print("Unable to generate list")
            }
        }
    }
    
    override func viewDidLoad() {
        super .viewDidLoad()
        dataView.dataSource=self
    }
    
    func formatCellLabel(label:UILabel) {
        label.numberOfLines=0;
        label.font = UIFont(name: "HelveticaNeue", size: 20)
        label.minimumScaleFactor = 0.01
        label.adjustsFontSizeToFitWidth=true
        label.textColor = UIColor(red:253,green:201,blue:16)

    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = dataView.dequeueReusableCell(withIdentifier: "customListCell") as! CustomListCell
        let temp = tableData[indexPath.row]
        cell.fName.text=temp.fname
        formatCellLabel(label: cell.fName)
        cell.lName.text=temp.lname
        formatCellLabel(label: cell.lName)
        cell.sName.text=temp.school
        formatCellLabel(label: cell.sName)
        
        return cell
    }
    
    
    
    
}
