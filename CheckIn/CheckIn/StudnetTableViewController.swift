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
    @IBOutlet weak var school: UILabel!
    
}

class StudentTableViewController: UIViewController {

    @IBOutlet weak var studentTableView: UITableView!
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    var students: [NSManagedObject] = []
    var filteredStudents: [NSManagedObject] = []
    let searchController = UISearchController(searchResultsController: nil)
    
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
    
    //REMOVE WHEN WE HAVE ACTUAL DATA PULL FROM GOOGLE SHEETS!!!!!!
    @IBAction func addStudent(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "New Student", message: "Add a student", preferredStyle: .alert)
        
        let saveAction = UIAlertAction(title: "Save", style: .default) {
            [unowned self] action in
            
            guard let textField = alert.textFields?[0],
                let studentId = textField.text else {
                    return
            }
            guard let textField2 = alert.textFields?[1],
                let firstName = textField2.text else {
                    return
            }
            guard let textField3 = alert.textFields?[2],
                let lastName = textField3.text else {
                    return
            }
            guard let textField4 = alert.textFields?[3],
                let school = textField4.text else {
                    return
            }
            
            self.save(studentId: studentId, firstName: firstName, lastName: lastName, school: school)
            self.studentTableView.reloadData()
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .default)
        
        alert.addTextField{ (textField) in
            textField.text = " "
        }
        alert.addTextField{ (textField2) in
            textField2.text = " "
        }
        alert.addTextField{ (textField3) in
            textField3.text = " "
        }
        alert.addTextField{ (textField4) in
            textField4.text = " "
        }
        
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true)
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
    
    func checkInStudent(studentId: String, numGuests: Int16){
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        
        var filteredStudent: [NSManagedObject] = []
        filteredStudent = students.filter({( student: NSManagedObject) -> Bool in
            let id = student.value(forKey: "studentId") as! String
            return id.elementsEqual(studentId)
        })
        
        filteredStudent.first?.setValue(numGuests, forKey: "numGuests")
        filteredStudent.first?.setValue(true, forKey: "checkedIn")
        
        do {
            try managedContext.save()
        } catch let error as NSError {
            print("error")
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
        if let sourceViewController = sender.source as? StudentDetailsViewController, let numGuestsInt = sourceViewController.numGuestsInt as? Int16, let studentIdString = sourceViewController.studentIdString as? String {
            checkInStudent(studentId: studentIdString, numGuests: numGuestsInt)
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



