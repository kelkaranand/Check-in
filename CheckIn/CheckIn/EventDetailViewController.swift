//
//  EventDetailViewController.swift
//  CheckIn
//
//  Created by Anand Kelkar on 18/04/18.
//  Copyright © 2018 Sam Walk. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class EventDetailViewController : UIViewController {
    
    @IBOutlet weak var EventNameLabel: UILabel!
    
    @IBOutlet weak var StudentRecordsView: UIView!
    @IBOutlet weak var StudentRecordsHeader: UILabel!
    @IBOutlet weak var StudentRecordsNumber: UILabel!
    
    @IBOutlet weak var AnalyticsView: UIView!
    @IBOutlet weak var AnalyticsHeader: UILabel!
    @IBOutlet weak var AnalyticsPercentage: UILabel!
    
    
    @IBOutlet weak var CheckInView: UIView!
    @IBOutlet weak var CheckInNumber: UILabel!
    @IBOutlet weak var CheckInText: UILabel!
    
    @IBOutlet weak var GuestsView: UIView!
    @IBOutlet weak var GuestsHeader: UILabel!
    @IBOutlet weak var GuestsNumber: UILabel!
    
    
    
    var checkInList : [String] = []
    var vipList : [String] = []
    
    var EventName:String=""
    var guests:Int=0
    var studentRecords:String="StudentRecords"
    
    var qrCheckIns:Int=0
    var manCheckIns:Int=0
    var perc:Double=0
    
    /*
     1-CheckInList
     */
    var click:Int?
    
    
    @objc func checkInClickAction(_ : UITapGestureRecognizer){
        self.click=1
        self.performSegue(withIdentifier: "showList", sender: self)
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if let view = segue.destination as? CheckInListViewController
        {
            if self.click==1
            {
                view.image=UIImage(named:"checkmark")
                view.data=self.checkInList
            }
        }
    }
    
    func formatViews(view: UIView, header: UILabel, message: UILabel, x: String, y: String, shadow: Bool)
    {
        header.text=x
        message.text=y
        
        if shadow {
            view.layer.shadowColor = UIColor.black.cgColor
            view.layer.shadowOpacity = 1
            view.layer.shadowOffset = CGSize.zero
            view.layer.shadowRadius = 10
            view.layer.shadowPath = UIBezierPath(rect: view.bounds).cgPath
        }
        
        view.layer.borderColor=UIColor.black.cgColor
        view.layer.borderWidth=1
        if shadow {
                view.layer.backgroundColor=ColorSettings.lineColor.cgColor
        }
        else{
            view.layer.backgroundColor=UIColor.white.cgColor
        }
        view.layer.shouldRasterize = false
        view.layer.cornerRadius = 10
        
        header.font = UIFont(name: "HelveticaNeue-Bold", size: 600)
        header.numberOfLines = 0
        header.minimumScaleFactor = 0.01
        header.baselineAdjustment = .alignCenters
        header.textAlignment  = .center
        header.adjustsFontSizeToFitWidth=true
        if shadow {
            header.textColor = ColorSettings.navTextColor
        }
        else {
            header.textColor = ColorSettings.textColor
        }
        
        message.font = UIFont(name: "HelveticaNeue-Bold", size: 100)
        message.numberOfLines = 0
        message.minimumScaleFactor = 0.01
        message.baselineAdjustment = .alignCenters
        message.textAlignment  = .center
        message.adjustsFontSizeToFitWidth=true
        if shadow {
            message.textColor = ColorSettings.navTextColor
        }
        else {
            message.textColor = ColorSettings.textColor
        }
    }
    
    func formatDataText(message: UILabel)
    {
        message.font = UIFont(name: "HelveticaNeue-Bold", size: 200)
        message.numberOfLines = 0
        message.minimumScaleFactor = 0.01
        message.baselineAdjustment = .alignCenters
        message.textAlignment  = .center
        message.adjustsFontSizeToFitWidth=true
        message.textColor = ColorSettings.textColor
    }
    
    func checkInAnalytics()
    {
        var count:Int=0
        guard let appDelegate = UIApplication.shared.delegate as?AppDelegate else {
            return
        }
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "CheckedInStudent")
        do{
            let temp = try managedContext.fetch(fetchRequest)
            for entry in temp{
                count=count+1
                if entry.value(forKey: "method") as! Int == 1{
                    qrCheckIns=qrCheckIns+1
                }
                else{
                    manCheckIns=manCheckIns+1
                }
            }
        }
        catch _ as NSError {
            print("Error getting check-in analytics")
        }
        perc=Double(round(10*(((Double)(qrCheckIns))/(Double)(count)*100))/10)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        //Disable swipe
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "clearSwipeList"), object: nil)
        
        //Hide page control
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "hidePageControl"), object: nil)
        
        checkInAnalytics()
        
        EventNameLabel.text=self.EventName
        formatDataText(message: EventNameLabel)
        
        formatViews(view: StudentRecordsView, header: StudentRecordsNumber, message: StudentRecordsHeader, x: studentRecords, y: "Student Records", shadow: false)
        
        formatViews(view: AnalyticsView, header: AnalyticsPercentage, message: AnalyticsHeader, x: (String)(perc), y: "QR scan %", shadow: false)
        
        formatViews(view: CheckInView, header: CheckInNumber, message: CheckInText, x: (String)(checkInList.count), y: "Student check-ins",shadow: true)
        
        formatViews(view: GuestsView, header: GuestsNumber, message: GuestsHeader, x: (String)(guests), y: "Guests", shadow: false)
        
        let checkInClick = UITapGestureRecognizer(target: self, action: #selector(checkInClickAction(_:)))
        self.CheckInView.addGestureRecognizer(checkInClick)
        
    }
    
}
