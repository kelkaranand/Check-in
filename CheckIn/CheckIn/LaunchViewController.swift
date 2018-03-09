//
//  LaunchViewController.swift
//  CheckIn
//
//  Created by Anand Kelkar on 08/03/18.
//  Copyright © 2018 Sam Walk. All rights reserved.
//

import Foundation
import UIKit

class LaunchViewController :UIViewController
{
    @IBOutlet weak var animatedView: UIView!
    
    override func viewDidLoad() {
        generateLogo()
    }
    
    func generateLogo()
    {
        let imagelayer=CALayer()
        imagelayer.frame=animatedView.bounds
        let image = UIImage(named: "LJFF-logo")!
        imagelayer.contents = image.cgImage
        imagelayer.contentsGravity = kCAGravityCenter
        imagelayer.backgroundColor=UIColor.black.cgColor
        imagelayer.shadowOpacity = 0.7
        imagelayer.shadowRadius = 10.0
        imagelayer.cornerRadius = imagelayer.frame.width/2
        imagelayer.isHidden = false
        imagelayer.masksToBounds = false
        
        animatedView.layer.addSublayer(imagelayer)
        
        UIView.animate(withDuration: 2.0, animations: {
            self.animatedView.alpha = 1.0
        }, completion: { finished in
            self.performSegue(withIdentifier: "moveToMain", sender: self)
        })
        
        
    }
    
}
