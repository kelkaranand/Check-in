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
import Firebase

class StudentTableViewCell: UITableViewCell {
    @IBOutlet weak var studentId: UILabel!
    @IBOutlet weak var firstName: UILabel!
    @IBOutlet weak var lastName: UILabel!
    @IBOutlet weak var school: UILabel!
    
}

class StudentTableViewController: UIViewController {

    @IBOutlet weak var studentTableView: UITableView!
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    var students: [NSManagedObject] = []
    var filteredStudents: [NSManagedObject] = []
    let searchController = UISearchController(searchResultsController: nil)
    
    var ref: DatabaseReference!
    //var students=[student]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        clearCoreData()
        loadStudentsFromFirebase()
        
        // Setup search controller
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Students"
        navigationItem.searchController = searchController
        definesPresentationContext = true
        
        title = "Check In"
        studentTableView.dataSource = self
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
    
    func loadStudentsFromFirebase() {
        ref=Database.database().reference(withPath: "students")
        
        ref.observeSingleEvent(of:.value, with: { snapshot in
            
            for data in snapshot.children {
                var studentData = data as! DataSnapshot
                var fields = studentData.value as? [String:AnyObject]
                var fname=fields!["fname"] as! String
                var lname=fields!["lname"] as! String
                var media=fields!["media"] as! String
                var id=fields!["id"] as! String
                var studentRecord = student(fname: fname, lname: lname, media: media, id: id)
                //self.students.append(studentRecord)
                self.save(studentId: id, firstName: fname, lastName: lname, school: "school")
                
                print(fname)
            }
            self.studentTableView.reloadData()
        })
    }
    
    func save(studentId: String, firstName: String, lastName: String, school: String) {
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        let entity = NSEntityDescription.entity(forEntityName: "Student", in: managedContext)
        let student = NSManagedObject(entity: entity!, insertInto: managedContext)
        
        student.setValue(studentId, forKeyPath: "studentId")
        student.setValue(firstName, forKeyPath: "firstName")
        student.setValue(lastName, forKeyPath: "lastName")
        student.setValue(school, forKeyPath: "school")
        
        do {
            try managedContext.save()
            students.append(student)
        } catch let error as NSError {
            print("Could not save")
        }
    }
    
    func clearCoreData() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else{
            return
        }
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Student")
        
        do {
            let results = try managedContext.fetch(fetchRequest as! NSFetchRequest<NSFetchRequestResult>)
            for managedObject in results {
                let managedObjectData:NSManagedObject = managedObject as! NSManagedObject
                managedContext.delete(managedObjectData)
            }
        } catch let error as NSError {
            print(error)
        }
    }
    
    func checkInStudent(studentId: String, numGuests: String, media: String){
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        let entity = NSEntityDescription.entity(forEntityName: "CheckedInStudent", in: managedContext)
        let student = NSManagedObject(entity: entity!, insertInto: managedContext)
        
        student.setValue(studentId, forKeyPath: "id")
        student.setValue(numGuests, forKeyPath: "guests")
        student.setValue(media, forKeyPath: "media")
        
        do {
            try managedContext.save()
            students.append(student)
        } catch let error as NSError {
            print("Could not save")
        }
        
    }
    
    func searchBarIsEmpty() -> Bool {
        return searchController.searchBar.text?.isEmpty ?? true
    }
    
    func filterContentForSearchText(_ searchText: String, scope: String = "All") {
        filteredStudents = students.filter({( student: NSManagedObject) -> Bool in
            let fName = student.value(forKey: "firstName") as! String
            let lName = student.value(forKey: "lastName") as! String
            let fullName = fName + " " + lName
            return fullName.lowercased().contains(searchText.lowercased())
            
        })
        studentTableView.reloadData()
    }
    
    func isFiltering() -> Bool {
        return searchController.isActive && !searchBarIsEmpty()
    }
    
    @IBAction func unwindToStudentList(sender: UIStoryboardSegue){
        if let sourceViewController = sender.source as? StudentDetailsViewController, let guests = sourceViewController.guests as? String, let id = sourceViewController.id as? String, let media = sourceViewController.media as? String {
            checkInStudent(studentId: id, numGuests: guests, media: media)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
        super.prepare(for: segue, sender: sender)
        
        guard let studentDetailViewController = segue.destination as? StudentDetailsViewController else {
            fatalError()
        }
        
        guard let selectedStudentCell = sender as? StudentTableViewCell else {
            fatalError()
        }
        
        guard let indexPath = studentTableView.indexPath(for: selectedStudentCell) else {
            fatalError()
        }
        
        let selectedStudent = students[indexPath.row]
        studentDetailViewController.setStudent(student: selectedStudent)
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
        cell.school!.text = student.value(forKey: "school") as? String
        
        return cell

    }
}

extension StudentTableViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)
    }
}



