//
//  gifViewController.swift
//  CheckIn
//
//  Created by Anand Kelkar on 16/05/18.
//  Copyright © 2018 Sam Walk. All rights reserved.
//

import Foundation
import CoreData
import UIKit
import AudioToolbox

class gifViewController : UIViewController {
    @IBOutlet weak var gifView: UIImageView!
    @IBOutlet var mainView: UIView!
    
    override func viewWillAppear(_ animated: Bool) {
        super .viewWillAppear(animated)
        mainView.backgroundColor=UIColor.black
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "hidePageControl"), object: nil)
        gifView.image=UIImage.gifImageWithName("lj")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
            self.navigationController?.setNavigationBarHidden(false, animated: true)
            self.navigationController?.popToRootViewController(animated: false)
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "unhidePageControl"), object: nil)
        }
    }
    
}
