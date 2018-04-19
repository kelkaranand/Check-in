//
//  EventDetailViewController.swift
//  CheckIn
//
//  Created by Anand Kelkar on 18/04/18.
//  Copyright © 2018 Sam Walk. All rights reserved.
//

import Foundation
import UIKit

class EventDetailViewController : UIViewController {
    @IBOutlet weak var DataView: UIView!
    @IBOutlet weak var EventNameLabel: UILabel!
    @IBOutlet weak var LineView: UIView!
    @IBOutlet weak var StudentRecordsLabel: UILabel!
    @IBOutlet weak var GuestsCheckedLabel: UILabel!
    @IBOutlet weak var FilterLabel: UILabel!
    
    @IBOutlet weak var CheckInView: UIView!
    @IBOutlet weak var CheckInNumber: UILabel!
    @IBOutlet weak var CheckInText: UILabel!
    
    @IBOutlet weak var VipView: UIView!
    @IBOutlet weak var VipNumber: UILabel!
    @IBOutlet weak var VipText: UILabel!
    
    
    var checkInList : [String] = []
    var vipList : [String] = []
    
    var EventName:String=""
    var guests:Int=0
    var studentRecords:String="StudentRecords"
    
    var filterStatus:Bool = false
    var filterType:Int = 0
    var FilterString:String = "message"
    
    /*
     1-CheckInList
     2-VipList
     */
    var click:Int?
    
    
    @objc func checkInClickAction(_ : UITapGestureRecognizer){
        self.click=1
        self.performSegue(withIdentifier: "showList", sender: self)
    }
    
    @objc func vipClickAction(_ : UITapGestureRecognizer){
        self.click=2
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
            else{
                view.image=UIImage(named:"vip")
                view.data=self.vipList
            }
        }
    }
    
    func formatViews(view: UIView, header: UILabel, message: UILabel, x: String, y: String)
    {
        header.text=x
        message.text=y
        
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 1
        view.layer.shadowOffset = CGSize.zero
        view.layer.shadowRadius = 10
        view.layer.shadowPath = UIBezierPath(rect: view.bounds).cgPath
        
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
        
        message.font = UIFont(name: "HelveticaNeue-Bold", size: 200)
        message.numberOfLines = 0
        message.minimumScaleFactor = 0.01
        message.baselineAdjustment = .alignCenters
        message.textAlignment  = .center
        message.adjustsFontSizeToFitWidth=true
        message.textColor = UIColor(red:253,green:201,blue:16)
        
    }
    
    func formatDataText(message: UILabel)
    {
        message.font = UIFont(name: "HelveticaNeue-Bold", size: 200)
        message.numberOfLines = 0
        message.minimumScaleFactor = 0.01
        message.baselineAdjustment = .alignCenters
        message.textAlignment  = .center
        message.adjustsFontSizeToFitWidth=true
        message.textColor = UIColor(red:253,green:201,blue:16)
    }
    
    func populateDataView()
    {
        DataView.layer.borderColor=UIColor.black.cgColor
        DataView.layer.borderWidth=1
        DataView.layer.backgroundColor=UIColor.white.cgColor
        DataView.layer.shouldRasterize = false
        DataView.layer.cornerRadius = 10
        
        EventNameLabel.text=self.EventName
        StudentRecordsLabel.text=self.studentRecords+" student profiles on this device"
        GuestsCheckedLabel.text=(String)(self.guests)+" guests checked in on this device"
        if filterStatus
        {
            if filterType == 1
            {
                FilterLabel.text=FilterString
            }
            else if filterType == 2
            {
                FilterLabel.text=FilterString
            }
        }
        else {
            FilterLabel.text="No filters active"
        }
        
        formatDataText(message: EventNameLabel)
        formatDataText(message: StudentRecordsLabel)
        formatDataText(message: GuestsCheckedLabel)
        formatDataText(message: FilterLabel)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        //Disable swipe
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "clearSwipeList"), object: nil)
        
        //Hide page control
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "hidePageControl"), object: nil)
        
        LineView.backgroundColor=UIColor(red:3,green:129,blue:0)
        
        populateDataView()
        
        formatViews(view: CheckInView, header: CheckInNumber, message: CheckInText, x: (String)(checkInList.count), y: "Student check-ins")
        
        formatViews(view: VipView, header: VipNumber, message: VipText, x: (String)(vipList.count), y: "VIP check-ins")
        
        let checkInClick = UITapGestureRecognizer(target: self, action: #selector(checkInClickAction(_:)))
        self.CheckInView.addGestureRecognizer(checkInClick)
        
        let vipClick = UITapGestureRecognizer(target: self, action: #selector(vipClickAction(_:)))
        self.VipView.addGestureRecognizer(vipClick)
        
        
        
        
    }
    
}
