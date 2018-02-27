//
//  ViewController.swift
//  CheckIn
//
//  Created by Samuel Walk on 2/13/18.
//  Copyright © 2018 Sam Walk. All rights reserved.
//

import UIKit
import CoreData
import os.log

class StudentTableViewCell: UITableViewCell {
    @IBOutlet weak var studentId: UILabel!
    @IBOutlet weak var firstName: UILabel!
    @IBOutlet weak var lastName: UILabel!
    //@IBOutlet weak var school: UILabel!
    
}

class StudentTableViewController: UIViewController {

    @IBOutlet weak var studentTableView: UITableView!
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    var students: [NSManagedObject] = []
    var filteredStudents: [NSManagedObject] = []
    let searchController = UISearchController(searchResultsController: nil)
    
    //var students=[student]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setup search controller
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Students"
        navigationItem.searchController = searchController
        definesPresentationContext = true
        
        title = "Check In"
        studentTableView.dataSource = self
        studentTableView.delegate = self
        studentTableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Student")
        
        do {
            students = try managedContext.fetch(fetchRequest)
        } catch let error as NSError {
            print ("Could not fetch data")
        }
    }
    
    //Shows the alert pop up when QRCode is scanned
    func showAlert(id: String) {
        
        //Find student record by APS ID
        var student : [NSManagedObject]
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Student")
        fetchRequest.predicate = NSPredicate(format: "studentId == %@", id)
        
        do {
            student = try managedContext.fetch(fetchRequest)
            
            if(student.isEmpty)
            {
                var invalidQrAlert = UIAlertController(title:"No record found", message:"No record was found for the scanned code. Try using the manual search", preferredStyle: .alert)
                invalidQrAlert.addAction(UIAlertAction(title:"OK", style: .cancel, handler:nil))
                self.present(invalidQrAlert, animated:true)
            }
            else{
                //Fields and labels
                var studentRecord=student.first
                var fname=studentRecord?.value(forKey:"firstName") as! String
                var lname=studentRecord?.value(forKey:"lastName") as! String
                var sname=studentRecord?.value(forKey:"school") as! String
                var media=studentRecord?.value(forKey:"media") as! String
                var id=studentRecord?.value(forKey:"studentId") as! String
                var flabel="First Name: "
                var llabel="Last Name: "
                var ilabel="APS ID: "
                var mlabel="Media Waiver: "
                var slabel="School Name: "
                var nextLine="\n"
                
                //Create alert on screen
                var alert = UIAlertController(title: "Record Found", message: nextLine+ilabel+id+nextLine+flabel+fname+nextLine+llabel+lname+nextLine+slabel+sname+nextLine+nextLine+mlabel+media, preferredStyle: .alert)
                
                alert.addTextField(configurationHandler: {(textField) in
                    textField.placeholder = "Number of Guests"
                })
                
                alert.addAction(UIAlertAction(title: "Check-in", style: .default, handler:
                    {
                        (alertAction: UIAlertAction) in
                        //Code after Check-in is pressed
                        //Check if media waiver is not accepted and show alert as required
                        var guests:String=alert.textFields![0].text!
                        self.checkMediaWaiver(indicator: media, id:id, fname:fname, lname:lname, guests: guests)
                }))
                alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                
                self.present(alert, animated: true)
                
            }
            
        } catch let error as NSError {
            print ("Could not fetch data")
        }
    }
    
    //Function to check if media waiver has been accepted
    func checkMediaWaiver(indicator: String, id:String, fname: String, lname: String, guests: String)
    {
        //If media waiver is not accepted, display alert
        if indicator=="N"
        {
            var mediaAlert = UIAlertController(title:"Media Waiver not accepted", message:"The student is yet to accept the media waiver!", preferredStyle: .alert)
            
            
            //Make Check in call once accepted
            mediaAlert.addAction(UIAlertAction(title:"Accepted", style: .default, handler: {(alert:UIAlertAction) in
                self.checkInStudent(id: id, fname: fname, lname: lname, guests:guests)
            }))
            self.present(mediaAlert, animated: true)
        }
            //If media waiver is accepted, proceed with check-in
        else{
            self.checkInStudent(id: id, fname:fname, lname:lname, guests:guests)
        }
    }
    
    
    //Function to complete the check in
    func checkInStudent(id: String, fname: String, lname: String, guests:String)
    {
        var space=" "
        var successlabel="Successfully checked in "
        
        //Write to local data
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        let entity = NSEntityDescription.entity(forEntityName: "CheckedInStudent", in: managedContext)
        let checkedStudent = NSManagedObject(entity: entity!, insertInto: managedContext)
        
        checkedStudent.setValue(id, forKey: "id")
        checkedStudent.setValue("Y", forKey: "media")
        if(!guests.isEmpty){
            checkedStudent.setValue(guests, forKey: "guests")
        }
        do{
            try managedContext.save()
        }
        catch let error as NSError{
            print("Could not check-in student")
        }
        //Print final success message
        var successAlert=UIAlertController(title:"Success", message:successlabel+fname+space+lname , preferredStyle: .alert)
        successAlert.addAction(UIAlertAction(title:"OK", style: .default, handler:nil))
        self.present(successAlert, animated: true)
    }
    
    func searchBarIsEmpty() -> Bool {
        return searchController.searchBar.text?.isEmpty ?? true
    }
    
    func filterContentForSearchText(_ searchText: String, scope: String = "All") {
        filteredStudents = students.filter({( student: NSManagedObject) -> Bool in
            let fName = student.value(forKey: "firstName") as! String
            let lName = student.value(forKey: "lastName") as! String
            let id = student.value(forKey: "studentId") as! String
            let fullName = fName + " " + lName + " " + id
            return fullName.lowercased().contains(searchText.lowercased())
            
        })
        studentTableView.reloadData()
    }
    
    func isFiltering() -> Bool {
        return searchController.isActive && !searchBarIsEmpty()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

extension StudentTableViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFiltering() {
            return filteredStudents.count
        }
        return students.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let student: NSManagedObject
        let cell = studentTableView.dequeueReusableCell(withIdentifier: "custom", for: indexPath) as! StudentTableViewCell
        
        if isFiltering(){
            student = filteredStudents[indexPath.row]
        }
        else {
            student = students[indexPath.row]
        }
        cell.studentId!.text = student.value(forKey: "studentId") as? String
        cell.firstName!.text = student.value(forKey: "firstName") as? String
        cell.lastName!.text = student.value(forKey: "lastName") as? String
        //cell.school!.text = student.value(forKey: "school") as? String
        
        return cell
    }
}

extension StudentTableViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("CELL PRESSED")
        let selectedStudent = students[indexPath.row]
        showAlert(id: selectedStudent.value(forKey: "studentId") as! String)
    }
}

extension StudentTableViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)
    }
}



