//
//  SetFilterViewController.swift
//  CheckIn
//
//  Created by Anand Kelkar on 13/04/18.
//  Copyright © 2018 Sam Walk. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class SetFilterViewController : UIViewController, UIPickerViewDataSource, UIPickerViewDelegate
{
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView.tag == 1{
            return self.schoolList.count
        }
        else {
            return self.alphabets.count
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView.tag == 1 {
        return self.schoolList[row]
        }
        else {
            return self.alphabets[row]
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView.tag == 1 || pickerView.tag == 2
        {
            if SchoolFilterStatus.isOn {
                self.toggleFilterStatus(on: SchoolFilterStatus.isOn, type: 1, school: self.schoolList[SchoolPicker.selectedRow(inComponent: 0)], from: nil, to: nil)
                self.checkFilterStatus()
            }
            else {
                self.toggleFilterStatus(on: false, type: 2, school: nil, from: nil, to: nil)
                checkFilterStatus()
            }
        }
    }
    
    
    
    @IBOutlet weak var SchoolFilterView: UIView!
    @IBOutlet weak var SchoolFilterHeader: UILabel!
    @IBOutlet weak var SchoolFilterStatus: UISwitch!
    @IBAction func SchoolFilterToggle(_ sender: UISwitch) {
        self.toggleFilterStatus(on: SchoolFilterStatus.isOn, type: 1, school: self.schoolList[SchoolPicker.selectedRow(inComponent: 0)], from: nil, to: nil)
        self.checkFilterStatus()
    }
    
    @IBOutlet weak var SchoolPicker: UIPickerView!
    
    
    @IBOutlet weak var AlphabetFilterView: UIView!
    @IBOutlet weak var AlphabetPickerView: UIView!
    @IBOutlet weak var AlphabetFilterHeader: UILabel!
    @IBOutlet weak var AlphabetFilterStatus: UISwitch!
    @IBAction func AlphabetFilterToggle(_ sender: UISwitch) {
        let from = AlphabetPicker.selectedRow(inComponent: 0)
        let to = AlphabetPicker2.selectedRow(inComponent: 0)
        if from<=to
        {
            self.toggleFilterStatus(on: AlphabetFilterStatus.isOn, type: 2, school: nil, from: self.alphabets[from], to: self.alphabets[to])
            self.checkFilterStatus()
        }
        else{
            let checkFilterAlert = UIAlertController(title:"Error", message:"Please check the alphabets selected", preferredStyle: .alert)
            checkFilterAlert.addAction(UIAlertAction(title:"OK", style: .cancel, handler: nil))
            self.present(checkFilterAlert, animated:true)
        }
    }
    @IBOutlet weak var AlphabetPicker: UIPickerView!
    @IBOutlet weak var AlphabetPicker2: UIPickerView!
    
    
    
    
    
    
    var schoolList:[String]=[]
    let alphabets:[String]=["A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z"]
    
    //Formats the main views
    func formatView(view: UIView, header: UILabel){
        view.layer.borderColor=UIColor.black.cgColor
        view.layer.borderWidth=1
        view.layer.backgroundColor=UIColor.white.cgColor
        view.layer.shouldRasterize = false
        view.layer.cornerRadius = 10
        
        header.font = UIFont(name: "HelveticaNeue-Bold", size: 600)
        header.numberOfLines = 0
        header.minimumScaleFactor = 0.01
        header.baselineAdjustment = .alignCenters
        header.textAlignment  = .center
        header.adjustsFontSizeToFitWidth=true
        header.textColor = UIColor(red:253,green:201,blue:16)
    }
    override func viewDidLoad() {
        super .viewDidLoad()
        SchoolPicker.dataSource=self
        SchoolPicker.delegate=self
        SchoolPicker.autoresizesSubviews=true
        AlphabetPicker.dataSource=self
        AlphabetPicker.delegate=self
        AlphabetPicker.autoresizesSubviews=true
        AlphabetPicker2.dataSource=self
        AlphabetPicker2.delegate=self
        AlphabetPicker2.autoresizesSubviews=true
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        formatView(view: SchoolFilterView, header: SchoolFilterHeader)
        SchoolFilterHeader.text="Filter by school"
        
        formatView(view: AlphabetFilterView, header: AlphabetFilterHeader)
        AlphabetFilterHeader.text="Filter by alphabet"
        
        SchoolPicker.tag=1
        AlphabetPicker.tag=2
        AlphabetPicker2.tag=3
        
        
        
        self.checkFilterStatus()
    }
    
    //Sets the toggle display
    func checkFilterStatus()
    {
        print("Setting toggles on screen")
        guard let appDelegate = UIApplication.shared.delegate as?AppDelegate else {
            return
        }
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Filter")
        do{
            let temp = try managedContext.fetch(fetchRequest).first?.value(forKey: "killSwitch") as? Bool
            if(!(temp==nil) && temp!)
            {
                print("Found")
                let type = try managedContext.fetch(fetchRequest).first?.value(forKey: "type") as! Int
                
                if type == 1
                {
                    SchoolFilterStatus.isOn=true
                    AlphabetFilterStatus.isOn=false
                    let filteredSchoolName = try managedContext.fetch(fetchRequest).first?.value(forKey: "school") as! String
                    SchoolPicker.selectRow(self.getFilteredSchool(x: filteredSchoolName)!, inComponent: 0, animated: true)
                }
                else if type == 2
                {
                    AlphabetFilterStatus.isOn=true
                    SchoolFilterStatus.isOn=false
                    let fromAlphabet = try managedContext.fetch(fetchRequest).first?.value(forKey: "from") as! String
                    let toAlphabet = try managedContext.fetch(fetchRequest).first?.value(forKey: "to") as! String
                    AlphabetPicker.selectRow(self.getAlphabetIndex(x: fromAlphabet)!, inComponent: 0, animated: true)
                    AlphabetPicker2.selectRow(self.getAlphabetIndex(x: toAlphabet)!, inComponent: 0, animated: true)
                }
            }
            else{
                SchoolFilterStatus.isOn=false
                AlphabetFilterStatus.isOn=false
            }
        }
        catch _ as NSError {
            print("Error getting filter status")
        }
    }
    
    //Sets the new toggle and makes changes to the filter object in core data
    func toggleFilterStatus(on: Bool, type: Int, school: String?, from: String?, to: String?)
    {
        guard let appDelegate = UIApplication.shared.delegate as?AppDelegate else {
            return
        }
        let managedContext = appDelegate.persistentContainer.viewContext
        //Get filter
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Filter")
        do{
            let temp = try managedContext.fetch(fetchRequest).first
            if(!(temp==nil))
            {
                temp?.setValue(on, forKey: "killSwitch")
                temp?.setValue(type, forKey: "type")
                if type == 1
                {
                    temp?.setValue(school, forKey: "school")
                }
                else if type == 2 {
                    temp?.setValue(from, forKey: "from")
                    temp?.setValue(to, forKey: "to")
                }
                try managedContext.save()
            }
            else{
                let entity = NSEntityDescription.entity(forEntityName: "Filter", in: managedContext)
                let filter = NSManagedObject(entity: entity!, insertInto: managedContext)
                filter.setValue(on, forKey: "killSwitch")
                filter.setValue(type, forKey: "type")
                if type == 1{
                    filter.setValue(school, forKey: "school")
                }
                else if type == 2 {
                    filter.setValue(from, forKey: "from")
                    filter.setValue(to, forKey: "to")
                }
                try managedContext.save()
            }
        }
        catch _ as NSError {
            print("Error changing filter status")
        }
    }
    
    
    func getFilteredSchool(x: String) -> Int?
    {
        guard let appDelegate = UIApplication.shared.delegate as?AppDelegate else {
            return nil
        }
        let managedContext = appDelegate.persistentContainer.viewContext
        //Get school list
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "School")
        var counter=0
        do{
            let schools = try managedContext.fetch(fetchRequest)
            for entry in schools
            {
                counter=counter+1
                if (entry.value(forKey: "name") as! String) == x
                {
                    return (counter-1)
                }
            }
        }
        catch _ as NSError{
            print("Error checking for filtered school")
            return nil
        }
        return nil
    }
    
    func getAlphabetIndex(x: String) -> Int? {
        var counter=0
        for value in alphabets {
            if x == value {
                return counter
            }
            else {
                counter=counter+1
            }
        }
        return nil
    }
    
    
}
