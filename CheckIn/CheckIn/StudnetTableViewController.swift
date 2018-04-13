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
    @IBOutlet weak var checkMark: UIImageView!
    @IBOutlet weak var lastName: UILabel!
    @IBOutlet weak var firstName: UILabel!
    var studentId=""
    
}

class StudentTableViewController: UIViewController {

    @IBOutlet weak var studentTableView: UITableView!
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    var students: [NSManagedObject] = []
    var filteredStudents: [NSManagedObject] = []
    let searchController = UISearchController(searchResultsController: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Unhide page control
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "unhidePageControl"), object: nil)
        
        // TextField Color Customization
        let textFieldInsideSearchBar = searchController.searchBar.value(forKey: "searchField") as? UITextField
        textFieldInsideSearchBar?.textColor = UIColor.white
        
        
        //Sets the cancel button text color
        let cancelButtonAttributes: NSDictionary = [NSAttributedStringKey.foregroundColor: UIColor(red:253,green:201,blue:16)]
        UIBarButtonItem.appearance().setTitleTextAttributes(cancelButtonAttributes as? [NSAttributedStringKey:Any], for: UIControlState.normal)
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(reloadTable), name: NSNotification.Name(rawValue: "reload"), object: nil)
        
        // Setup search controller
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Students"
        navigationItem.searchController = searchController
        definesPresentationContext = true
        
        studentTableView.dataSource = self
        studentTableView.delegate = self
        studentTableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //Unhide page control
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "unhidePageControl"), object: nil)
        
        //Enable swipe
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "createSwipeList"), object: nil)
        
        self.navigationController?.navigationBar.barTintColor=UIColor(red:2,green:86,blue:0)
        self.navigationController?.navigationBar.tintColor=UIColor(red:253,green:201,blue:16)
        
        //Sets text color for text in the search bar
        UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self]).defaultTextAttributes = [NSAttributedStringKey.foregroundColor.rawValue: UIColor.white]
        
        loadTableData()
    }
    
    @objc func reloadTable(){
        loadTableData()
        print("here")
        self.studentTableView.reloadData()
    }
    
    func loadTableData(){
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Student")
        
        do {
            students = try managedContext.fetch(fetchRequest)
        } catch _ as NSError {
            print ("Could not fetch data")
        }
        appDelegate.saveContext()
        do {
            try managedContext.save()
        } catch _ as NSError {
            print ("Could not save data")
        }
    }
    
    var gid:String=""
    var gfname:String=""
    var glname:String=""
    var gsname:String=""
    var gmedia:String=""
    var gvip:String=""
    var gpicture:UIImage=UIImage(named:"default")!
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if let profile = segue.destination as? ProfileViewController
        {
            profile.id=gid
            profile.fname=gfname
            profile.lname=glname
            profile.sname=gsname
            profile.media=gmedia
            profile.spicture=gpicture
            profile.vip=gvip
            profile.method=2;
        }
    }
    
    func showProfile(id:String) {
        
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
            
            //Fields and labels
            let studentRecord=student.first
            self.gfname=studentRecord?.value(forKey:"firstName") as! String
            self.glname=studentRecord?.value(forKey:"lastName") as! String
            self.gsname=studentRecord?.value(forKey:"school") as! String
            self.gmedia=studentRecord?.value(forKey:"media") as! String
            self.gid=studentRecord?.value(forKey:"studentId") as! String
            self.gvip=studentRecord?.value(forKey: "vip") as! String
            
            if(UIImage(named:self.gid) != nil)
            {
                self.gpicture=UIImage(named:self.gid)!
            }
            else{
                self.gpicture=UIImage(named:"default")!
            }
                
            self.performSegue(withIdentifier: "tableToProfile", sender: self)
            
        }catch _ as NSError {
            print ("Could not fetch data")
        }
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
            let apostropheChar : Character = "\u{27}"
            let rightApostropheChar : Character = "\u{2019}"
            let replacedSearchText : String = searchText.replacingOccurrences(of: String(rightApostropheChar), with: String(apostropheChar))
            return fullName.lowercased().contains(replacedSearchText.lowercased())
            
        })
        studentTableView.reloadData()
    }
    
    func isFiltering() -> Bool {
        return searchController.isActive && !searchBarIsEmpty()
    }
    
    //Function to check if student has already checkedIn
    func checkForCheckIn(id:String) -> Bool
    {
        var checkIn : [NSManagedObject]
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return false
        }
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "CheckedInStudent")
        fetchRequest.predicate = NSPredicate(format: "id == %@", id)
        do {
            checkIn = try managedContext.fetch(fetchRequest)
            
            if(!checkIn.isEmpty)
            {
                return true
            }
        }
        catch _ as NSError {
            print ("Error when checking if already checked in")
            return false
        }
        return false
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
        cell.studentId = (student.value(forKey: "studentId") as? String)!
        cell.firstName!.text = student.value(forKey: "firstName") as? String
        cell.lastName!.text = student.value(forKey: "lastName") as? String
        
//        cell.studentId.numberOfLines=0;
//        cell.studentId.font = UIFont(name: "HelveticaNeue", size: 20)
//        cell.studentId.minimumScaleFactor = 0.1
//        cell.studentId.adjustsFontSizeToFitWidth=true
//        cell.studentId.textColor=UIColor(red:3,green:129,blue:0)
        
        if(student.value(forKey: "checkedIn") as! Bool)
        {
            cell.checkMark.image=UIImage(named:"checkmark")
        }
        else{
            cell.checkMark.image=nil
        }
        
        cell.firstName.numberOfLines=0;
        cell.firstName.font = UIFont(name: "HelveticaNeue", size: 20)
        cell.firstName.minimumScaleFactor = 0.1
        cell.firstName.adjustsFontSizeToFitWidth=true
        cell.firstName.textColor = UIColor(red:253,green:201,blue:16)
        
        cell.lastName.numberOfLines=0;
        cell.lastName.font = UIFont(name: "HelveticaNeue", size: 20)
        cell.lastName.minimumScaleFactor = 0.1
        cell.lastName.adjustsFontSizeToFitWidth=true
        cell.lastName.textColor = UIColor(red:253,green:201,blue:16)
        
        return cell
    }
}

extension StudentTableViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("CELL PRESSED")
        let selectedCell = tableView.cellForRow(at: indexPath) as! StudentTableViewCell
//        showAlert(id: selectedStudent.value(forKey: "studentId") as! String)
        showProfile(id: selectedCell.studentId )
    }
}

extension StudentTableViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)
    }
}


extension UIColor {
    convenience init(red: Int, green: Int, blue: Int) {
        let newRed = CGFloat(red)/255
        let newGreen = CGFloat(green)/255
        let newBlue = CGFloat(blue)/255
        
        self.init(red: newRed, green: newGreen, blue: newBlue, alpha: 1.0)
    }
}



