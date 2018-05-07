//
//  ColorSettings.swift
//  CheckIn
//
//  Created by Anand Kelkar on 02/05/18.
//  Copyright © 2018 Sam Walk. All rights reserved.
//

import Foundation
import UIKit

public class ColorSettings {
//    public static var navBarColor:UIColor=UIColor(red:2,green:86,blue:0)
//    public static var labelColor:UIColor=UIColor(red:3,green:129,blue:0)
//    public static var textColor:UIColor=UIColor(red:253,green:201,blue:16)
//    public static var lineColor:UIColor=UIColor(red:3,green:129,blue:0)
    
    public static var navBarColor:UIColor=UIColor(red:32,green:32,blue:32)
    public static var labelColor:UIColor=UIColor.black
    public static var textColor:UIColor=UIColor.darkGray
    public static var lineColor:UIColor=UIColor.darkGray
    public static var navTextColor:UIColor=UIColor.white
    
    public class func switchToColor(){
        navBarColor=UIColor(red:2,green:86,blue:0)
        labelColor=UIColor(red:3,green:129,blue:0)
        textColor=UIColor(red:253,green:201,blue:16)
        lineColor=UIColor(red:3,green:129,blue:0)
        navTextColor=UIColor(red:253,green:201,blue:16)
    }
}
