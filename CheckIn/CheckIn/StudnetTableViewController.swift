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
        
        
//        let textFieldInsideSearchBar = searchBar.value(forKey: "text") as? UITextField
//        textFieldInsideSearchBar?.textColor = UIColor.white
        
        //searchController.searchBar.barTintColor=UIColor.white
        //searchController.searchBar.tintColor=UIColor.white
        //searchController.searchBar.keyboardAppearance
//        UITextField.appearance().defaultTextAttributes = [NSAttributedStringKey.foregroundColor.rawValue: UIColor.white]
        
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
        
//        title = "Check In"
        studentTableView.dataSource = self
        studentTableView.delegate = self
        studentTableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
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
    
    
    
    //Experimental code
    
//    func getDirectoryPath() -> String {
//        let path = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString).appendingPathComponent("customDirectory")
//        let documentsDirectory = path
//        return documentsDirectory
//    }
//
//    func getImage(id: String) -> UIImage{
//        let fileManager = FileManager.default
//        let imagePAth = (self.getDirectoryPath() as NSString).appendingPathComponent(id+".jpg")
//        if fileManager.fileExists(atPath: imagePAth){
//            //            self.imageView.image = UIImage(contentsOfFile: imagePAth)
//            return UIImage(contentsOfFile: imagePAth)!
//        }else{
//            print("No Image")
//        }
//        print("Default image")
//        return UIImage(named:"default")!
//    }
    
    
    //End Experimental code
    
    
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
            
            
                
//                let foundAlert = UIAlertController(title:"Success", message:"Student record found.", preferredStyle: .alert)
//                foundAlert.addAction(UIAlertAction(title:"Continue", style: .default, handler:
//                    {
//                        (alertAction: UIAlertAction) in
                        
                        //Fields and labels
                        let studentRecord=student.first
                        self.gfname=studentRecord?.value(forKey:"firstName") as! String
                        self.glname=studentRecord?.value(forKey:"lastName") as! String
                        self.gsname=studentRecord?.value(forKey:"school") as! String
                        self.gmedia=studentRecord?.value(forKey:"media") as! String
                        self.gid=studentRecord?.value(forKey:"studentId") as! String
                        self.gvip=studentRecord?.value(forKey: "vip") as! String
                        
                        //Retrieve image from directory
//                        self.gpicture = self.getImage(id: id)
                        if(UIImage(named:self.gid) != nil)
                        {
                            self.gpicture=UIImage(named:self.gid)!
                        }
                        else{
                            self.gpicture=UIImage(named:"default")!
                        }
                
                        self.performSegue(withIdentifier: "tableToProfile", sender: self)
                        
//                }
//                ))
//                self.present(foundAlert, animated:true)
            
        }catch _ as NSError {
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
                let invalidQrAlert = UIAlertController(title:"No record found", message:"No record was found for the scanned code. Try using the manual search", preferredStyle: .alert)
                invalidQrAlert.addAction(UIAlertAction(title:"OK", style: .cancel, handler:nil))
                self.present(invalidQrAlert, animated:true)
            }
            else{
                //Fields and labels
                let studentRecord=student.first
                let fname=studentRecord?.value(forKey:"firstName") as! String
                let lname=studentRecord?.value(forKey:"lastName") as! String
                let sname=studentRecord?.value(forKey:"school") as! String
                let media=studentRecord?.value(forKey:"media") as! String
                let id=studentRecord?.value(forKey:"studentId") as! String
                let flabel="First Name: "
                let llabel="Last Name: "
                let ilabel="APS ID: "
                let mlabel="Media Waiver: "
                let slabel="School Name: "
                let nextLine="\n"
                
                //Create alert on screen
                let alert = UIAlertController(title: "Record Found", message: nextLine+ilabel+id+nextLine+flabel+fname+nextLine+llabel+lname+nextLine+slabel+sname+nextLine+nextLine+mlabel+media, preferredStyle: .alert)
                
//                let profilePicture = UIAlertAction(title: "", style: .default, handler: nil)
//                profilePicture.setValue(self.getImage(id: id).withRenderingMode(UIImageRenderingMode.alwaysOriginal), forKey: "image")
//                alert.addAction(profilePicture)
                
                alert.addTextField(configurationHandler: {(textField) in
                    textField.placeholder = "Number of Guests"
                })
                
                alert.addAction(UIAlertAction(title: "Check-in", style: .default, handler:
                    {
                        (alertAction: UIAlertAction) in
                        //Code after Check-in is pressed
                        //Check if media waiver is not accepted and show alert as required
                        var guests:String=alert.textFields![0].text!
                        if(guests.isEmpty)
                        {
                            guests="0"
                        }
                        self.checkMediaWaiver(indicator: media, id:id, fname:fname, lname:lname, guests: guests)
                }))
                alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                
                self.present(alert, animated: true)
                
            }
            
        } catch _ as NSError {
            print ("Could not fetch data")
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
        checkedStudent.setValue("Y", forKey: "media")
        if(!guests.isEmpty){
            checkedStudent.setValue(guests, forKey: "guests")
        }
        do{
            try managedContext.save()
        }
        catch _ as NSError{
            print("Could not check-in student")
        }
        //Print final success message
        let successAlert=UIAlertController(title:"Success", message:successlabel+fname+space+lname , preferredStyle: .alert)
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
        
        return cell
    }
}

extension StudentTableViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("CELL PRESSED")
        let selectedCell = tableView.cellForRow(at: indexPath) as! StudentTableViewCell
//        showAlert(id: selectedStudent.value(forKey: "studentId") as! String)
        showProfile(id: selectedCell.studentId.text as! String)
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



